using Microsoft.AspNetCore.Mvc.RazorPages;
using Ulp.Docs.Web.Models;
using Ulp.Docs.Web.Services;

namespace Ulp.Docs.Web.Pages;

public sealed class IndexModel(MarkdownDocumentationService documentation) : PageModel
{
    public NavigationCatalog Navigation { get; private set; } = new();

    public void OnGet()
    {
        Navigation = documentation.GetNavigation();
        ViewData["Title"] = "Universal Log Parser documentation";
        ViewData["Description"] = "Learn how to query files, logs, Windows data, source code, assemblies, and databases with Universal Log Parser.";
        ViewData["PageKind"] = "home";
    }
}

