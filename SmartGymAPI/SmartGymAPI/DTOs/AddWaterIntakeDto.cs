using System;

namespace SmartGymAPI.DTOs
{
    public class AddWaterIntakeDto
    {
        public double Amount { get; set; }
        public DateTime? Date { get; set; } // optional: nếu client gửi sẽ dùng, nếu không thì backend dùng DateTime.UtcNow
    }
}