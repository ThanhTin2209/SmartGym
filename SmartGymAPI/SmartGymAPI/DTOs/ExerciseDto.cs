using System;

namespace SmartGymAPI.DTOs
{
    public class ExerciseDto
    {
        public string ExerciseName { get; set; } = string.Empty;
        public string Category { get; set; } = "Strength";
        public int DurationSeconds { get; set; }
        public int? Sets { get; set; }
        public int? Reps { get; set; }
        public double? WeightKg { get; set; }

        // Client may optionally send calories and source
        public double? CaloriesBurned { get; set; }
        public string? CaloriesSource { get; set; } // "user" when user typed it, or "client_estimate"

        public DateTime? Date { get; set; }
        public string? Notes { get; set; }
    }
}