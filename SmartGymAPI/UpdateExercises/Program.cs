using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;
using System.Text.Json;

// Simple console app to update exercises with Vietnamese names
var connectionString = "Server=ADMINISTRATOR\\MSSQLSERVER02;Database=SmartGymDB_V2;Trusted_Connection=True;Encrypt=False;TrustServerCertificate=True;MultipleActiveResultSets=true";

var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
optionsBuilder.UseSqlServer(connectionString);

using var context = new ApplicationDbContext(optionsBuilder.Options);

Console.WriteLine("Reading JSON file...");
var jsonText = File.ReadAllText("exercises_vietnamese.json");
var exercises = JsonSerializer.Deserialize<List<ExerciseTemplate>>(jsonText);

if (exercises == null || exercises.Count == 0)
{
    Console.WriteLine("ERROR: No exercises loaded from JSON!");
    return;
}

Console.WriteLine($"Loaded {exercises.Count} exercises from JSON");
Console.WriteLine($"First exercise: {exercises[0].Name}");

Console.WriteLine($"Updating {exercises.Count} exercises...");

// Load all existing exercises first, ordered by ID
var allExercises = await context.ExerciseTemplates.OrderBy(e => e.Id).ToListAsync();
Console.WriteLine($"Found {allExercises.Count} exercises in database");
Console.WriteLine($"First DB exercise ID: {allExercises[0].Id}, Name: {allExercises[0].Name}");
Console.WriteLine($"Last DB exercise ID: {allExercises[allExercises.Count-1].Id}");

int updated = 0;

// Update by index (first JSON exercise -> first DB exercise, etc.)
for (int i = 0; i < Math.Min(exercises.Count, allExercises.Count); i++)
{
    var ex = exercises[i];
    var existing = allExercises[i];
    
    existing.Name = ex.Name;
    existing.Category = ex.Category;
    existing.DurationSeconds = ex.DurationSeconds;
    existing.BaseMet = ex.BaseMet;
    existing.Intensity = ex.Intensity;
    existing.Level = ex.Level;
    updated++;
    
    if (updated % 50 == 0)
        Console.WriteLine($"Updated {updated} exercises...");
}

await context.SaveChangesAsync();
Console.WriteLine($"Successfully updated {updated} exercises!");
