namespace SmartGymAPI.Utils
{
    /// <summary>
    /// Lớp tiện ích sức khỏe: chứa các hàm tính toán liên quan đến BMI.
    /// </summary>
    public static class HealthUtils
    {
        /// <summary>
        /// Hàm tính chỉ số BMI từ chiều cao (cm) và cân nặng (kg).
        /// </summary>
        /// <param name="heightCm">Chiều cao tính bằng cm</param>
        /// <param name="weightKg">Cân nặng tính bằng kg</param>
        /// <returns>Giá trị BMI (làm tròn 1 chữ số thập phân)</returns>
        public static double TinhBmi(double heightCm, double weightKg)
        {
            if (heightCm <= 0) return 0;
            var h = heightCm / 100.0;
            var bmi = weightKg / (h * h);
            return Math.Round(bmi, 1);
        }

        /// <summary>
        /// Hàm phân loại BMI theo chuẩn WHO.
        /// </summary>
        /// <param name="bmi">Giá trị BMI</param>
        /// <returns>Chuỗi mô tả tình trạng cơ thể</returns>
        public static string PhanLoaiBmi(double bmi)
        {
            if (bmi <= 0) return "Không xác định";
            if (bmi < 18.5) return "Gầy (thiếu cân)";
            if (bmi < 25) return "Bình thường";
            if (bmi < 30) return "Thừa cân";
            return "Béo phì";
        }
    }
}