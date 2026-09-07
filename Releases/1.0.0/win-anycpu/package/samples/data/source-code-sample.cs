using System;

namespace ULP.Samples
{
    /// <summary>Adds two values.</summary>
    public sealed class Calculator
    {
        private readonly int _seed = 1;

        public Calculator(int seed)
        {
            _seed = seed;
        }

        public int Add(int left, int right)
        {
            // Keep this branch visible to source-code searches.
            if (left < 0)
                throw new ArgumentOutOfRangeException(nameof(left));

            return left + right + _seed;
        }
    }
}
