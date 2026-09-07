using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Ulp.Docs.Web.Pages;

public sealed class NotFoundModel : PageModel
{
    public void OnGet()
    {
        Response.StatusCode = StatusCodes.Status404NotFound;
        ViewData["Title"] = "Page not found";
        ViewData["Description"] = "The requested ULP documentation page was not found.";
        ViewData["Robots"] = "noindex, nofollow";
    }
}

