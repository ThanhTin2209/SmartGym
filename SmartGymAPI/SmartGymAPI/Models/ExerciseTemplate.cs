namespace SmartGymAPI.Models
{
    public class ExerciseTemplate
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Category { get; set; } = "Strength";
        public int DurationSeconds { get; set; }
        public string Intensity { get; set; } = "Moderate";
        public double BaseMet { get; set; } = 5.0;
        public string Level { get; set; } = "Beginner";
    }
}