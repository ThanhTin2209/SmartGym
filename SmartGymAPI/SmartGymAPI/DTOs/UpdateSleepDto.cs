using System;

namespace SmartGymAPI.DTOs
{
    public class UpdateSleepDto
    {
        public DateTime? StartAt { get; set; }
        public DateTime? EndAt { get; set; }
        public string? Type { get; set; }
    }
}