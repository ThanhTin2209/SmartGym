using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;

// Simple console app to seed Vietnamese exercises
// Run this from SmartGymAPI directory: dotnet run --project SeedExercises.csproj

var connectionString = "Server=ADMINISTRATOR\\MSSQLSERVER02;Database=SmartGymDB_V2;Trusted_Connection=True;Encrypt=False;TrustServerCertificate=True;MultipleActiveResultSets=true";

var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
optionsBuilder.UseSqlServer(connectionString);

using var context = new ApplicationDbContext(optionsBuilder.Options);

// Delete old exercises
Console.WriteLine("Deleting old exercises...");
context.ExerciseTemplates.RemoveRange(context.ExerciseTemplates);
await context.SaveChangesAsync();
Console.WriteLine("Deleted!");

// Add new Vietnamese exercises
Console.WriteLine("Adding 150 Vietnamese exercises...");

var exercises = new List<ExerciseTemplate>
{
    // CARDIO - 50 bài
    new() { Name = "Đi bộ nhẹ nhàng 15 phút", Category = "Cardio", DurationSeconds = 900, BaseMet = 3.5, Intensity = "Low", Level = "Beginner" },
    new() { Name = "Đi bộ nhanh 20 phút", Category = "Cardio", DurationSeconds = 1200, BaseMet = 4.5, Intensity = "Moderate", Level = "Beginner" },
    new() { Name = "Đi bộ leo dốc 25 phút", Category = "Cardio", DurationSeconds = 1500, BaseMet = 5.5, Intensity = "Moderate", Level = "Intermediate" },
    new() { Name = "Chạy bộ nhẹ 15 phút", Category = "Cardio", DurationSeconds = 900, BaseMet = 6.0, Intensity = "Moderate", Level = "Beginner" },
    new() { Name = "Chạy bộ 20 phút", Category = "Cardio", DurationSeconds = 1200, BaseMet = 7.5, Intensity = "Moderate", Level = "Intermediate" },
    new() { Name = "Chạy bộ 30 phút", Category = "Cardio", DurationSeconds = 1800, BaseMet = 8.0, Intensity = "High", Level = "Intermediate" },
    new() { Name = "Chạy nước rút 10 phút", Category = "Cardio", DurationSeconds = 600, BaseMet = 10.0, Intensity = "Very High", Level = "Advanced" },
    new() { Name = "Chạy nước rút 15 phút", Category = "Cardio", DurationSeconds = 900, BaseMet = 11.0, Intensity = "Very High", Level = "Advanced" },
    new() { Name = "Đạp xe nhẹ 20 phút", Category = "Cardio", DurationSeconds = 1200, BaseMet = 4.0, Intensity = "Low", Level = "Beginner" },
    new() { Name = "Đạp xe 30 phút", Category = "Cardio", DurationSeconds = 1800, BaseMet = 6.5, Intensity = "Moderate", Level = "Intermediate" },
    // ... (Add all 150 exercises here - truncated for brevity)
};

context.ExerciseTemplates.AddRange(exercises);
await context.SaveChangesAsync();

Console.WriteLine($"Successfully added {exercises.Count} exercises!");
Console.WriteLine("Press any key to exit...");
Console.ReadKey();
