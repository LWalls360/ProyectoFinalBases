using System;
using System.Collections.Generic;

namespace MiChangarro.Models
{
    public partial class Movie
    {
        public Movie()
        {
            MovieRevenues = new HashSet<MovieRevenue>();
            Actors = new HashSet<Actor>();
        }

        public int MovieId { get; set; }
        public string MovieName { get; set; } = null!;
        public int? MovieLength { get; set; }
        public string? MovieLang { get; set; }
        public DateOnly? ReleaseDate { get; set; }
        public string? AgeCertificate { get; set; }
        public int? DirectorId { get; set; }

        public virtual Director? Director { get; set; }
        public virtual ICollection<MovieRevenue> MovieRevenues { get; set; }

        public virtual ICollection<Actor> Actors { get; set; }
    }
}
