using System;
using System.Collections.Generic;

namespace MiChangarro.Models
{
    public partial class Actor
    {
        public Actor()
        {
            Movies = new HashSet<Movie>();
        }

        public int ActorId { get; set; }
        public string? FirstName { get; set; }
        public string LastName { get; set; } = null!;
        public char? Gender { get; set; }
        public DateOnly? DateOfBirth { get; set; }

        public virtual ICollection<Movie> Movies { get; set; }
    }
}
