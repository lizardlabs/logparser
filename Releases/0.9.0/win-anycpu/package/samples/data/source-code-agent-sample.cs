using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace ULP.AgentSamples
{
    /// <summary>Small service used to exercise structured coding-agent searches.</summary>
    public sealed class OrderService<TOrder> where TOrder : class
    {
        private readonly HttpClient _client;

        public OrderService(HttpClient client)
        {
            _client = client;
        }

        /// <summary>Loads and filters orders asynchronously.</summary>
        public async Task<IReadOnlyList<TOrder>> LoadAsync(string path, int minimumLength)
        {
            if (string.IsNullOrWhiteSpace(path))
                throw new ArgumentException("A path is required.", nameof(path));

            var text = await File.ReadAllTextAsync(path);
            var response = await _client.GetStringAsync("https://example.invalid/orders");
            return Parse(text + response)
                .Where(order => order.ToString().Length >= minimumLength)
                .ToList();
        }

        public IReadOnlyList<TOrder> Parse(string value)
        {
            return Array.Empty<TOrder>();
        }

        public IReadOnlyList<TOrder> Parse(IEnumerable<string> values)
        {
            return values.SelectMany(Parse).ToList();
        }

        // Intentionally branchy so hotspot queries have a stable result.
        public int Classify(int value)
        {
            if (value < 0)
                return -1;
            if (value > ) // intentional syntax diagnostic
                return 0;
            return value > 100 ? 2 : 1;
        }
    }
}
