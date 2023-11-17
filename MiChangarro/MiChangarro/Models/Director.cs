using System;
using System.Collections.Generic;

namespace MiChangarro.Models
{
    public partial class Director
    {
        public Director()
        {
            Movies = new HashSet<Movie>();
        }

        public int DirectorId { get; set; }
        public string? FirstName { get; set; }
        public string LastName { get; set; } = null!;
        public DateOnly? DateOfBirth { get; set; }
        public string? Nationality { get; set; }

        public virtual ICollection<Movie> Movies { get; set; }
    }
}
