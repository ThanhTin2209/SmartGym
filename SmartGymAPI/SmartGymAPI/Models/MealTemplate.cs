using System.ComponentModel.DataAnnotations;

namespace SmartGymAPI.Models
{
    public class MealTemplate
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        // Categories: "Breakfast", "Lunch", "Dinner", "Snack", "Pre-workout", "Post-workout"
        public string Category { get; set; } = "Snack";

        public int Calories { get; set; }
        public double Protein { get; set; }
        public double Carbs { get; set; }
        public double Fat { get; set; }

        public string? ImageUrl { get; set; }

        // Similar to ExerciseTemplate, we can have a "Goal" tag or "Level" but for food maybe "DietType"
        // e.g., "Keto", "Vegan", "Balanced", "High Protein"
        public string DietType { get; set; } = "Balanced";
    }
}
