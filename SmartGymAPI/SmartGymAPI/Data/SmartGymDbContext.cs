using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Models;

namespace SmartGymAPI.Data
{
    public class ApplicationDbContext : IdentityDbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Khai báo các bảng trong database (DbSet)
        public DbSet<HealthProfile> HealthProfiles { get; set; }
        public DbSet<UserProfile> UserProfiles { get; set; }
        public DbSet<WaterIntake> WaterIntakes { get; set; }
        public DbSet<SleepRecord> SleepRecords { get; set; }
        public DbSet<NutritionRecord> NutritionRecords { get; set; }
        public DbSet<ExerciseRecord> ExerciseRecords { get; set; }

        // Thêm ExerciseTemplate
        public DbSet<ExerciseTemplate> ExerciseTemplates { get; set; }
        public DbSet<MealTemplate> MealTemplates { get; set; }

        // E-commerce tables
        public DbSet<ProductCategory> ProductCategories { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<CartItem> CartItems { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }

        // Gym Pack & Coin
        public DbSet<GymPackage> GymPackages { get; set; }
        public DbSet<GymCoinTransaction> GymCoinTransactions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure Decimal Precision
            modelBuilder.Entity<Product>()
                .Property(p => p.Price)
                .HasPrecision(18, 2);

            modelBuilder.Entity<Order>()
                .Property(o => o.TotalAmount)
                .HasPrecision(18, 2);

            modelBuilder.Entity<OrderItem>()
                .Property(oi => oi.Price)
                .HasPrecision(18, 2);

            // Seed 150 ExerciseTemplate tiếng Việt
            modelBuilder.Entity<ExerciseTemplate>().HasData(ExerciseSeedData.GetExercises());

            // Seed 100 MealTemplate mẫu
            modelBuilder.Entity<MealTemplate>().HasData(
                // 1-20: Đã có
                new MealTemplate { Id = 1, Name = "Ức gà luộc & Súp lơ", Category = "Lunch", Calories = 350, Protein = 40, Carbs = 10, Fat = 5, Description = "Ức gà luộc, súp lơ xanh luộc, ít muối." },
                new MealTemplate { Id = 2, Name = "Yến mạch & Chuối", Category = "Breakfast", Calories = 400, Protein = 12, Carbs = 60, Fat = 6, Description = "Yến mạch nấu sữa, topping chuối và mật ong." },
                new MealTemplate { Id = 3, Name = "Cá hồi áp chảo", Category = "Dinner", Calories = 500, Protein = 35, Carbs = 5, Fat = 25, Description = "Cá hồi áp chảo với măng tây." },
                new MealTemplate { Id = 4, Name = "Sinh tố Whey Protein", Category = "Post-workout", Calories = 250, Protein = 25, Carbs = 20, Fat = 3, Description = "1 muỗng whey, 1 quả chuối, nước." },
                new MealTemplate { Id = 5, Name = "Trứng luộc", Category = "Snack", Calories = 140, Protein = 12, Carbs = 1, Fat = 10, Description = "2 quả trứng gà luộc." },
                new MealTemplate { Id = 6, Name = "Cơm gạo lứt & Bò xào", Category = "Lunch", Calories = 600, Protein = 30, Carbs = 70, Fat = 15, Description = "1 bát cơm gạo lứt, 100g bò xào bông cải." },
                new MealTemplate { Id = 7, Name = "Salad Ức gà", Category = "Dinner", Calories = 300, Protein = 30, Carbs = 10, Fat = 10, Description = "Rau xà lách, cà chua, ức gà nướng, sốt mè rang." },
                new MealTemplate { Id = 8, Name = "Bánh mì đen & Bơ", Category = "Breakfast", Calories = 350, Protein = 8, Carbs = 40, Fat = 15, Description = "2 lát bánh mì đen, 1/2 quả bơ, hạt tiêu." },
                new MealTemplate { Id = 9, Name = "Sữa chua Hy Lạp", Category = "Snack", Calories = 120, Protein = 15, Carbs = 8, Fat = 0, Description = "1 hũ sữa chua Hy Lạp." },
                new MealTemplate { Id = 10, Name = "Táo & Bơ đậu phộng", Category = "Snack", Calories = 200, Protein = 5, Carbs = 25, Fat = 10, Description = "1 quả táo cắt lát, 1 thìa bơ đậu phộng." },
                new MealTemplate { Id = 11, Name = "Hạt hạnh nhân (30g)", Category = "Snack", Calories = 170, Protein = 6, Carbs = 6, Fat = 15, Description = "30g hạt hạnh nhân rang mộc." },
                new MealTemplate { Id = 12, Name = "Khoai lang luộc", Category = "Pre-workout", Calories = 150, Protein = 2, Carbs = 35, Fat = 0, Description = "1 củ khoai lang luộc vừa." },
                new MealTemplate { Id = 13, Name = "Phở bò (tái)", Category = "Breakfast", Calories = 450, Protein = 25, Carbs = 60, Fat = 12, Description = "Phở bò ít bánh, nhiều hành." },
                new MealTemplate { Id = 14, Name = "Cơm sườn bì chả", Category = "Lunch", Calories = 700, Protein = 25, Carbs = 80, Fat = 30, Description = "Cơm tấm sườn nướng, bì, chả trứng (ăn chừng mực)." },
                new MealTemplate { Id = 15, Name = "Bún bò Huế", Category = "Breakfast", Calories = 550, Protein = 30, Carbs = 65, Fat = 20, Description = "Bún bò Huế đầy đủ." },
                new MealTemplate { Id = 16, Name = "Protein Bar", Category = "Post-workout", Calories = 220, Protein = 20, Carbs = 25, Fat = 8, Description = "Thanh protein bar tiện lợi." },
                new MealTemplate { Id = 17, Name = "Nước cam ép", Category = "Snack", Calories = 110, Protein = 1, Carbs = 26, Fat = 0, Description = "1 ly nước cam ép nguyên chất." },
                new MealTemplate { Id = 18, Name = "Sandwich Cá ngừ", Category = "Lunch", Calories = 400, Protein = 25, Carbs = 40, Fat = 12, Description = "Bánh mì sandwich kẹp cá ngừ sốt mayo ít béo." },
                new MealTemplate { Id = 19, Name = "Mỳ Ý sốt bò băm", Category = "Dinner", Calories = 650, Protein = 25, Carbs = 90, Fat = 20, Description = "Mỳ Spaghetti sốt Bolognese." },
                new MealTemplate { Id = 20, Name = "Cháo gà", Category = "Dinner", Calories = 350, Protein = 20, Carbs = 40, Fat = 10, Description = "Cháo gà xé phay, hành ngò." },

                // 21-100: Mới thêm
                new MealTemplate { Id = 21, Name = "Bún chả (ít bún)", Category = "Lunch", Calories = 500, Protein = 25, Carbs = 60, Fat = 15, Description = "Bún chả Hà Nội, nhiều rau, nước mắm nhạt." },
                new MealTemplate { Id = 22, Name = "Gỏi cuốn tôm thịt", Category = "Snack", Calories = 180, Protein = 10, Carbs = 25, Fat = 3, Description = "3 cuốn gỏi tôm thịt, chấm tương đen." },
                new MealTemplate { Id = 23, Name = "Cơm rang dưa bò", Category = "Lunch", Calories = 750, Protein = 25, Carbs = 90, Fat = 30, Description = "Cơm rang dưa chua, thịt bò, một chút dầu mỡ." },
                new MealTemplate { Id = 24, Name = "Miến gà trộn", Category = "Breakfast", Calories = 400, Protein = 25, Carbs = 50, Fat = 10, Description = "Miến trộn thịt gà xé, rau thơm, lạc rang." },
                new MealTemplate { Id = 25, Name = "Bánh mì ốp la", Category = "Breakfast", Calories = 380, Protein = 15, Carbs = 40, Fat = 18, Description = "1 bánh mì, 2 trứng ốp la, dưa chuột." },
                new MealTemplate { Id = 26, Name = "Sữa đậu nành", Category = "Snack", Calories = 150, Protein = 8, Carbs = 12, Fat = 6, Description = "1 ly sữa đậu nành nóng, ít đường." },
                new MealTemplate { Id = 27, Name = "Canh chua cá lóc", Category = "Dinner", Calories = 300, Protein = 25, Carbs = 10, Fat = 12, Description = "Canh chua cá lóc, ăn kèm rau sống." },
                new MealTemplate { Id = 28, Name = "Đậu phụ sốt cà chua", Category = "Dinner", Calories = 250, Protein = 12, Carbs = 10, Fat = 15, Description = "2 bìa đậu phụ sốt cà chua, hành lá." },
                new MealTemplate { Id = 29, Name = "Rau muống xào tỏi", Category = "Dinner", Calories = 120, Protein = 3, Carbs = 5, Fat = 10, Description = "1 đĩa rau muống xào tỏi." },
                new MealTemplate { Id = 30, Name = "Thịt kho tàu (2 miếng)", Category = "Lunch", Calories = 450, Protein = 20, Carbs = 5, Fat = 35, Description = "Thịt ba chỉ kho trứng, ăn chừng mực." },
                new MealTemplate { Id = 31, Name = "Súp cua", Category = "Snack", Calories = 200, Protein = 10, Carbs = 20, Fat = 5, Description = "1 chén súp cua nóng hổi." },
                new MealTemplate { Id = 32, Name = "Nem nướng", Category = "Lunch", Calories = 550, Protein = 25, Carbs = 60, Fat = 25, Description = "Nem nướng Nha Trang cuốn bánh tráng." },
                new MealTemplate { Id = 33, Name = "Bánh cuốn Thanh Trì", Category = "Breakfast", Calories = 400, Protein = 10, Carbs = 60, Fat = 12, Description = "Bánh cuốn không nhân, chả quế." },
                new MealTemplate { Id = 34, Name = "Xôi xéo", Category = "Breakfast", Calories = 600, Protein = 15, Carbs = 80, Fat = 25, Description = "Xôi xéo mỡ hành, đậu xanh, ruốc." },
                new MealTemplate { Id = 35, Name = "Chè hạt sen", Category = "Snack", Calories = 250, Protein = 5, Carbs = 50, Fat = 2, Description = "Chè hạt sen long nhãn, ngọt thanh." },
                new MealTemplate { Id = 36, Name = "Nước dừa tươi", Category = "Pre-workout", Calories = 60, Protein = 1, Carbs = 15, Fat = 0, Description = "1 quả dừa tươi." },
                new MealTemplate { Id = 37, Name = "Chuối luộc", Category = "Pre-workout", Calories = 100, Protein = 1, Carbs = 25, Fat = 0, Description = "2 quả chuối sáp luộc." },
                new MealTemplate { Id = 38, Name = "Ngô luộc", Category = "Snack", Calories = 150, Protein = 4, Carbs = 30, Fat = 2, Description = "1 bắp ngô nếp luộc." },
                new MealTemplate { Id = 39, Name = "Sữa tươi không đường", Category = "Snack", Calories = 120, Protein = 8, Carbs = 10, Fat = 6, Description = "1 hộp sữa tươi Vinamilk không đường." },
                new MealTemplate { Id = 40, Name = "Granola & Sữa chua", Category = "Breakfast", Calories = 350, Protein = 12, Carbs = 45, Fat = 12, Description = "Ngũ cốc Granola ăn kèm sữa chua." },
                new MealTemplate { Id = 41, Name = "Bơ dầm sữa đặc", Category = "Snack", Calories = 350, Protein = 4, Carbs = 40, Fat = 20, Description = "Món tráng miệng, hạn chế ăn nhiều." },
                new MealTemplate { Id = 42, Name = "Cà phê sữa đá", Category = "Pre-workout", Calories = 250, Protein = 4, Carbs = 35, Fat = 10, Description = "Năng lượng tỉnh táo buổi sáng." },
                new MealTemplate { Id = 43, Name = "Bò bít tết (150g)", Category = "Dinner", Calories = 450, Protein = 40, Carbs = 0, Fat = 30, Description = "Bò bít tết áp chảo, kèm salad." },
                new MealTemplate { Id = 44, Name = "Mực xào cần tỏi", Category = "Lunch", Calories = 250, Protein = 20, Carbs = 10, Fat = 10, Description = "Mực tươi xào cần tây, tỏi tây." },
                new MealTemplate { Id = 45, Name = "Tôm hấp bia", Category = "Dinner", Calories = 150, Protein = 25, Carbs = 2, Fat = 2, Description = "200g tôm sú hấp bia." },
                new MealTemplate { Id = 46, Name = "Gà nướng mật ong", Category = "Lunch", Calories = 400, Protein = 30, Carbs = 15, Fat = 20, Description = "Đùi gà nướng mật ong." },
                new MealTemplate { Id = 47, Name = "Lẩu thái (1 bát)", Category = "Dinner", Calories = 500, Protein = 25, Carbs = 40, Fat = 25, Description = "Bún, tôm, mực, rau, nước lẩu." },
                new MealTemplate { Id = 48, Name = "Bánh bao nhân thịt", Category = "Breakfast", Calories = 300, Protein = 10, Carbs = 40, Fat = 8, Description = "1 chiếc bánh bao to." },
                new MealTemplate { Id = 49, Name = "Cháo yến mạch ức gà", Category = "Dinner", Calories = 300, Protein = 25, Carbs = 30, Fat = 5, Description = "Cháo yến mạch nấu ức gà băm." },
                new MealTemplate { Id = 50, Name = "Sushi tổng hợp", Category = "Lunch", Calories = 450, Protein = 20, Carbs = 60, Fat = 10, Description = "6 miếng sushi cá hồi, tôm." },
                new MealTemplate { Id = 51, Name = "Sashimi Cá hồi", Category = "Dinner", Calories = 250, Protein = 30, Carbs = 0, Fat = 15, Description = "100g cá hồi tươi sống." },
                new MealTemplate { Id = 52, Name = "Kimbap chiên", Category = "Snack", Calories = 400, Protein = 10, Carbs = 50, Fat = 18, Description = "Cơm cuộn rong biển tẩm bột chiên." },
                new MealTemplate { Id = 53, Name = "Tokbokki", Category = "Snack", Calories = 450, Protein = 8, Carbs = 90, Fat = 5, Description = "Bánh gạo cay Hàn Quốc." },
                new MealTemplate { Id = 54, Name = "Mì tương đen", Category = "Lunch", Calories = 600, Protein = 20, Carbs = 85, Fat = 15, Description = "Mì Jajangmyeon kèm củ cải muối." },
                new MealTemplate { Id = 55, Name = "Pizza (1 lát)", Category = "Lunch", Calories = 300, Protein = 12, Carbs = 35, Fat = 12, Description = "Pizza bò hoặc hải sản đế dày." },
                new MealTemplate { Id = 56, Name = "Hamburger Bò", Category = "Lunch", Calories = 500, Protein = 25, Carbs = 45, Fat = 25, Description = "Burger bò phô mai, rau xà lách." },
                new MealTemplate { Id = 57, Name = "Gà rán (1 miếng)", Category = "Lunch", Calories = 350, Protein = 20, Carbs = 20, Fat = 20, Description = "Ức gà hoặc đùi gà tẩm bột chiên giòn." },
                new MealTemplate { Id = 58, Name = "Khoai tây chiên", Category = "Snack", Calories = 350, Protein = 4, Carbs = 50, Fat = 15, Description = "1 phần khoai tây chiên vừa." },
                new MealTemplate { Id = 59, Name = "Bánh Crepe chuối", Category = "Snack", Calories = 250, Protein = 5, Carbs = 35, Fat = 10, Description = "Bánh kếp nhân chuối socola." },
                new MealTemplate { Id = 60, Name = "Trà sữa (50% đường)", Category = "Snack", Calories = 350, Protein = 2, Carbs = 60, Fat = 10, Description = "Trà sữa trân châu đường đen." },
                new MealTemplate { Id = 61, Name = "Sữa hạt điều", Category = "Snack", Calories = 180, Protein = 6, Carbs = 10, Fat = 14, Description = "Sữa hạt điều nguyên chất." },
                new MealTemplate { Id = 62, Name = "Smoothie Xanh", Category = "Breakfast", Calories = 200, Protein = 5, Carbs = 40, Fat = 2, Description = "Cải bó xôi, chuối, táo, nước dừa." },
                new MealTemplate { Id = 63, Name = "Bánh giò", Category = "Breakfast", Calories = 350, Protein = 12, Carbs = 40, Fat = 15, Description = "Bánh giò nóng nhân thịt mộc nhĩ." },
                new MealTemplate { Id = 64, Name = "Chè đậu đen", Category = "Snack", Calories = 250, Protein = 8, Carbs = 50, Fat = 2, Description = "Chè đậu đen ít đường, nước cốt dừa." },
                new MealTemplate { Id = 65, Name = "Tào phớ", Category = "Snack", Calories = 150, Protein = 8, Carbs = 25, Fat = 2, Description = "Tào phớ nước đường gừng." },
                new MealTemplate { Id = 66, Name = "Lạc luộc (100g)", Category = "Snack", Calories = 550, Protein = 25, Carbs = 20, Fat = 45, Description = "Lạc (đậu phộng) luộc cả vỏ." },
                new MealTemplate { Id = 67, Name = "Nem chua rán", Category = "Snack", Calories = 400, Protein = 20, Carbs = 20, Fat = 25, Description = "5 chiếc nem chua rán." },
                new MealTemplate { Id = 68, Name = "Phô mai que", Category = "Snack", Calories = 300, Protein = 10, Carbs = 20, Fat = 18, Description = "3 que phô mai chiên." },
                new MealTemplate { Id = 69, Name = "Chân gà sả tắc", Category = "Snack", Calories = 250, Protein = 20, Carbs = 5, Fat = 15, Description = "Chân gà ngâm sả tắc chua cay." },
                new MealTemplate { Id = 70, Name = "Nộm bò khô", Category = "Snack", Calories = 200, Protein = 15, Carbs = 20, Fat = 5, Description = "Nộm đu đủ bò khô, lạc rang." },
                new MealTemplate { Id = 71, Name = "Bánh tráng trộn", Category = "Snack", Calories = 300, Protein = 5, Carbs = 45, Fat = 10, Description = "Bánh tráng, xoài, trứng cút, bò khô." },
                new MealTemplate { Id = 72, Name = "Cơm cháy chà bông", Category = "Snack", Calories = 400, Protein = 10, Carbs = 50, Fat = 15, Description = "1 gói cơm cháy chà bông." },
                new MealTemplate { Id = 73, Name = "Hoa quả dầm", Category = "Snack", Calories = 250, Protein = 5, Carbs = 50, Fat = 5, Description = "Các loại trái cây trộn sữa chua." },
                new MealTemplate { Id = 74, Name = "Chả rươi", Category = "Lunch", Calories = 400, Protein = 25, Carbs = 10, Fat = 25, Description = "Món đặc sản chả rươi thơm ngon." },
                new MealTemplate { Id = 75, Name = "Canh măng vịt", Category = "Dinner", Calories = 450, Protein = 25, Carbs = 10, Fat = 30, Description = "Canh măng nấu chân/cổ cánh vịt." },
                new MealTemplate { Id = 76, Name = "Bún đậu mắm tôm", Category = "Lunch", Calories = 700, Protein = 35, Carbs = 80, Fat = 35, Description = "Bún, đậu rán, chả cốm, thịt chân giò." },
                new MealTemplate { Id = 77, Name = "Chả cá Lã Vọng", Category = "Dinner", Calories = 500, Protein = 30, Carbs = 20, Fat = 30, Description = "Cá lăng nướng, thì là, hành, mắm tôm." },
                new MealTemplate { Id = 78, Name = "Bánh xèo", Category = "Lunch", Calories = 600, Protein = 20, Carbs = 70, Fat = 25, Description = "2 cái bánh xèo nhân tôm thịt." },
                new MealTemplate { Id = 79, Name = "Bánh khọt", Category = "Snack", Calories = 400, Protein = 15, Carbs = 50, Fat = 15, Description = "5 cái bánh khọt tôm." },
                new MealTemplate { Id = 80, Name = "Lẩu mắm", Category = "Dinner", Calories = 550, Protein = 30, Carbs = 40, Fat = 25, Description = "Lẩu mắm miền Tây, nhiều rau." },
                new MealTemplate { Id = 81, Name = "Cơm hến", Category = "Lunch", Calories = 400, Protein = 15, Carbs = 60, Fat = 10, Description = "Cơm hến Huế cay nồng." },
                new MealTemplate { Id = 82, Name = "Mì Quảng", Category = "Breakfast", Calories = 450, Protein = 20, Carbs = 55, Fat = 15, Description = "Mì Quảng tôm thịt trứng." },
                new MealTemplate { Id = 83, Name = "Cao lầu", Category = "Lunch", Calories = 500, Protein = 25, Carbs = 60, Fat = 15, Description = "Cao lầu Hội An, thịt xá xíu." },
                new MealTemplate { Id = 84, Name = "Bánh mì Hội An", Category = "Breakfast", Calories = 450, Protein = 20, Carbs = 55, Fat = 18, Description = "Bánh mì thập cẩm đặc biệt." },
                new MealTemplate { Id = 85, Name = "Sữa bí đỏ", Category = "Snack", Calories = 200, Protein = 5, Carbs = 30, Fat = 6, Description = "Sữa bí đỏ hạt sen." },
                new MealTemplate { Id = 86, Name = "Nước ép cần tây", Category = "Post-workout", Calories = 50, Protein = 1, Carbs = 10, Fat = 0, Description = "Detox cơ thể, giảm cân." },
                new MealTemplate { Id = 87, Name = "Salad Nga", Category = "Dinner", Calories = 350, Protein = 8, Carbs = 25, Fat = 20, Description = "Khoai tây, cà rốt, đậu hà lan, sốt mayonaise." },
                new MealTemplate { Id = 88, Name = "Bò lúc lắc", Category = "Dinner", Calories = 500, Protein = 30, Carbs = 10, Fat = 35, Description = "Bò lúc lắc khoai tây chiên." },
                new MealTemplate { Id = 89, Name = "Cánh gà chiên nước mắm", Category = "Lunch", Calories = 550, Protein = 25, Carbs = 10, Fat = 40, Description = "3 cánh gà chiên mắm đậm đà." },
                new MealTemplate { Id = 90, Name = "Mướp đắng nhồi thịt", Category = "Dinner", Calories = 200, Protein = 15, Carbs = 10, Fat = 8, Description = "Canh mướp đắng nhồi thịt nạc vai." },
                new MealTemplate { Id = 91, Name = "Trứng vịt lộn", Category = "Snack", Calories = 180, Protein = 14, Carbs = 2, Fat = 12, Description = "1 quả trứng vịt lộn, rau răm." },
                new MealTemplate { Id = 92, Name = "Chè trôi nước", Category = "Snack", Calories = 300, Protein = 5, Carbs = 50, Fat = 8, Description = "2 viên chè trôi nước cốt dừa." },
                new MealTemplate { Id = 93, Name = "Sữa ngô", Category = "Snack", Calories = 150, Protein = 4, Carbs = 25, Fat = 5, Description = "Sữa ngô non thơm mát." },
                new MealTemplate { Id = 94, Name = "Bánh nếp/Bánh chưng rán", Category = "Breakfast", Calories = 500, Protein = 15, Carbs = 70, Fat = 20, Description = "1 góc bánh chưng rán giòn." },
                new MealTemplate { Id = 95, Name = "Măng tây xào tôm", Category = "Dinner", Calories = 200, Protein = 20, Carbs = 5, Fat = 10, Description = "Măng tây xanh xào tôm nõn." },
                new MealTemplate { Id = 96, Name = "Cải thìa xào nấm", Category = "Dinner", Calories = 100, Protein = 5, Carbs = 10, Fat = 5, Description = "Món chay thanh đạm." },
                new MealTemplate { Id = 97, Name = "Đậu que xào thịt bò", Category = "Lunch", Calories = 350, Protein = 25, Carbs = 10, Fat = 20, Description = "Đậu que giòn ngọt xào thịt bò." },
                new MealTemplate { Id = 98, Name = "Canh bí đỏ thịt băm", Category = "Dinner", Calories = 150, Protein = 10, Carbs = 20, Fat = 5, Description = "Canh bí đỏ dinh dưỡng." },
                new MealTemplate { Id = 99, Name = "Cá kho tộ", Category = "Lunch", Calories = 350, Protein = 30, Carbs = 5, Fat = 20, Description = "Cá lóc hoặc cá ba sa kho tộ." },
                new MealTemplate { Id = 100, Name = "Canh cua rau đay", Category = "Dinner", Calories = 150, Protein = 10, Carbs = 5, Fat = 8, Description = "Canh cua đồng ăn với cà pháo." }
            );

            // --- SEED E-COMMERCE DATA ---
            
            // 1. Categories
            modelBuilder.Entity<ProductCategory>().HasData(
                new ProductCategory { Id = 1, Name = "Dụng cụ tập luyện", Description = "Tạ, thảm, dây kháng lực...", ImageUrl = "https://example.com/gear.jpg" },
                new ProductCategory { Id = 2, Name = "Thực phẩm bổ sung", Description = "Whey, BCAA, Pre-workout...", ImageUrl = "https://example.com/supp.jpg" },
                new ProductCategory { Id = 3, Name = "Trang phục nam", Description = "Áo gym, quần short nam...", ImageUrl = "https://example.com/men.jpg" },
                new ProductCategory { Id = 4, Name = "Trang phục nữ", Description = "Bra, Legging nữ...", ImageUrl = "https://example.com/women.jpg" },
                new ProductCategory { Id = 5, Name = "Phụ kiện", Description = "Bình nước, găng tay...", ImageUrl = "https://example.com/acc.jpg" }
            );

            // 2. Products
            modelBuilder.Entity<Product>().HasData(
                // Dụng cụ
                new Product { Id = 1, CategoryId = 1, Name = "Tạ đơn Hex 5kg", Description = "Tạ tay bọc cao su 5kg", Price = 150000, Stock = 20, ImageUrl = "https://example.com/ta5kg.jpg" },
                new Product { Id = 2, CategoryId = 1, Name = "Thảm Yoga TPE", Description = "Thảm tập chống trượt 6mm", Price = 250000, Stock = 50, ImageUrl = "https://example.com/tham.jpg" },
                
                // TPBS
                new Product { Id = 3, CategoryId = 2, Name = "Whey Gold Standard 5lbs", Description = "Sữa tăng cơ vị Chocolate", Price = 1850000, Stock = 10, ImageUrl = "https://example.com/whey.jpg" },
                new Product { Id = 4, CategoryId = 2, Name = "Creatine Monohydrate", Description = "Hũ 300g không mùi", Price = 450000, Stock = 15, ImageUrl = "https://example.com/creatine.jpg" },

                // Quần áo
                new Product { Id = 5, CategoryId = 3, Name = "Áo Thun Gym Shark", Description = "Vải thun lạnh co giãn", Price = 200000, Stock = 30, ImageUrl = "https://example.com/shirt.jpg" },
                new Product { Id = 6, CategoryId = 4, Name = "Quần Legging Lululemon", Description = "Quần tập yoga cao cấp", Price = 500000, Stock = 20, ImageUrl = "https://example.com/leg.jpg" },

                // Phụ kiện
                new Product { Id = 7, CategoryId = 5, Name = "Bình nước Shaker", Description = "Bình lắc 500ml", Price = 90000, Stock = 100, ImageUrl = "https://example.com/shaker.jpg" },
                new Product { Id = 8, CategoryId = 5, Name = "Găng tay tập Gym", Description = "Bảo vệ lòng bàn tay", Price = 120000, Stock = 40, ImageUrl = "https://example.com/glove.jpg" }
            );

            // 3. Gym Packages
            modelBuilder.Entity<GymPackage>().HasData(
                new GymPackage { Id = 1, Name = "Gói 1 Tháng", Description = "Tập luyện không giới hạn 1 tháng", Price = 300000, DurationMonths = 1, ImageUrl = "https://example.com/pack1.jpg" },
                new GymPackage { Id = 2, Name = "Gói 3 Tháng", Description = "Tiết kiệm hơn, tặng 1 tuần", Price = 800000, DurationMonths = 3, ImageUrl = "https://example.com/pack3.jpg" },
                new GymPackage { Id = 3, Name = "Gói 1 Năm", Description = "Cam kết dài hạn, tặng 1 tháng", Price = 3000000, DurationMonths = 12, ImageUrl = "https://example.com/pack12.jpg" }
            );
    }
}
}