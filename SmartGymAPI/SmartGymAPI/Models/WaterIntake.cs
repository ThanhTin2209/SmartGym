using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Identity;

namespace SmartGymAPI.Models
{
    public class WaterIntake
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [ForeignKey("UserId")]
        public IdentityUser? User { get; set; }  // Dùng IdentityUser mặc định

        [Required]
        public double Amount { get; set; }

        public DateTime Date { get; set; } = DateTime.UtcNow;
    }
}
