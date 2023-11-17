using System;
using System.Collections.Generic;

namespace MiChangarro.Models
{
    public partial class MovieRevenue
    {
        public int RevenueId { get; set; }
        public int? MovieId { get; set; }
        public decimal? DomesticTakings { get; set; }
        public decimal? InternationalTakings { get; set; }

        public virtual Movie? Movie { get; set; }
    }
}
