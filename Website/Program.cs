using System.Security.Cryptography;
using System.Text;
using System.Xml;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Options;
using Ulp.Docs.Web.Options;
using Ulp.Docs.Web.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddSimpleConsole(options =>
{
    options.SingleLine = true;
    options.TimestampFormat = "HH:mm:ss ";
});
builder.Services.Configure<DocumentationOptions>(builder.Configuration.GetSection("Documentation"));
builder.Services.Configure<SiteOptions>(builder.Configuration.GetSection("Site"));
builder.Services.AddSingleton<MarkdownDocumentationService>();
builder.Services.AddRazorPages();
builder.Services.AddSingleton<IDataProtectionProvider>(new EphemeralDataProtectionProvider());
builder.Services.AddResponseCompression(options => options.EnableForHttps = true);

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownIPNetworks.Clear();
    options.KnownProxies.Clear();
});

var app = builder.Build();
var siteOptions = app.Services.GetRequiredService<IOptions<SiteOptions>>().Value;

if (siteOptions.TrustForwardedHeaders)
{
    app.UseForwardedHeaders();
}
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/error");
    app.UseHsts();
}
app.UseStatusCodePagesWithReExecute("/not-found");

if (siteOptions.RequireHttps)
{
    app.UseHttpsRedirection();
}

if (!app.Environment.IsDevelopment())
{
    app.UseResponseCompression();
}
app.Use(async (context, next) =>
{
    var nonceBytes = RandomNumberGenerator.GetBytes(18);
    var nonce = Convert.ToBase64String(nonceBytes);
    context.Items["CspNonce"] = nonce;
    context.Response.Headers.ContentSecurityPolicy =
        $"default-src 'self'; script-src 'self' 'nonce-{nonce}'; style-src 'self'; img-src 'self' data: https:; font-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'";
    context.Response.Headers.XContentTypeOptions = "nosniff";
    context.Response.Headers.XFrameOptions = "DENY";
    context.Response.Headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
    context.Response.Headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=(), payment=()";
    await next();
});

app.UseStaticFiles();
app.UseRouting();

app.MapGet("/robots.txt", (HttpContext context) =>
{
    var baseUrl = ResolveBaseUrl(context, siteOptions);
    return Results.Text($"User-agent: *\nAllow: /\nSitemap: {baseUrl}/sitemap.xml\n", "text/plain", Encoding.UTF8);
});

app.MapGet("/sitemap.xml", (HttpContext context, MarkdownDocumentationService documentation) =>
{
    var baseUrl = ResolveBaseUrl(context, siteOptions);
    var settings = new XmlWriterSettings { Indent = true, OmitXmlDeclaration = false, Encoding = new UTF8Encoding(false) };
    using var buffer = new MemoryStream();
    using (var writer = XmlWriter.Create(buffer, settings))
    {
        writer.WriteStartDocument();
        writer.WriteStartElement("urlset", "http://www.sitemaps.org/schemas/sitemap/0.9");
        WriteSitemapUrl(writer, baseUrl + "/");
        foreach (var slug in documentation.GetAllSlugs())
        {
            WriteSitemapUrl(writer, $"{baseUrl}/docs/{Uri.EscapeDataString(slug).Replace("%2F", "/", StringComparison.OrdinalIgnoreCase)}");
        }
        writer.WriteEndElement();
        writer.WriteEndDocument();
    }
    return Results.Bytes(buffer.ToArray(), "application/xml; charset=utf-8");
});

var contentTypeProvider = new FileExtensionContentTypeProvider();
app.MapGet("/docs-assets/{**path}", (string? path, MarkdownDocumentationService documentation) =>
{
    var asset = documentation.FindAsset(path);
    if (asset is null)
    {
        return Results.NotFound();
    }

    if (!contentTypeProvider.TryGetContentType(asset, out var contentType))
    {
        contentType = "application/octet-stream";
    }
    return Results.File(asset, contentType, enableRangeProcessing: true);
});

app.MapRazorPages();
app.Run();

static string ResolveBaseUrl(HttpContext context, SiteOptions options)
{
    if (!string.IsNullOrWhiteSpace(options.CanonicalBaseUrl))
    {
        return options.CanonicalBaseUrl.TrimEnd('/');
    }
    return $"{context.Request.Scheme}://{context.Request.Host}{context.Request.PathBase}".TrimEnd('/');
}

static void WriteSitemapUrl(XmlWriter writer, string url)
{
    writer.WriteStartElement("url");
    writer.WriteElementString("loc", url);
    writer.WriteEndElement();
}

public partial class Program;
