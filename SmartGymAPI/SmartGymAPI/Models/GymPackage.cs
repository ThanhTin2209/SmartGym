using System.ComponentModel.DataAnnotations;

namespace SmartGymAPI.Models
{
    public class GymPackage
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty; // Ví dụ: "Gói 1 Tháng"
        public string Description { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public int DurationMonths { get; set; } // Thời hạn (tháng)
        public string ImageUrl { get; set; } = string.Empty;
    }
}
