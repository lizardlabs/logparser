namespace Ulp.Docs.Web.Options;

public sealed class SiteOptions
{
    public string Name { get; set; } = "ULP Documentation";

    public string CanonicalBaseUrl { get; set; } = string.Empty;

    public bool RequireHttps { get; set; }

    public bool TrustForwardedHeaders { get; set; }

    public string HomeUrl { get; set; } = "https://log-parser.com";

    public string CompanyUrl { get; set; } = "https://lizard-labs.com";

    public string IdeasUrl { get; set; } = "https://github.com/lizardlabs/logparser/issues/new?labels=idea";

    public string BugsUrl { get; set; } = "https://github.com/lizardlabs/logparser/issues/new?labels=bug";
}
