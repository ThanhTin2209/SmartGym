namespace SmartGymAPI.Models
{
    public class HealthProfile
    {
        public int Id { get; set; }
        public string UserId { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public int Age { get; set; }
        public double Height { get; set; } // cm
        public double Weight { get; set; } // kg
        public string Gender { get; set; } = string.Empty; // "Male" hoặc "Female"
        public string Goal { get; set; } = string.Empty;   // "Maintain", "FatLoss", "MuscleGain"
        public double Bmi { get; set; }

        // 🟢 Thêm mức độ hoạt động để tính PAL
        public string ActivityLevel { get; set; } = "Sedentary"; // Sedentary, Light, Moderate, Active

        // 🟢 Mức độ tập luyện (Beginner/Intermediate/Advanced) dùng cho gợi ý
        public string Level { get; set; } = "Beginner"; // Beginner, Intermediate, Advanced

        // 🟢 Lưu mục tiêu kcal/ngày đã tính toán (nếu user lưu thủ công)
        public int DailyCalorieGoal { get; set; }

        // 🟢 Ví GymCoin (Blockchain Mock)
        public string? WalletAddress { get; set; }
        public string? PrivateKey { get; set; }
        [System.ComponentModel.DataAnnotations.Schema.Column(TypeName = "decimal(18, 2)")]
        public decimal GymCoinBalance { get; set; } = 0;

        // 📌 Hàm tính toán kcal/ngày dựa trên BMR + PAL + Goal
        public int CalculateDailyCalories()
        {
            // BMR theo công thức Mifflin-St Jeor
            double bmr;
            var genderLower = (Gender ?? string.Empty).ToLowerInvariant();
            if (genderLower == "male")
                bmr = 10 * Weight + 6.25 * Height - 5 * Age + 5;
            else
                bmr = 10 * Weight + 6.25 * Height - 5 * Age - 161;

            // PAL (Physical Activity Level)
            double pal = (ActivityLevel ?? string.Empty).ToLowerInvariant() switch
            {
                "sedentary" => 1.2,
                "light" => 1.375,
                "moderate" => 1.55,
                "active" => 1.725,
                _ => 1.2
            };

            double maintenanceCalories = bmr * pal;

            // Điều chỉnh theo mục tiêu
            return (Goal ?? string.Empty).ToLowerInvariant() switch
            {
                "fatloss" => (int)Math.Round(maintenanceCalories * 0.8),   // giảm ~20%
                "musclegain" => (int)Math.Round(maintenanceCalories * 1.15), // tăng ~15%
                _ => (int)Math.Round(maintenanceCalories) // giữ dáng
            };
        }
    }
}