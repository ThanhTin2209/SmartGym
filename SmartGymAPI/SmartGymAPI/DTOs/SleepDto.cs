using System;

namespace SmartGymAPI.DTOs
{
    public class SleepDto
    {
        public DateTime StartAt { get; set; } // client should send ISO string; backend will convert to UTC
        public DateTime? EndAt { get; set; }  // optional
        public string? Type { get; set; }
    }
}