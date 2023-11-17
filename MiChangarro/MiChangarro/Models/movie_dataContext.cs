using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace MiChangarro.Models
{
    public partial class movie_dataContext : DbContext
    {
        public movie_dataContext()
        {
        }

        public movie_dataContext(DbContextOptions<movie_dataContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Actor> Actors { get; set; } = null!;
        public virtual DbSet<Director> Directors { get; set; } = null!;
        public virtual DbSet<Movie> Movies { get; set; } = null!;
        public virtual DbSet<MovieRevenue> MovieRevenues { get; set; } = null!;

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                optionsBuilder.UseNpgsql("Host=localhost;Database=movie_data;Username=luisadmin;Password=Primal5_Stabilize_Crudely");
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Actor>(entity =>
            {
                entity.ToTable("actors");

                entity.Property(e => e.ActorId).HasColumnName("actor_id");

                entity.Property(e => e.DateOfBirth).HasColumnName("date_of_birth");

                entity.Property(e => e.FirstName)
                    .HasMaxLength(30)
                    .HasColumnName("first_name");

                entity.Property(e => e.Gender)
                    .HasMaxLength(1)
                    .HasColumnName("gender");

                entity.Property(e => e.LastName)
                    .HasMaxLength(30)
                    .HasColumnName("last_name");
            });

            modelBuilder.Entity<Director>(entity =>
            {
                entity.ToTable("directors");

                entity.Property(e => e.DirectorId).HasColumnName("director_id");

                entity.Property(e => e.DateOfBirth).HasColumnName("date_of_birth");

                entity.Property(e => e.FirstName)
                    .HasMaxLength(30)
                    .HasColumnName("first_name");

                entity.Property(e => e.LastName)
                    .HasMaxLength(30)
                    .HasColumnName("last_name");

                entity.Property(e => e.Nationality)
                    .HasMaxLength(20)
                    .HasColumnName("nationality");
            });

            modelBuilder.Entity<Movie>(entity =>
            {
                entity.ToTable("movies");

                entity.Property(e => e.MovieId).HasColumnName("movie_id");

                entity.Property(e => e.AgeCertificate)
                    .HasMaxLength(5)
                    .HasColumnName("age_certificate");

                entity.Property(e => e.DirectorId).HasColumnName("director_id");

                entity.Property(e => e.MovieLang)
                    .HasMaxLength(20)
                    .HasColumnName("movie_lang");

                entity.Property(e => e.MovieLength).HasColumnName("movie_length");

                entity.Property(e => e.MovieName)
                    .HasMaxLength(50)
                    .HasColumnName("movie_name");

                entity.Property(e => e.ReleaseDate).HasColumnName("release_date");

                entity.HasOne(d => d.Director)
                    .WithMany(p => p.Movies)
                    .HasForeignKey(d => d.DirectorId)
                    .HasConstraintName("movies_director_id_fkey");

                entity.HasMany(d => d.Actors)
                    .WithMany(p => p.Movies)
                    .UsingEntity<Dictionary<string, object>>(
                        "MovieActor",
                        l => l.HasOne<Actor>().WithMany().HasForeignKey("ActorId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("movie_actors_actor_id_fkey"),
                        r => r.HasOne<Movie>().WithMany().HasForeignKey("MovieId").OnDelete(DeleteBehavior.ClientSetNull).HasConstraintName("movie_actors_movie_id_fkey"),
                        j =>
                        {
                            j.HasKey("MovieId", "ActorId").HasName("movie_actors_pkey");

                            j.ToTable("movie_actors");

                            j.IndexerProperty<int>("MovieId").HasColumnName("movie_id");

                            j.IndexerProperty<int>("ActorId").HasColumnName("actor_id");
                        });
            });

            modelBuilder.Entity<MovieRevenue>(entity =>
            {
                entity.HasKey(e => e.RevenueId)
                    .HasName("movie_revenues_pkey");

                entity.ToTable("movie_revenues");

                entity.Property(e => e.RevenueId).HasColumnName("revenue_id");

                entity.Property(e => e.DomesticTakings)
                    .HasPrecision(6, 2)
                    .HasColumnName("domestic_takings");

                entity.Property(e => e.InternationalTakings)
                    .HasPrecision(6, 2)
                    .HasColumnName("international_takings");

                entity.Property(e => e.MovieId).HasColumnName("movie_id");

                entity.HasOne(d => d.Movie)
                    .WithMany(p => p.MovieRevenues)
                    .HasForeignKey(d => d.MovieId)
                    .HasConstraintName("movie_revenues_movie_id_fkey");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
