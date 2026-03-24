using System;

namespace SmartGymAPI.Models
{
    public class NutritionRecord
    {
        public int Id { get; set; }              // Khóa chính
        public string UserId { get; set; }       // Id người dùng (liên kết với IdentityUser)

        public string MealType { get; set; }     // Tên món ăn
        public int Calories { get; set; }        // Tổng calories
        public double Protein { get; set; }      // Gram protein
        public double Carbs { get; set; }        // Gram carbs
        public double Fat { get; set; }          // Gram fat

        public DateTime Date { get; set; }       // Ngày ghi (UTC)

        // --- MỚI: phân loại bữa và thời gian ăn ---
        // mealSlot: breakfast | lunch | afternoon | dinner | snack
        public string MealSlot { get; set; } = "lunch";

        // consumedAt: thời gian ăn cụ thể (UTC)
        public DateTime? ConsumedAt { get; set; }
    }
}