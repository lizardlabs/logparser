using Microsoft.AspNetCore.Mvc.RazorPages;

namespace Ulp.Docs.Web.Pages;

public sealed class ErrorModel : PageModel
{
    public void OnGet()
    {
        Response.StatusCode = StatusCodes.Status500InternalServerError;
        ViewData["Title"] = "Documentation error";
        ViewData["Description"] = "The documentation page could not be displayed.";
        ViewData["Robots"] = "noindex, nofollow";
    }
}
