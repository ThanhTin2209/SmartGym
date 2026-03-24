using System;
using System.ComponentModel.DataAnnotations;

namespace SmartGymAPI.Models
{
    public class SleepRecord
    {
        [Key]
        public int Id { get; set; }

        public string UserId { get; set; } = string.Empty;

        // Stored in UTC
        public DateTime StartAt { get; set; }

        // Stored in UTC, nullable (open record if null)
        public DateTime? EndAt { get; set; }

        // cached duration in minutes (0 if EndAt null)
        public int DurationMinutes { get; set; }

        // optional: "Night" | "Nap" | other
        public string Type { get; set; } = "Night";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}