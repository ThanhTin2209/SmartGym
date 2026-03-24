using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Identity;

namespace SmartGymAPI.Models
{
    public class GymCoinTransaction
    {
        [Key]
        public int Id { get; set; }

        public string UserId { get; set; } = string.Empty;
        
        [ForeignKey("UserId")]
        public IdentityUser? User { get; set; }

        public decimal Amount { get; set; } // Số coin (+ hoặc -)
        public string Type { get; set; } = "Earn"; // Earn, Spend
        public string Description { get; set; } = string.Empty; // "Tập luyện: Chạy bộ", "Mua bình nước"
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
