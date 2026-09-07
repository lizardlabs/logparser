using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Ulp.Docs.Web.Models;
using Ulp.Docs.Web.Services;

namespace Ulp.Docs.Web.Pages;

public sealed class DocsModel(MarkdownDocumentationService documentation) : PageModel
{
    public DocumentationPage Document { get; private set; } = null!;

    public IActionResult OnGet(string? slug)
    {
        var document = documentation.GetPage(slug);
        if (document is null)
        {
            return NotFound();
        }

        Document = document;
        ViewData["Title"] = document.Title;
        ViewData["Description"] = document.Description;
        ViewData["CurrentSlug"] = document.Slug;
        ViewData["PageKind"] = "document";
        return Page();
    }
}

