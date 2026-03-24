using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SmartGymAPI.Models
{
    public class UserProfile
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey("User")]
        public string UserId { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Range(10, 100)]
        public int Age { get; set; }

        [Required]
        public string Gender { get; set; } = string.Empty; // "Nam" | "Nữ" | "Khác"

        [Range(30, 300)]
        public double Weight { get; set; } // kg

        [Range(100, 250)]
        public double Height { get; set; } // cm

        [MaxLength(50)]
        public string Goal { get; set; } = string.Empty; // "Giảm cân", "Tăng cơ", "Giữ dáng"

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
