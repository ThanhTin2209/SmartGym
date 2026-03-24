using SmartGymAPI.Models;

namespace SmartGymAPI.Data
{
    public static class EcommerceSeedData
    {
        public static ProductCategory[] GetCategories()
        {
            return new[]
            {
                new ProductCategory { Id = 1, Name = "Thực phẩm bổ sung", Description = "Whey protein, mass gainer, vitamin", ImageUrl = "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400", IsActive = true },
                new ProductCategory { Id = 2, Name = "Dụng cụ tập luyện", Description = "Tạ, dây kháng lực, máy tập", ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400", IsActive = true },
                new ProductCategory { Id = 3, Name = "Trang phục thể thao", Description = "Áo, quần, giày tập gym", ImageUrl = "https://images.unsplash.com/photo-1556906781-9a412961c28c?w=400", IsActive = true },
                new ProductCategory { Id = 4, Name = "Phụ kiện tập luyện", Description = "Găng tay, đai lưng, băng cổ tay", ImageUrl = "https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400", IsActive = true },
                new ProductCategory { Id = 5, Name = "Thiết bị Cardio", Description = "Máy chạy bộ, xe đạp tập", ImageUrl = "https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400", IsActive = true },
                new ProductCategory { Id = 6, Name = "Yoga & Pilates", Description = "Thảm yoga, block, dây tập", ImageUrl = "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400", IsActive = true },
                new ProductCategory { Id = 7, Name = "Dinh dưỡng thể thao", Description = "Năng lượng, phục hồi, giảm cân", ImageUrl = "https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=400", IsActive = true },
                new ProductCategory { Id = 8, Name = "Đồ uống thể thao", Description = "Bình lắc, bình nước, isotonic", ImageUrl = "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400", IsActive = true },
                new ProductCategory { Id = 9, Name = "Thiết bị gia đình", Description = "Dụng cụ tập tại nhà", ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400", IsActive = true },
                new ProductCategory { Id = 10, Name = "Sức khỏe & Phục hồi", Description = "Massage, foam roller, băng dính", ImageUrl = "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400", IsActive = true }
            };
        }

        public static Product[] GetProducts()
        {
            return new[]
            {
                // Category 1: Thực phẩm bổ sung (40 sản phẩm)
                new Product { Id = 1, CategoryId = 1, Name = "Whey Protein Isolate 2kg", Description = "Protein tinh khiết 90%, hỗ trợ tăng cơ", Price = 1200000, Stock = 50, ImageUrl = "https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=400" },
                new Product { Id = 2, CategoryId = 1, Name = "Mass Gainer 5kg", Description = "Tăng cân nhanh cho người gầy", Price = 1500000, Stock = 30, ImageUrl = "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400" },
                new Product { Id = 3, CategoryId = 1, Name = "BCAA 2:1:1 500g", Description = "Amino acid chống dị hóa cơ", Price = 450000, Stock = 100, ImageUrl = "https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=400" },
                new Product { Id = 4, CategoryId = 1, Name = "Creatine Monohydrate 300g", Description = "Tăng sức mạnh và sức bền", Price = 350000, Stock = 80, ImageUrl = "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400" },
                new Product { Id = 5, CategoryId = 1, Name = "Pre-Workout Explosive", Description = "Tăng năng lượng trước tập", Price = 550000, Stock = 60, ImageUrl = "https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=400" },
                
                // Category 2: Dụng cụ tập luyện (40 sản phẩm)  
                new Product { Id = 41, CategoryId = 2, Name = "Tạ đơn 10kg (đôi)", Description = "Tạ gang bọc cao su", Price = 450000, Stock = 40, ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400" },
                new Product { Id = 42, CategoryId = 2, Name = "Tạ đơn 20kg (đôi)", Description = "Tạ gang chuyên nghiệp", Price = 850000, Stock = 25, ImageUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400" },
                
                // Tôi sẽ tạo file JSON đầy đủ 200 sản phẩm...
            };
        }
    }
}
