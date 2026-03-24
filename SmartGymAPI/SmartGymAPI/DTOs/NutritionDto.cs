using System;

namespace SmartGymAPI.DTOs
{
    public class NutritionDto
    {
        public string? MealType { get; set; }    // Tên món ăn
        public int Calories { get; set; }        // Calories
        public double Protein { get; set; }      // Protein
        public double Carbs { get; set; }        // Carbs
        public double Fat { get; set; }          // Fat
        public DateTime? Date { get; set; }      // Ngày ghi (optional, mặc định = DateTime.UtcNow)

        // --- MỚI ---
        public string? MealSlot { get; set; }    // breakfast|lunch|afternoon|dinner|snack
        public DateTime? ConsumedAt { get; set; } // thời gian ăn (optional)
    }
}