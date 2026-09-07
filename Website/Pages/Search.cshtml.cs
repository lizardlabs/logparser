using Microsoft.AspNetCore.Mvc.RazorPages;
using Ulp.Docs.Web.Models;
using Ulp.Docs.Web.Services;

namespace Ulp.Docs.Web.Pages;

public sealed class SearchModel(MarkdownDocumentationService documentation) : PageModel
{
    public string Query { get; private set; } = string.Empty;

    public IReadOnlyList<SearchResult> Results { get; private set; } = [];

    public void OnGet(string? q)
    {
        Query = q?.Trim() ?? string.Empty;
        Results = documentation.Search(Query);
        ViewData["Title"] = string.IsNullOrWhiteSpace(Query) ? "Search documentation" : $"Search: {Query}";
        ViewData["Description"] = "Search the Universal Log Parser user manual.";
        ViewData["PageKind"] = "search";
    }
}

