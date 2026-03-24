namespace SmartGymAPI.DTOs
{
    public class ProgressResponseDto
    {
        public string Range { get; set; } = "week";
        public double Percent { get; set; }
        public double Actual { get; set; }
        public double Target { get; set; }
        public string Unit { get; set; } = "minutes";
        public string Status { get; set; } = "OnTrack";
    }
}