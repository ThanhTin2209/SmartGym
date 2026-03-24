using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;

var connectionString = "Server=ADMINISTRATOR\\MSSQLSERVER02;Database=SmartGymDB_V2;Trusted_Connection=True;Encrypt=False;TrustServerCertificate=True;MultipleActiveResultSets=true";

var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
optionsBuilder.UseSqlServer(connectionString);

using var context = new ApplicationDbContext(optionsBuilder.Options);

Console.WriteLine("=== SEED E-COMMERCE DATA ===");

// Seed Categories
Console.WriteLine("\n[1/2] Seeding categories...");
var categoriesJson = File.ReadAllText("ecommerce_categories.json");
var categories = JsonSerializer.Deserialize<List<ProductCategory>>(categoriesJson);

foreach (var cat in categories!)
{
    // Check if category with same name exists
    var existing = await context.ProductCategories.FirstOrDefaultAsync(c => c.Name == cat.Name);
    if (existing == null)
    {
        cat.Id = 0; // Let DB auto-generate
        context.ProductCategories.Add(cat);
    }
}
await context.SaveChangesAsync();
Console.WriteLine($"✓ Seeded {categories.Count} categories");

// Seed Products
Console.WriteLine("\n[2/2] Seeding products...");
var productsJson = File.ReadAllText("ecommerce_products.json");
var products = JsonSerializer.Deserialize<List<Product>>(productsJson);

// Get category mapping (old Id -> new Id)
var categoryMap = new Dictionary<int, int>();
for (int i = 1; i <= 10; i++)
{
    var cat = await context.ProductCategories.Skip(i-1).FirstOrDefaultAsync();
    if (cat != null) categoryMap[i] = cat.Id;
}

foreach (var prod in products!)
{
    // Check if product exists
    var existing = await context.Products.FirstOrDefaultAsync(p => p.Name == prod.Name);
    if (existing == null)
    {
        prod.Id = 0; // Let DB auto-generate
        // Map to correct category Id
        if (categoryMap.ContainsKey(prod.CategoryId))
            prod.CategoryId = categoryMap[prod.CategoryId];
        
        context.Products.Add(prod);
    }
    else
    {
        // Update existing image if valid in JSON
        if (!string.IsNullOrEmpty(prod.ImageUrl) && prod.ImageUrl != existing.ImageUrl)
        {
            existing.ImageUrl = prod.ImageUrl;
            Console.WriteLine($"Updated image for: {existing.Name}");
        }
    }
}
await context.SaveChangesAsync();
Console.WriteLine($"✓ Seeded {products.Count} products");

Console.WriteLine("\n🎉 DONE! E-commerce data seeded successfully!");
