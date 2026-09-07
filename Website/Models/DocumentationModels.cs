namespace Ulp.Docs.Web.Models;

public sealed record DocumentationPage(
    string Slug,
    string Title,
    string Description,
    string Html,
    string SourcePath,
    IReadOnlyList<DocumentHeading> Headings);

public sealed record DocumentHeading(int Level, string Id, string Text);

public sealed record SearchResult(string Slug, string Title, string Description, string Snippet, int Score);

public sealed class NavigationCatalog
{
    public List<NavigationGroup> Groups { get; set; } = [];
}

public sealed class NavigationGroup
{
    public string Title { get; set; } = string.Empty;

    public List<NavigationItem> Items { get; set; } = [];
}

public sealed class NavigationItem
{
    public string Title { get; set; } = string.Empty;

    public string Slug { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;
}

