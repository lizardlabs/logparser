using System.Collections.Concurrent;
using System.Net;
using System.Text.Json;
using System.Text.RegularExpressions;
using Markdig;
using Markdig.Extensions.AutoIdentifiers;
using Microsoft.Extensions.Options;
using Ulp.Docs.Web.Models;
using Ulp.Docs.Web.Options;

namespace Ulp.Docs.Web.Services;

public sealed partial class MarkdownDocumentationService
{
    private static readonly HashSet<string> AllowedAssetExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".ico", ".pdf",
        ".json", ".csv", ".txt", ".sql", ".ps1", ".config", ".zip"
    };

    private readonly string _contentRoot;
    private readonly string _contentRootPrefix;
    private readonly string _navigationFile;
    private readonly MarkdownPipeline _pipeline;
    private readonly ConcurrentDictionary<string, CachedPage> _pageCache = new(StringComparer.OrdinalIgnoreCase);
    private NavigationCatalog? _navigation;

    public MarkdownDocumentationService(
        IWebHostEnvironment environment,
        IOptions<DocumentationOptions> options)
    {
        _contentRoot = ResolveContentRoot(environment, options.Value.SourcePath);
        _contentRootPrefix = _contentRoot.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
        _navigationFile = Path.IsPathRooted(options.Value.NavigationFile)
            ? options.Value.NavigationFile
            : Path.Combine(environment.ContentRootPath, options.Value.NavigationFile);
        _pipeline = new MarkdownPipelineBuilder()
            .UseAdvancedExtensions()
            .UseAutoIdentifiers(AutoIdentifierOptions.GitHub)
            .DisableHtml()
            .Build();
    }

    public NavigationCatalog GetNavigation()
    {
        if (_navigation is not null)
        {
            return _navigation;
        }

        if (!File.Exists(_navigationFile))
        {
            throw new FileNotFoundException("Documentation navigation was not found.", _navigationFile);
        }

        var json = File.ReadAllText(_navigationFile);
        _navigation = JsonSerializer.Deserialize<NavigationCatalog>(json, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        }) ?? new NavigationCatalog();
        return _navigation;
    }

    public DocumentationPage? GetPage(string? requestedSlug)
    {
        var slug = NormalizeSlug(requestedSlug);
        var path = ResolveMarkdownPath(slug);
        if (path is null || !File.Exists(path))
        {
            return null;
        }

        var modified = File.GetLastWriteTimeUtc(path);
        if (_pageCache.TryGetValue(slug, out var cached) && cached.ModifiedUtc == modified)
        {
            return cached.Page;
        }

        var markdown = File.ReadAllText(path);
        var title = ExtractTitle(markdown, slug);
        var description = ExtractDescription(markdown, title);
        var html = Markdown.ToHtml(markdown, _pipeline);
        html = RewriteRelativeUrls(html, slug);
        var headings = ExtractHeadings(html);
        var page = new DocumentationPage(slug, title, description, html, path, headings);
        _pageCache[slug] = new CachedPage(modified, page);
        return page;
    }

    public IReadOnlyList<SearchResult> Search(string? query, int maximumResults = 30)
    {
        var search = query?.Trim();
        if (string.IsNullOrWhiteSpace(search) || search.Length < 2)
        {
            return [];
        }

        var results = new List<SearchResult>();
        foreach (var file in Directory.EnumerateFiles(_contentRoot, "*.md", SearchOption.AllDirectories))
        {
            if (IsPrivateDocumentation(file)) continue;
            var markdown = File.ReadAllText(file);
            var slug = ToSlug(file);
            var title = ExtractTitle(markdown, slug);
            var titleMatches = CountOccurrences(title, search);
            var bodyMatches = CountOccurrences(markdown, search);
            if (titleMatches == 0 && bodyMatches == 0)
            {
                continue;
            }

            var description = ExtractDescription(markdown, title);
            results.Add(new SearchResult(
                slug,
                title,
                description,
                BuildSnippet(markdown, search),
                (titleMatches * 20) + Math.Min(bodyMatches, 20)));
        }

        return results
            .OrderByDescending(result => result.Score)
            .ThenBy(result => result.Title, StringComparer.OrdinalIgnoreCase)
            .Take(Math.Clamp(maximumResults, 1, 100))
            .ToArray();
    }

    public IReadOnlyList<string> GetAllSlugs() => Directory
        .EnumerateFiles(_contentRoot, "*.md", SearchOption.AllDirectories)
        .Where(file => !IsPrivateDocumentation(file))
        .Select(ToSlug)
        .OrderBy(slug => slug, StringComparer.OrdinalIgnoreCase)
        .ToArray();

    public string? FindAsset(string? requestedPath)
    {
        if (string.IsNullOrWhiteSpace(requestedPath))
        {
            return null;
        }

        var relative = Uri.UnescapeDataString(requestedPath).Replace('/', Path.DirectorySeparatorChar);
        var candidate = Path.GetFullPath(Path.Combine(_contentRoot, relative));
        if (!IsWithinContentRoot(candidate) || IsPrivateDocumentation(candidate) || !File.Exists(candidate))
        {
            return null;
        }

        return AllowedAssetExtensions.Contains(Path.GetExtension(candidate)) ? candidate : null;
    }

    private static string ResolveContentRoot(IWebHostEnvironment environment, string configuredPath)
    {
        var candidates = new List<string>();
        if (Path.IsPathRooted(configuredPath))
        {
            candidates.Add(configuredPath);
        }
        else
        {
            candidates.Add(Path.Combine(AppContext.BaseDirectory, configuredPath));
            candidates.Add(Path.Combine(environment.ContentRootPath, configuredPath));
            candidates.Add(Path.Combine(environment.ContentRootPath, "..", "Documentation", "UserGuide"));
        }

        var selected = candidates.Select(Path.GetFullPath).FirstOrDefault(Directory.Exists);
        return selected ?? throw new DirectoryNotFoundException(
            $"Documentation content was not found. Checked: {string.Join(", ", candidates)}");
    }

    private string? ResolveMarkdownPath(string slug)
    {
        var relative = slug.Equals("index", StringComparison.OrdinalIgnoreCase) ? "README" : slug;
        var candidate = Path.GetFullPath(Path.Combine(_contentRoot, relative.Replace('/', Path.DirectorySeparatorChar) + ".md"));
        return IsWithinContentRoot(candidate) && !IsPrivateDocumentation(candidate) ? candidate : null;
    }

    private bool IsPrivateDocumentation(string path)
    {
        // Old deployment folders may retain files removed from a newer package.
        // Never expose maintainer-only records through pages, search or downloads.
        var relative = Path.GetRelativePath(_contentRoot, path).Replace('\\', '/');
        return relative.StartsWith("developer/", StringComparison.OrdinalIgnoreCase)
            || new[] { "legal/COMPLIANCE-REVIEW.md", "legal/PRODUCT-LEGAL.md", "legal/EULA-TEMPLATE.md" }
                .Contains(relative, StringComparer.OrdinalIgnoreCase);
    }

    private bool IsWithinContentRoot(string path) =>
        path.StartsWith(_contentRootPrefix, StringComparison.OrdinalIgnoreCase) ||
        path.Equals(_contentRoot, StringComparison.OrdinalIgnoreCase);

    private string ToSlug(string path)
    {
        var relative = Path.GetRelativePath(_contentRoot, path).Replace(Path.DirectorySeparatorChar, '/');
        var slug = relative[..^Path.GetExtension(relative).Length];
        return slug.Equals("README", StringComparison.OrdinalIgnoreCase) ? "index" : slug;
    }

    private string RewriteRelativeUrls(string html, string currentSlug) => HtmlUrlRegex().Replace(html, match =>
    {
        var attribute = match.Groups["attribute"].Value;
        var quote = match.Groups["quote"].Value;
        var rawUrl = WebUtility.HtmlDecode(match.Groups["url"].Value);
        if (rawUrl.StartsWith('#') || rawUrl.StartsWith('/') || rawUrl.StartsWith("http:", StringComparison.OrdinalIgnoreCase) ||
            rawUrl.StartsWith("https:", StringComparison.OrdinalIgnoreCase) || rawUrl.StartsWith("mailto:", StringComparison.OrdinalIgnoreCase))
        {
            return match.Value;
        }

        var fragmentIndex = rawUrl.IndexOf('#');
        var fragment = fragmentIndex >= 0 ? rawUrl[fragmentIndex..] : string.Empty;
        var target = fragmentIndex >= 0 ? rawUrl[..fragmentIndex] : rawUrl;
        var currentDirectory = currentSlug.Contains('/') ? currentSlug[..currentSlug.LastIndexOf('/')] : string.Empty;
        var normalized = NormalizeRelativePath(currentDirectory, target);
        if (normalized is null)
        {
            return $"{attribute}={quote}#{quote}";
        }

        string rewritten;
        if (target.EndsWith(".md", StringComparison.OrdinalIgnoreCase))
        {
            normalized = normalized[..^3];
            if (normalized.Equals("README", StringComparison.OrdinalIgnoreCase))
            {
                normalized = "index";
            }
            rewritten = "/docs/" + EscapePath(normalized) + fragment;
        }
        else
        {
            rewritten = "/docs-assets/" + EscapePath(normalized) + fragment;
        }
        return $"{attribute}={quote}{WebUtility.HtmlEncode(rewritten)}{quote}";
    });

    private static string? NormalizeRelativePath(string currentDirectory, string target)
    {
        var parts = new List<string>();
        foreach (var part in (currentDirectory + "/" + target).Split('/', StringSplitOptions.RemoveEmptyEntries))
        {
            if (part == ".")
            {
                continue;
            }
            if (part == "..")
            {
                if (parts.Count == 0)
                {
                    return null;
                }
                parts.RemoveAt(parts.Count - 1);
                continue;
            }
            parts.Add(Uri.UnescapeDataString(part));
        }
        return string.Join('/', parts);
    }

    private static string EscapePath(string path) => string.Join('/', path
        .Split('/', StringSplitOptions.RemoveEmptyEntries)
        .Select(Uri.EscapeDataString));

    private static string NormalizeSlug(string? value)
    {
        var slug = string.IsNullOrWhiteSpace(value) ? "index" : Uri.UnescapeDataString(value).Trim().Replace('\\', '/').Trim('/');
        if (slug.EndsWith(".md", StringComparison.OrdinalIgnoreCase))
        {
            slug = slug[..^3];
        }
        return string.IsNullOrWhiteSpace(slug) ? "index" : slug;
    }

    private static string ExtractTitle(string markdown, string slug)
    {
        var match = TitleRegex().Match(markdown);
        if (match.Success)
        {
            return CleanMarkdown(match.Groups["title"].Value);
        }
        return slug.Split('/').Last().Replace('-', ' ');
    }

    private static string ExtractDescription(string markdown, string title)
    {
        var blocks = ParagraphBreakRegex().Split(markdown);
        foreach (var block in blocks)
        {
            var trimmed = block.Trim();
            if (trimmed.Length == 0 || trimmed.StartsWith('#') || trimmed.StartsWith("```", StringComparison.Ordinal) ||
                trimmed.StartsWith('|') || trimmed.StartsWith('>') || trimmed.StartsWith("<!--", StringComparison.Ordinal))
            {
                continue;
            }
            var clean = CleanMarkdown(trimmed.ReplaceLineEndings(" "));
            if (clean.Length > 20)
            {
                return clean.Length <= 180 ? clean : clean[..177].TrimEnd() + "...";
            }
        }
        return $"Learn how to use {title} in Universal Log Parser.";
    }

    private static IReadOnlyList<DocumentHeading> ExtractHeadings(string html)
    {
        return HeadingRegex().Matches(html)
            .Select(match => new DocumentHeading(
                int.Parse(match.Groups["level"].Value),
                WebUtility.HtmlDecode(match.Groups["id"].Value),
                WebUtility.HtmlDecode(HtmlTagRegex().Replace(match.Groups["text"].Value, string.Empty))))
            .Where(heading => heading.Text.Length > 0)
            .ToArray();
    }

    private static string BuildSnippet(string markdown, string query)
    {
        var plain = CleanMarkdown(markdown.ReplaceLineEndings(" "));
        var index = plain.IndexOf(query, StringComparison.OrdinalIgnoreCase);
        var start = Math.Max(0, index - 90);
        var length = Math.Min(240, plain.Length - start);
        var snippet = plain.Substring(start, length).Trim();
        return (start > 0 ? "…" : string.Empty) + snippet + (start + length < plain.Length ? "…" : string.Empty);
    }

    private static int CountOccurrences(string text, string value)
    {
        var count = 0;
        var index = 0;
        while ((index = text.IndexOf(value, index, StringComparison.OrdinalIgnoreCase)) >= 0)
        {
            count++;
            index += Math.Max(value.Length, 1);
        }
        return count;
    }

    private static string CleanMarkdown(string value)
    {
        var withoutLinks = MarkdownLinkRegex().Replace(value, "$1");
        var withoutMarkup = MarkdownMarkupRegex().Replace(withoutLinks, " ");
        return WhitespaceRegex().Replace(withoutMarkup, " ").Trim();
    }

    private sealed record CachedPage(DateTime ModifiedUtc, DocumentationPage Page);

    [GeneratedRegex("^#\\s+(?<title>.+)$", RegexOptions.Multiline)]
    private static partial Regex TitleRegex();

    [GeneratedRegex("(?:\\r?\\n){2,}")]
    private static partial Regex ParagraphBreakRegex();

    [GeneratedRegex("(?<attribute>href|src)=(?<quote>[\\\"])(?<url>[^\\\"]+)\\k<quote>", RegexOptions.IgnoreCase)]
    private static partial Regex HtmlUrlRegex();

    [GeneratedRegex("<h(?<level>[23]) id=\\\"(?<id>[^\\\"]+)\\\">(?<text>.*?)</h\\k<level>>", RegexOptions.IgnoreCase | RegexOptions.Singleline)]
    private static partial Regex HeadingRegex();

    [GeneratedRegex("<[^>]+>")]
    private static partial Regex HtmlTagRegex();

    [GeneratedRegex("\\[([^\\]]+)\\]\\([^\\)]+\\)")]
    private static partial Regex MarkdownLinkRegex();

    [GeneratedRegex("[`*_#>|~\\[\\]{}]")]
    private static partial Regex MarkdownMarkupRegex();

    [GeneratedRegex("\\s+")]
    private static partial Regex WhitespaceRegex();
}

