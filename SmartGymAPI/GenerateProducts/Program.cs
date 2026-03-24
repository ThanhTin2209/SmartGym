using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using SmartGymAPI.Models;

Console.WriteLine("=== GENERATE 200 GYM PRODUCTS ===\n");

var products = new List<Product>();
int id = 1;

// Category 1: Thực phẩm bổ sung (40 products)
var supplements = new[]
{
    ("Whey Protein Isolate", 900000, 1500000, "Protein tinh khiết"),
    ("Whey Protein Concentrate", 600000, 1200000, "Protein cô đặc"),
    ("Mass Gainer", 800000, 1800000, "Tăng cân nhanh"),
    ("BCAA", 300000, 800000, "Amino acid"),
    ("Creatine", 250000, 600000, "Tăng sức mạnh"),
    ("Pre-Workout", 400000, 900000, "Năng lượng trước tập"),
    ("Glutamine", 350000, 700000, "Phục hồi cơ"),
    ("Vitamin Tổng Hợp", 200000, 500000, "Vitamin & khoáng chất")
};
foreach (var (name, minPrice, maxPrice, desc) in supplements)
{
    for (int i = 1; i <= 5; i++)
    {
        var sizes = new[] { "500g", "1kg", "2kg", "3kg", "5kg" };
        products.Add(new Product
        {
            Id = id++,
            CategoryId = 1,
            Name = $"{name} {sizes[i-1]}",
            Description = $"{desc} - Hỗ trợ tăng cơ giảm mỡ",
            Price = minPrice + (maxPrice - minPrice) * i / 5,
            Stock = 50 + i * 10,
            ImageUrl = "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
    }
}

// Category 2: Dụng cụ tập luyện (40 products)
var equipment = new[]
{
    ("Tạ Đơn", 200000, 1000000, "Tạ gang bọc cao su"),
    ("Tạ Đòn", 500000, 2000000, "Barbell chuyên nghiệp"),
    ("Dây Kháng Lực", 100000, 500000, "Resistance band"),
    ("Kettlebell", 300000, 800000, "Tạ bình Nga"),
    ("Ghế Tập Tạ", 1000000, 5000000, "Bench press"),
    ("Xà Đơn", 500000, 2000000, "Pull-up bar"),
    ("Bóng Tập", 200000, 600000, "Medicine ball"),
    ("TRX", 800000, 2000000, "Suspension training")
};
foreach (var (name, minPrice, maxPrice, desc) in equipment)
{
    for (int i = 1; i <= 5; i++)
    {
        var variants = new[] { "Cơ Bản", "Tiêu Chuẩn", "Cao Cấp", "Pro", "Elite" };
        products.Add(new Product
        {
            Id = id++,
            CategoryId = 2,
            Name = $"{name} {variants[i-1]}",
            Description = desc,
            Price = minPrice + (maxPrice - minPrice) * i / 5,
            Stock = 30 + i * 5,
            ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
    }
}

// Category 3: Trang phục thể thao (40 products)
var apparel = new[]
{
    ("Áo Thun Tập Gym Nam", 150000, 500000, "Vải thấm hút mồ hôi"),
    ("Áo Thun Tập Gym Nữ", 150000, 500000, "Vải co giãn 4 chiều"),
    ("Quần Short Tập Gym Nam", 200000, 600000, "Thoáng mát"),
    ("Quần Legging Nữ", 250000, 700000, "Nâng mông định hình"),
    ("Áo Tank Top", 120000, 400000, "Thoải mái vận động"),
    ("Quần Jogger", 300000, 800000, "Phong cách thể thao"),
    ("Giày Tập Gym", 500000, 2000000, "Đế chống trượt"),
    ("Áo Khoác Thể Thao", 400000, 1200000, "Giữ ấm sau tập")
};
foreach (var (name, minPrice, maxPrice, desc) in apparel)
{
    for (int i = 1; i <= 5; i++)
    {
        var sizes = new[] { "S", "M", "L", "XL", "XXL" };
        products.Add(new Product
        {
            Id = id++,
            CategoryId = 3,
            Name = $"{name} Size {sizes[i-1]}",
            Description = desc,
            Price = minPrice + (maxPrice - minPrice) * i / 5,
            Stock = 40 + i * 8,
            ImageUrl = "https://images.unsplash.com/photo-1556906781-9a412961c28c?w=400",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
    }
}

// Category 4: Phụ kiện (20 products)
var accessories = new[]
{
    ("Găng Tay Tập Gym", 100000, 400000, "Bảo vệ bàn tay"),
    ("Đai Lưng Tập Gym", 200000, 800000, "Hỗ trợ cột sống"),
    ("Băng Cổ Tay", 50000, 200000, "Bảo vệ cổ tay"),
    ("Băng Đầu Gối", 100000, 300000, "Hỗ trợ khớp gối")
};
foreach (var (name, minPrice, maxPrice, desc) in accessories)
{
    for (int i = 1; i <= 5; i++)
    {
        products.Add(new Product
        {
            Id = id++,
            CategoryId = 4,
            Name = $"{name} Loại {i}",
            Description = desc,
            Price = minPrice + (maxPrice - minPrice) * i / 5,
            Stock = 60 + i * 10,
            ImageUrl = "https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
    }
}

// Category 5: Thiết bị Cardio (20 products)
var cardio = new[]
{
    ("Máy Chạy Bộ", 5000000, 30000000, "Treadmill điện"),
    ("Xe Đạp Tập", 2000000, 15000000, "Exercise bike"),
    ("Máy Chèo Thuyền", 3000000, 20000000, "Rowing machine"),
    ("Máy Leo Núi", 8000000, 40000000, "Stepper machine")
};
foreach (var (name, minPrice, maxPrice, desc) in cardio)
{
    for (int i = 1; i <= 5; i++)
    {
        var models = new[] { "Cơ Bản", "Gia Đình", "Bán Chuyên", "Chuyên Nghiệp", "Thương Mại" };
        products.Add(new Product
        {
            Id = id++,
            CategoryId = 5,
            Name = $"{name} {models[i-1]}",
            Description = desc,
            Price = minPrice + (maxPrice - minPrice) * i / 5,
            Stock = 5 + i * 2,
            ImageUrl = "https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
    }
}

// Category 6: Yoga & Pilates (20 products)
var yoga = new[]
{
    ("Thảm Yoga", 150000, 800000, "Chống trượt cao cấp"),
    ("Yoga Block", 100000, 300000, "Gạch tập yoga"),
    ("Dây Tập Yoga", 80000, 250000, "Yoga strap"),
    ("Bóng Yoga", 200000, 600000, "Yoga ball")
};
foreach (var (name, minPrice, maxPrice, desc) in yoga)
{
    for (int i = 1; i <= 5; i++)
    {
        products.Add(new Product
        {
            Id = id++,
            CategoryId = 6,
            Name = $"{name} Cấp {i}",
            Description = desc,
            Price = minPrice + (maxPrice - minPrice) * i / 5,
            Stock = 50 + i * 10,
            ImageUrl = "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
    }
}

// Category 7: Dinh dưỡng thể thao (10 products)
var nutrition = new[]
{
    ("Thanh Protein Bar", 20000, 50000, "Bữa phụ tiện lợi"),
    ("Năng Lượng Gel", 15000, 40000, "Energy gel")
};
foreach (var (name, minPrice, maxPrice, desc) in nutrition)
{
    for (int i = 1; i <= 5; i++)
    {
        products.Add(new Product
        {
            Id = id++,
            CategoryId = 7,
            Name = $"{name} Vị {i}",
            Description = desc,
            Price = minPrice + (maxPrice - minPrice) * i / 5,
            Stock = 100 + i * 20,
            ImageUrl = "https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=400",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
    }
}

// Category 8: Đồ uống (5 products)
products.Add(new Product { Id = id++, CategoryId = 8, Name = "Bình Lắc Protein 500ml", Description = "Shaker bottle", Price = 80000, Stock = 100, ImageUrl = "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });
products.Add(new Product { Id = id++, CategoryId = 8, Name = "Bình Lắc Protein 700ml", Description = "Shaker bottle", Price = 120000, Stock = 100, ImageUrl = "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });
products.Add(new Product { Id = id++, CategoryId = 8, Name = "Bình Nước Thể Thao 1L", Description = "Sport bottle", Price = 100000, Stock = 150, ImageUrl = "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });
products.Add(new Product { Id = id++, CategoryId = 8, Name = "Bình Nước Giữ Nhiệt", Description = "Thermos bottle", Price = 250000, Stock = 80, ImageUrl = "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });
products.Add(new Product { Id = id++, CategoryId = 8, Name = "Isotonic 500ml", Description = "Nước bù khoáng", Price = 15000, Stock = 200, ImageUrl = "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });

// Category 9: Thiết bị gia đình (3 products)
products.Add(new Product { Id = id++, CategoryId = 9, Name = "Bộ Tạ Tay Gia Đình", Description = "Home dumbbell set", Price = 1500000, Stock = 20, ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });
products.Add(new Product { Id = id++, CategoryId = 9, Name = "Ghế Tập Bụng", Description = "Ab bench", Price = 800000, Stock = 15, ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });
products.Add(new Product { Id = id++, CategoryId = 9, Name = "Xà Kép Đa Năng", Description = "Dip station", Price = 1200000, Stock = 10, ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });

// Category 10: Sức khỏe & Phục hồi (2 products)
products.Add(new Product { Id = id++, CategoryId = 10, Name = "Foam Roller", Description = "Con lăn massage cơ", Price = 250000, Stock = 50, ImageUrl = "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });
products.Add(new Product { Id = id++, CategoryId = 10, Name = "Massage Ball", Description = "Bóng massage điểm", Price = 150000, Stock = 60, ImageUrl = "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400", IsActive = true, CreatedAt = DateTime.UtcNow });

Console.WriteLine($"Generated {products.Count} products!");

var json = JsonSerializer.Serialize(products, new JsonSerializerOptions { WriteIndented = false });
File.WriteAllText("ecommerce_products.json", json);

Console.WriteLine("✓ Saved to ecommerce_products.json");
Console.WriteLine($"\nTotal: {products.Count} products across 10 categories");
