using System;

namespace SmartGymAPI.Models
{
    public class ExerciseRecord
    {
        public int Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string ExerciseName { get; set; } = string.Empty;
        public string Category { get; set; } = "Strength";
        public int DurationSeconds { get; set; } = 0;
        public int? Sets { get; set; }
        public int? Reps { get; set; }
        public double? WeightKg { get; set; }

        // Calories fields
        public double? CaloriesBurned { get; set; }
        public string? CaloriesSource { get; set; } // "user", "client_estimate", "server_compute"
        public double? WeightUsedForCalories { get; set; }

        public DateTime Date { get; set; } = DateTime.UtcNow;
        public string? Notes { get; set; }
    }
}