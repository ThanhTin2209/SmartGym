namespace SmartGymAPI.DTOs
{
    public class ExerciseSuggestionDto
    {
        public string Name { get; set; } = string.Empty;
        public string Category { get; set; } = "Strength";
        public int DurationSeconds { get; set; }
        public string Intensity { get; set; } = "Moderate";
        public double EstimatedCalories { get; set; }
        public string ReasonTag { get; set; } = "";
    }
}