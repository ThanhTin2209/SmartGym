using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace SmartGymAPI.Migrations
{
    /// <inheritdoc />
    public partial class SyncSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AspNetRoles",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUsers",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedUserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedEmail = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    EmailConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SecurityStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumberConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    TwoFactorEnabled = table.Column<bool>(type: "bit", nullable: false),
                    LockoutEnd = table.Column<DateTimeOffset>(type: "datetimeoffset", nullable: true),
                    LockoutEnabled = table.Column<bool>(type: "bit", nullable: false),
                    AccessFailedCount = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUsers", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ExerciseRecords",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ExerciseName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Category = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DurationSeconds = table.Column<int>(type: "int", nullable: false),
                    Sets = table.Column<int>(type: "int", nullable: true),
                    Reps = table.Column<int>(type: "int", nullable: true),
                    WeightKg = table.Column<double>(type: "float", nullable: true),
                    CaloriesBurned = table.Column<double>(type: "float", nullable: true),
                    CaloriesSource = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    WeightUsedForCalories = table.Column<double>(type: "float", nullable: true),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExerciseRecords", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ExerciseTemplates",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Category = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DurationSeconds = table.Column<int>(type: "int", nullable: false),
                    Intensity = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    BaseMet = table.Column<double>(type: "float", nullable: false),
                    Level = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExerciseTemplates", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "HealthProfiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Age = table.Column<int>(type: "int", nullable: false),
                    Height = table.Column<double>(type: "float", nullable: false),
                    Weight = table.Column<double>(type: "float", nullable: false),
                    Gender = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Goal = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Bmi = table.Column<double>(type: "float", nullable: false),
                    ActivityLevel = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Level = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DailyCalorieGoal = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HealthProfiles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MealTemplates",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Category = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Calories = table.Column<int>(type: "int", nullable: false),
                    Protein = table.Column<double>(type: "float", nullable: false),
                    Carbs = table.Column<double>(type: "float", nullable: false),
                    Fat = table.Column<double>(type: "float", nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DietType = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MealTemplates", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "NutritionRecords",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MealType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Calories = table.Column<int>(type: "int", nullable: false),
                    Protein = table.Column<double>(type: "float", nullable: false),
                    Carbs = table.Column<double>(type: "float", nullable: false),
                    Fat = table.Column<double>(type: "float", nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false),
                    MealSlot = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ConsumedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NutritionRecords", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ProductCategories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductCategories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SleepRecords",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    StartAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    Type = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SleepRecords", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "UserProfiles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Age = table.Column<int>(type: "int", nullable: false),
                    Gender = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Weight = table.Column<double>(type: "float", nullable: false),
                    Height = table.Column<double>(type: "float", nullable: false),
                    Goal = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserProfiles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AspNetRoleClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoleClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserLogins",
                columns: table => new
                {
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderKey = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderDisplayName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserLogins", x => new { x.LoginProvider, x.ProviderKey });
                    table.ForeignKey(
                        name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserRoles",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    RoleId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserTokens",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserTokens", x => new { x.UserId, x.LoginProvider, x.Name });
                    table.ForeignKey(
                        name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    TotalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ShippingAddress = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Orders_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WaterIntakes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Amount = table.Column<double>(type: "float", nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WaterIntakes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WaterIntakes_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CategoryId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Stock = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Products_ProductCategories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "ProductCategories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CartItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    AddedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CartItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CartItems_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CartItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrderItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    ProductName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_OrderItems_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "ExerciseTemplates",
                columns: new[] { "Id", "BaseMet", "Category", "DurationSeconds", "Intensity", "Level", "Name" },
                values: new object[,]
                {
                    { 1, 3.5, "Cardio", 900, "Low", "Beginner", "Đi bộ nhẹ nhàng 15 phút" },
                    { 2, 4.5, "Cardio", 1200, "Moderate", "Beginner", "Đi bộ nhanh 20 phút" },
                    { 3, 5.5, "Cardio", 1500, "Moderate", "Intermediate", "Đi bộ leo dốc 25 phút" },
                    { 4, 6.0, "Cardio", 900, "Moderate", "Beginner", "Chạy bộ nhẹ 15 phút" },
                    { 5, 7.5, "Cardio", 1200, "Moderate", "Intermediate", "Chạy bộ 20 phút" },
                    { 6, 8.0, "Cardio", 1800, "High", "Intermediate", "Chạy bộ 30 phút" },
                    { 7, 10.0, "Cardio", 600, "Very High", "Advanced", "Chạy nước rút 10 phút" },
                    { 8, 11.0, "Cardio", 900, "Very High", "Advanced", "Chạy nước rút 15 phút" },
                    { 9, 4.0, "Cardio", 1200, "Low", "Beginner", "Đạp xe nhẹ 20 phút" },
                    { 10, 6.5, "Cardio", 1800, "Moderate", "Intermediate", "Đạp xe 30 phút" },
                    { 11, 8.0, "Cardio", 1500, "High", "Intermediate", "Đạp xe nhanh 25 phút" },
                    { 12, 9.0, "Cardio", 1800, "High", "Advanced", "Đạp xe leo dốc 30 phút" },
                    { 13, 5.0, "Cardio", 1200, "Moderate", "Beginner", "Bơi lội nhẹ 20 phút" },
                    { 14, 7.0, "Cardio", 1800, "Moderate", "Intermediate", "Bơi lội 30 phút" },
                    { 15, 9.0, "Cardio", 1500, "High", "Advanced", "Bơi lội nhanh 25 phút" },
                    { 16, 11.0, "Cardio", 600, "Very High", "Intermediate", "Nhảy dây 10 phút" },
                    { 17, 12.0, "Cardio", 900, "Very High", "Advanced", "Nhảy dây 15 phút" },
                    { 18, 5.0, "Cardio", 1200, "Moderate", "Beginner", "Aerobic nhẹ 20 phút" },
                    { 19, 6.5, "Cardio", 1800, "Moderate", "Intermediate", "Aerobic 30 phút" },
                    { 20, 7.0, "Cardio", 1800, "High", "Intermediate", "Zumba 30 phút" },
                    { 21, 9.0, "Cardio", 900, "Very High", "Intermediate", "HIIT 15 phút" },
                    { 22, 10.0, "Cardio", 1200, "Very High", "Advanced", "HIIT 20 phút" },
                    { 23, 11.0, "Cardio", 600, "Very High", "Advanced", "Tabata 10 phút" },
                    { 24, 6.0, "Cardio", 900, "Moderate", "Beginner", "Chạy bộ tại chỗ 15 phút" },
                    { 25, 8.0, "Cardio", 900, "High", "Intermediate", "Leo cầu thang 15 phút" },
                    { 26, 9.0, "Cardio", 1200, "High", "Advanced", "Leo cầu thang 20 phút" },
                    { 27, 7.0, "Cardio", 1200, "Moderate", "Intermediate", "Chèo thuyền 20 phút" },
                    { 28, 8.5, "Cardio", 1800, "High", "Advanced", "Chèo thuyền 30 phút" },
                    { 29, 4.5, "Cardio", 1200, "Low", "Beginner", "Đi bộ trong nước 20 phút" },
                    { 30, 5.5, "Cardio", 1800, "Moderate", "Beginner", "Thể dục dưới nước 30 phút" },
                    { 31, 8.0, "Cardio", 1200, "High", "Intermediate", "Kickboxing 20 phút" },
                    { 32, 9.0, "Cardio", 1800, "High", "Advanced", "Kickboxing 30 phút" },
                    { 33, 5.5, "Cardio", 1200, "Moderate", "Beginner", "Đạp xe đạp tĩnh 20 phút" },
                    { 34, 7.0, "Cardio", 1800, "Moderate", "Intermediate", "Đạp xe đạp tĩnh 30 phút" },
                    { 35, 7.5, "Cardio", 1200, "High", "Intermediate", "Máy chạy bộ dốc 20 phút" },
                    { 36, 8.5, "Cardio", 1800, "High", "Advanced", "Máy chạy bộ dốc 30 phút" },
                    { 37, 7.0, "Cardio", 600, "Moderate", "Beginner", "Nhảy Jumping Jacks 10 phút" },
                    { 38, 10.0, "Cardio", 600, "Very High", "Advanced", "Burpees 10 phút" },
                    { 39, 9.0, "Cardio", 600, "High", "Intermediate", "Mountain Climbers 10 phút" },
                    { 40, 4.0, "Cardio", 900, "Low", "Beginner", "Đi bộ nhanh trong nhà 15 phút" },
                    { 41, 6.5, "Cardio", 1200, "Moderate", "Intermediate", "Cardio nhảy nhót 20 phút" },
                    { 42, 7.0, "Cardio", 1500, "Moderate", "Intermediate", "Bài tập cardio tại nhà 25 phút" },
                    { 43, 8.0, "Cardio", 1500, "High", "Intermediate", "Chạy bộ ngoài trời 25 phút" },
                    { 44, 9.0, "Cardio", 1800, "High", "Advanced", "Chạy bộ địa hình 30 phút" },
                    { 45, 7.0, "Cardio", 2400, "Moderate", "Intermediate", "Đi xe đạp ngoài trời 40 phút" },
                    { 46, 9.0, "Cardio", 2700, "High", "Advanced", "Đi xe đạp địa hình 45 phút" },
                    { 47, 4.0, "Cardio", 1200, "Low", "Beginner", "Cardio nhẹ cho người mới 20 phút" },
                    { 48, 7.5, "Cardio", 1800, "High", "Intermediate", "Cardio giảm cân 30 phút" },
                    { 49, 8.5, "Cardio", 1500, "High", "Advanced", "Cardio đốt mỡ 25 phút" },
                    { 50, 7.0, "Cardio", 1800, "Moderate", "Intermediate", "Cardio toàn thân 30 phút" },
                    { 51, 4.0, "Strength", 900, "Low", "Beginner", "Tập tay không cơ bản 15 phút" },
                    { 52, 5.0, "Strength", 1200, "Moderate", "Beginner", "Tập tay không 20 phút" },
                    { 53, 6.0, "Strength", 1500, "Moderate", "Intermediate", "Tập tay không nâng cao 25 phút" },
                    { 54, 5.5, "Strength", 600, "Moderate", "Beginner", "Chống đẩy 10 phút" },
                    { 55, 6.5, "Strength", 900, "High", "Intermediate", "Chống đẩy nâng cao 15 phút" },
                    { 56, 4.5, "Strength", 600, "Moderate", "Beginner", "Plank 10 phút" },
                    { 57, 5.5, "Strength", 900, "Moderate", "Intermediate", "Plank nâng cao 15 phút" },
                    { 58, 4.0, "Strength", 600, "Moderate", "Beginner", "Gập bụng 10 phút" },
                    { 59, 5.0, "Strength", 900, "Moderate", "Intermediate", "Gập bụng nâng cao 15 phút" },
                    { 60, 5.0, "Strength", 900, "Moderate", "Beginner", "Squat 15 phút" },
                    { 61, 6.5, "Strength", 1200, "High", "Intermediate", "Squat có tạ 20 phút" },
                    { 62, 5.5, "Strength", 900, "Moderate", "Beginner", "Lunge 15 phút" },
                    { 63, 6.5, "Strength", 1200, "High", "Intermediate", "Lunge có tạ 20 phút" },
                    { 64, 6.0, "Strength", 1200, "Moderate", "Intermediate", "Tập tạ đơn tay 20 phút" },
                    { 65, 7.0, "Strength", 1800, "High", "Advanced", "Tập tạ đơn tay nâng cao 30 phút" },
                    { 66, 6.5, "Strength", 1800, "High", "Intermediate", "Tập tạ đòn 30 phút" },
                    { 67, 7.5, "Strength", 2400, "High", "Advanced", "Tập tạ đòn nặng 40 phút" },
                    { 68, 6.0, "Strength", 1200, "Moderate", "Intermediate", "Tập ngực 20 phút" },
                    { 69, 7.0, "Strength", 1800, "High", "Advanced", "Tập ngực nâng cao 30 phút" },
                    { 70, 6.0, "Strength", 1200, "Moderate", "Intermediate", "Tập lưng 20 phút" },
                    { 71, 7.0, "Strength", 1800, "High", "Advanced", "Tập lưng nâng cao 30 phút" },
                    { 72, 6.0, "Strength", 1200, "Moderate", "Intermediate", "Tập vai 20 phút" },
                    { 73, 6.5, "Strength", 1500, "High", "Advanced", "Tập vai nâng cao 25 phút" },
                    { 74, 5.5, "Strength", 900, "Moderate", "Beginner", "Tập tay trước 15 phút" },
                    { 75, 5.5, "Strength", 900, "Moderate", "Beginner", "Tập tay sau 15 phút" },
                    { 76, 6.5, "Strength", 1500, "Moderate", "Intermediate", "Tập chân toàn diện 25 phút" },
                    { 77, 7.5, "Strength", 2100, "High", "Advanced", "Tập chân nâng cao 35 phút" },
                    { 78, 6.0, "Strength", 1200, "Moderate", "Intermediate", "Tập mông 20 phút" },
                    { 79, 6.5, "Strength", 1500, "High", "Advanced", "Tập mông nâng cao 25 phút" },
                    { 80, 5.0, "Strength", 900, "Moderate", "Intermediate", "Tập bụng 6 múi 15 phút" },
                    { 81, 6.0, "Strength", 1200, "High", "Advanced", "Tập bụng nâng cao 20 phút" },
                    { 82, 6.5, "Strength", 1800, "Moderate", "Intermediate", "Tập toàn thân 30 phút" },
                    { 83, 7.5, "Strength", 2400, "High", "Advanced", "Tập toàn thân nâng cao 40 phút" },
                    { 84, 5.5, "Strength", 1200, "Moderate", "Beginner", "Tập với dây kháng lực 20 phút" },
                    { 85, 6.5, "Strength", 1800, "Moderate", "Intermediate", "Tập với dây kháng lực nâng cao 30 phút" },
                    { 86, 7.0, "Strength", 1200, "High", "Intermediate", "Tập với Kettlebell 20 phút" },
                    { 87, 8.0, "Strength", 1800, "High", "Advanced", "Tập với Kettlebell nâng cao 30 phút" },
                    { 88, 6.5, "Strength", 1200, "Moderate", "Intermediate", "Tập TRX 20 phút" },
                    { 89, 7.5, "Strength", 1800, "High", "Advanced", "Tập TRX nâng cao 30 phút" },
                    { 90, 6.0, "Strength", 1200, "Moderate", "Intermediate", "Calisthenics 20 phút" },
                    { 91, 7.0, "Strength", 1800, "High", "Advanced", "Calisthenics nâng cao 30 phút" },
                    { 92, 8.0, "Strength", 900, "Very High", "Advanced", "Tập sức mạnh bùng nổ 15 phút" },
                    { 93, 8.5, "Strength", 1200, "Very High", "Advanced", "Tập sức mạnh bùng nổ 20 phút" },
                    { 94, 8.0, "Strength", 1200, "Very High", "Advanced", "CrossFit WOD 20 phút" },
                    { 95, 9.0, "Strength", 1800, "Very High", "Advanced", "CrossFit WOD 30 phút" },
                    { 96, 5.5, "Strength", 900, "Moderate", "Intermediate", "Tập cơ bắp tay 15 phút" },
                    { 97, 6.5, "Strength", 1200, "Moderate", "Intermediate", "Tập cơ bắp chân 20 phút" },
                    { 98, 6.0, "Strength", 1800, "Moderate", "Intermediate", "Tập sức bền cơ bắp 30 phút" },
                    { 99, 7.0, "Strength", 2400, "High", "Advanced", "Tập tăng khối cơ 40 phút" },
                    { 100, 6.5, "Strength", 2100, "Moderate", "Intermediate", "Tập định hình cơ thể 35 phút" },
                    { 101, 2.0, "Mobility", 600, "Low", "Beginner", "Giãn cơ nhẹ nhàng 10 phút" },
                    { 102, 2.5, "Mobility", 900, "Low", "Beginner", "Giãn cơ toàn thân 15 phút" },
                    { 103, 2.2999999999999998, "Mobility", 600, "Low", "Beginner", "Giãn cơ sau tập 10 phút" },
                    { 104, 2.7000000000000002, "Mobility", 900, "Low", "Beginner", "Giãn cơ buổi sáng 15 phút" },
                    { 105, 3.0, "Mobility", 1200, "Low", "Beginner", "Yoga cơ bản 20 phút" },
                    { 106, 3.5, "Mobility", 1800, "Moderate", "Intermediate", "Yoga 30 phút" },
                    { 107, 4.0, "Mobility", 2400, "Moderate", "Advanced", "Yoga nâng cao 40 phút" },
                    { 108, 3.0, "Mobility", 1200, "Low", "Beginner", "Yoga buổi sáng 20 phút" },
                    { 109, 3.2000000000000002, "Mobility", 1500, "Low", "Intermediate", "Yoga buổi tối 25 phút" },
                    { 110, 3.0, "Mobility", 1800, "Low", "Beginner", "Yoga giảm stress 30 phút" },
                    { 111, 4.0, "Mobility", 2100, "Moderate", "Intermediate", "Yoga tăng sức mạnh 35 phút" },
                    { 112, 3.5, "Mobility", 1200, "Moderate", "Beginner", "Pilates cơ bản 20 phút" },
                    { 113, 4.0, "Mobility", 1800, "Moderate", "Intermediate", "Pilates 30 phút" },
                    { 114, 4.5, "Mobility", 2400, "Moderate", "Advanced", "Pilates nâng cao 40 phút" },
                    { 115, 3.7999999999999998, "Mobility", 1200, "Moderate", "Intermediate", "Pilates bụng 20 phút" },
                    { 116, 4.2000000000000002, "Mobility", 2100, "Moderate", "Advanced", "Pilates toàn thân 35 phút" },
                    { 117, 2.7999999999999998, "Mobility", 1200, "Low", "Beginner", "Thái Cực Quyền 20 phút" },
                    { 118, 3.0, "Mobility", 1800, "Low", "Intermediate", "Thái Cực Quyền 30 phút" },
                    { 119, 2.0, "Mobility", 900, "Low", "Beginner", "Thiền & Giãn cơ 15 phút" },
                    { 120, 2.2000000000000002, "Mobility", 1200, "Low", "Beginner", "Thiền & Thở 20 phút" },
                    { 121, 2.5, "Mobility", 600, "Low", "Beginner", "Giãn cơ chân 10 phút" },
                    { 122, 2.5, "Mobility", 600, "Low", "Beginner", "Giãn cơ lưng 10 phút" },
                    { 123, 2.2999999999999998, "Mobility", 600, "Low", "Beginner", "Giãn cơ vai cổ 10 phút" },
                    { 124, 2.2000000000000002, "Mobility", 900, "Low", "Beginner", "Massage cơ với foam roller 15 phút" },
                    { 125, 2.5, "Mobility", 1200, "Low", "Beginner", "Phục hồi cơ bắp 20 phút" },
                    { 126, 2.7999999999999998, "Mobility", 900, "Low", "Beginner", "Cải thiện tư thế 15 phút" },
                    { 127, 3.0, "Mobility", 1200, "Low", "Intermediate", "Tăng độ linh hoạt 20 phút" },
                    { 128, 3.0, "Mobility", 900, "Low", "Beginner", "Giãn cơ động 15 phút" },
                    { 129, 3.0, "Mobility", 600, "Low", "Beginner", "Khởi động toàn thân 10 phút" },
                    { 130, 2.0, "Mobility", 600, "Low", "Beginner", "Hạ nhiệt sau tập 10 phút" },
                    { 131, 2.5, "Mobility", 900, "Low", "Beginner", "Yoga ghế cho văn phòng 15 phút" },
                    { 132, 2.7999999999999998, "Mobility", 1200, "Low", "Beginner", "Yoga trước khi ngủ 20 phút" },
                    { 133, 2.5, "Mobility", 1500, "Low", "Beginner", "Yoga cho người cao tuổi 25 phút" },
                    { 134, 2.7999999999999998, "Mobility", 1200, "Low", "Beginner", "Yoga cho bà bầu 20 phút" },
                    { 135, 2.2999999999999998, "Mobility", 900, "Low", "Beginner", "Giãn cơ cho người đau lưng 15 phút" },
                    { 136, 2.5, "Mobility", 900, "Low", "Beginner", "Giãn cơ cho người ngồi nhiều 15 phút" },
                    { 137, 3.0, "Mobility", 900, "Low", "Intermediate", "Cải thiện cân bằng 15 phút" },
                    { 138, 3.2000000000000002, "Mobility", 1200, "Moderate", "Intermediate", "Tập thăng bằng 20 phút" },
                    { 139, 2.7999999999999998, "Mobility", 1500, "Low", "Intermediate", "Giãn cơ sâu 25 phút" },
                    { 140, 2.5, "Mobility", 1800, "Low", "Beginner", "Yoga phục hồi 30 phút" },
                    { 141, 2.7999999999999998, "Mobility", 2100, "Low", "Intermediate", "Yoga trị liệu 35 phút" },
                    { 142, 3.0, "Mobility", 1200, "Low", "Beginner", "Giãn cơ thể dục dụng cụ 20 phút" },
                    { 143, 2.0, "Mobility", 900, "Low", "Beginner", "Thở và thư giãn 15 phút" },
                    { 144, 3.5, "Mobility", 1500, "Moderate", "Advanced", "Giãn cơ cho vận động viên 25 phút" },
                    { 145, 4.5, "Mobility", 2400, "Moderate", "Advanced", "Yoga Power 40 phút" },
                    { 146, 4.0, "Mobility", 2100, "Moderate", "Intermediate", "Yoga Flow 35 phút" },
                    { 147, 2.5, "Mobility", 1200, "Low", "Beginner", "Giãn cơ phục hồi chấn thương 20 phút" },
                    { 148, 2.7999999999999998, "Mobility", 1200, "Low", "Beginner", "Giãn cơ tăng chiều cao 20 phút" },
                    { 149, 2.7000000000000002, "Mobility", 1500, "Low", "Beginner", "Yoga giảm đau 25 phút" },
                    { 150, 3.0, "Mobility", 1800, "Low", "Intermediate", "Giãn cơ toàn diện 30 phút" }
                });

            migrationBuilder.InsertData(
                table: "MealTemplates",
                columns: new[] { "Id", "Calories", "Carbs", "Category", "Description", "DietType", "Fat", "ImageUrl", "Name", "Protein" },
                values: new object[,]
                {
                    { 1, 350, 10.0, "Lunch", "Ức gà luộc, súp lơ xanh luộc, ít muối.", "Balanced", 5.0, null, "Ức gà luộc & Súp lơ", 40.0 },
                    { 2, 400, 60.0, "Breakfast", "Yến mạch nấu sữa, topping chuối và mật ong.", "Balanced", 6.0, null, "Yến mạch & Chuối", 12.0 },
                    { 3, 500, 5.0, "Dinner", "Cá hồi áp chảo với măng tây.", "Balanced", 25.0, null, "Cá hồi áp chảo", 35.0 },
                    { 4, 250, 20.0, "Post-workout", "1 muỗng whey, 1 quả chuối, nước.", "Balanced", 3.0, null, "Sinh tố Whey Protein", 25.0 },
                    { 5, 140, 1.0, "Snack", "2 quả trứng gà luộc.", "Balanced", 10.0, null, "Trứng luộc", 12.0 },
                    { 6, 600, 70.0, "Lunch", "1 bát cơm gạo lứt, 100g bò xào bông cải.", "Balanced", 15.0, null, "Cơm gạo lứt & Bò xào", 30.0 },
                    { 7, 300, 10.0, "Dinner", "Rau xà lách, cà chua, ức gà nướng, sốt mè rang.", "Balanced", 10.0, null, "Salad Ức gà", 30.0 },
                    { 8, 350, 40.0, "Breakfast", "2 lát bánh mì đen, 1/2 quả bơ, hạt tiêu.", "Balanced", 15.0, null, "Bánh mì đen & Bơ", 8.0 },
                    { 9, 120, 8.0, "Snack", "1 hũ sữa chua Hy Lạp.", "Balanced", 0.0, null, "Sữa chua Hy Lạp", 15.0 },
                    { 10, 200, 25.0, "Snack", "1 quả táo cắt lát, 1 thìa bơ đậu phộng.", "Balanced", 10.0, null, "Táo & Bơ đậu phộng", 5.0 },
                    { 11, 170, 6.0, "Snack", "30g hạt hạnh nhân rang mộc.", "Balanced", 15.0, null, "Hạt hạnh nhân (30g)", 6.0 },
                    { 12, 150, 35.0, "Pre-workout", "1 củ khoai lang luộc vừa.", "Balanced", 0.0, null, "Khoai lang luộc", 2.0 },
                    { 13, 450, 60.0, "Breakfast", "Phở bò ít bánh, nhiều hành.", "Balanced", 12.0, null, "Phở bò (tái)", 25.0 },
                    { 14, 700, 80.0, "Lunch", "Cơm tấm sườn nướng, bì, chả trứng (ăn chừng mực).", "Balanced", 30.0, null, "Cơm sườn bì chả", 25.0 },
                    { 15, 550, 65.0, "Breakfast", "Bún bò Huế đầy đủ.", "Balanced", 20.0, null, "Bún bò Huế", 30.0 },
                    { 16, 220, 25.0, "Post-workout", "Thanh protein bar tiện lợi.", "Balanced", 8.0, null, "Protein Bar", 20.0 },
                    { 17, 110, 26.0, "Snack", "1 ly nước cam ép nguyên chất.", "Balanced", 0.0, null, "Nước cam ép", 1.0 },
                    { 18, 400, 40.0, "Lunch", "Bánh mì sandwich kẹp cá ngừ sốt mayo ít béo.", "Balanced", 12.0, null, "Sandwich Cá ngừ", 25.0 },
                    { 19, 650, 90.0, "Dinner", "Mỳ Spaghetti sốt Bolognese.", "Balanced", 20.0, null, "Mỳ Ý sốt bò băm", 25.0 },
                    { 20, 350, 40.0, "Dinner", "Cháo gà xé phay, hành ngò.", "Balanced", 10.0, null, "Cháo gà", 20.0 },
                    { 21, 500, 60.0, "Lunch", "Bún chả Hà Nội, nhiều rau, nước mắm nhạt.", "Balanced", 15.0, null, "Bún chả (ít bún)", 25.0 },
                    { 22, 180, 25.0, "Snack", "3 cuốn gỏi tôm thịt, chấm tương đen.", "Balanced", 3.0, null, "Gỏi cuốn tôm thịt", 10.0 },
                    { 23, 750, 90.0, "Lunch", "Cơm rang dưa chua, thịt bò, một chút dầu mỡ.", "Balanced", 30.0, null, "Cơm rang dưa bò", 25.0 },
                    { 24, 400, 50.0, "Breakfast", "Miến trộn thịt gà xé, rau thơm, lạc rang.", "Balanced", 10.0, null, "Miến gà trộn", 25.0 },
                    { 25, 380, 40.0, "Breakfast", "1 bánh mì, 2 trứng ốp la, dưa chuột.", "Balanced", 18.0, null, "Bánh mì ốp la", 15.0 },
                    { 26, 150, 12.0, "Snack", "1 ly sữa đậu nành nóng, ít đường.", "Balanced", 6.0, null, "Sữa đậu nành", 8.0 },
                    { 27, 300, 10.0, "Dinner", "Canh chua cá lóc, ăn kèm rau sống.", "Balanced", 12.0, null, "Canh chua cá lóc", 25.0 },
                    { 28, 250, 10.0, "Dinner", "2 bìa đậu phụ sốt cà chua, hành lá.", "Balanced", 15.0, null, "Đậu phụ sốt cà chua", 12.0 },
                    { 29, 120, 5.0, "Dinner", "1 đĩa rau muống xào tỏi.", "Balanced", 10.0, null, "Rau muống xào tỏi", 3.0 },
                    { 30, 450, 5.0, "Lunch", "Thịt ba chỉ kho trứng, ăn chừng mực.", "Balanced", 35.0, null, "Thịt kho tàu (2 miếng)", 20.0 },
                    { 31, 200, 20.0, "Snack", "1 chén súp cua nóng hổi.", "Balanced", 5.0, null, "Súp cua", 10.0 },
                    { 32, 550, 60.0, "Lunch", "Nem nướng Nha Trang cuốn bánh tráng.", "Balanced", 25.0, null, "Nem nướng", 25.0 },
                    { 33, 400, 60.0, "Breakfast", "Bánh cuốn không nhân, chả quế.", "Balanced", 12.0, null, "Bánh cuốn Thanh Trì", 10.0 },
                    { 34, 600, 80.0, "Breakfast", "Xôi xéo mỡ hành, đậu xanh, ruốc.", "Balanced", 25.0, null, "Xôi xéo", 15.0 },
                    { 35, 250, 50.0, "Snack", "Chè hạt sen long nhãn, ngọt thanh.", "Balanced", 2.0, null, "Chè hạt sen", 5.0 },
                    { 36, 60, 15.0, "Pre-workout", "1 quả dừa tươi.", "Balanced", 0.0, null, "Nước dừa tươi", 1.0 },
                    { 37, 100, 25.0, "Pre-workout", "2 quả chuối sáp luộc.", "Balanced", 0.0, null, "Chuối luộc", 1.0 },
                    { 38, 150, 30.0, "Snack", "1 bắp ngô nếp luộc.", "Balanced", 2.0, null, "Ngô luộc", 4.0 },
                    { 39, 120, 10.0, "Snack", "1 hộp sữa tươi Vinamilk không đường.", "Balanced", 6.0, null, "Sữa tươi không đường", 8.0 },
                    { 40, 350, 45.0, "Breakfast", "Ngũ cốc Granola ăn kèm sữa chua.", "Balanced", 12.0, null, "Granola & Sữa chua", 12.0 },
                    { 41, 350, 40.0, "Snack", "Món tráng miệng, hạn chế ăn nhiều.", "Balanced", 20.0, null, "Bơ dầm sữa đặc", 4.0 },
                    { 42, 250, 35.0, "Pre-workout", "Năng lượng tỉnh táo buổi sáng.", "Balanced", 10.0, null, "Cà phê sữa đá", 4.0 },
                    { 43, 450, 0.0, "Dinner", "Bò bít tết áp chảo, kèm salad.", "Balanced", 30.0, null, "Bò bít tết (150g)", 40.0 },
                    { 44, 250, 10.0, "Lunch", "Mực tươi xào cần tây, tỏi tây.", "Balanced", 10.0, null, "Mực xào cần tỏi", 20.0 },
                    { 45, 150, 2.0, "Dinner", "200g tôm sú hấp bia.", "Balanced", 2.0, null, "Tôm hấp bia", 25.0 },
                    { 46, 400, 15.0, "Lunch", "Đùi gà nướng mật ong.", "Balanced", 20.0, null, "Gà nướng mật ong", 30.0 },
                    { 47, 500, 40.0, "Dinner", "Bún, tôm, mực, rau, nước lẩu.", "Balanced", 25.0, null, "Lẩu thái (1 bát)", 25.0 },
                    { 48, 300, 40.0, "Breakfast", "1 chiếc bánh bao to.", "Balanced", 8.0, null, "Bánh bao nhân thịt", 10.0 },
                    { 49, 300, 30.0, "Dinner", "Cháo yến mạch nấu ức gà băm.", "Balanced", 5.0, null, "Cháo yến mạch ức gà", 25.0 },
                    { 50, 450, 60.0, "Lunch", "6 miếng sushi cá hồi, tôm.", "Balanced", 10.0, null, "Sushi tổng hợp", 20.0 },
                    { 51, 250, 0.0, "Dinner", "100g cá hồi tươi sống.", "Balanced", 15.0, null, "Sashimi Cá hồi", 30.0 },
                    { 52, 400, 50.0, "Snack", "Cơm cuộn rong biển tẩm bột chiên.", "Balanced", 18.0, null, "Kimbap chiên", 10.0 },
                    { 53, 450, 90.0, "Snack", "Bánh gạo cay Hàn Quốc.", "Balanced", 5.0, null, "Tokbokki", 8.0 },
                    { 54, 600, 85.0, "Lunch", "Mì Jajangmyeon kèm củ cải muối.", "Balanced", 15.0, null, "Mì tương đen", 20.0 },
                    { 55, 300, 35.0, "Lunch", "Pizza bò hoặc hải sản đế dày.", "Balanced", 12.0, null, "Pizza (1 lát)", 12.0 },
                    { 56, 500, 45.0, "Lunch", "Burger bò phô mai, rau xà lách.", "Balanced", 25.0, null, "Hamburger Bò", 25.0 },
                    { 57, 350, 20.0, "Lunch", "Ức gà hoặc đùi gà tẩm bột chiên giòn.", "Balanced", 20.0, null, "Gà rán (1 miếng)", 20.0 },
                    { 58, 350, 50.0, "Snack", "1 phần khoai tây chiên vừa.", "Balanced", 15.0, null, "Khoai tây chiên", 4.0 },
                    { 59, 250, 35.0, "Snack", "Bánh kếp nhân chuối socola.", "Balanced", 10.0, null, "Bánh Crepe chuối", 5.0 },
                    { 60, 350, 60.0, "Snack", "Trà sữa trân châu đường đen.", "Balanced", 10.0, null, "Trà sữa (50% đường)", 2.0 },
                    { 61, 180, 10.0, "Snack", "Sữa hạt điều nguyên chất.", "Balanced", 14.0, null, "Sữa hạt điều", 6.0 },
                    { 62, 200, 40.0, "Breakfast", "Cải bó xôi, chuối, táo, nước dừa.", "Balanced", 2.0, null, "Smoothie Xanh", 5.0 },
                    { 63, 350, 40.0, "Breakfast", "Bánh giò nóng nhân thịt mộc nhĩ.", "Balanced", 15.0, null, "Bánh giò", 12.0 },
                    { 64, 250, 50.0, "Snack", "Chè đậu đen ít đường, nước cốt dừa.", "Balanced", 2.0, null, "Chè đậu đen", 8.0 },
                    { 65, 150, 25.0, "Snack", "Tào phớ nước đường gừng.", "Balanced", 2.0, null, "Tào phớ", 8.0 },
                    { 66, 550, 20.0, "Snack", "Lạc (đậu phộng) luộc cả vỏ.", "Balanced", 45.0, null, "Lạc luộc (100g)", 25.0 },
                    { 67, 400, 20.0, "Snack", "5 chiếc nem chua rán.", "Balanced", 25.0, null, "Nem chua rán", 20.0 },
                    { 68, 300, 20.0, "Snack", "3 que phô mai chiên.", "Balanced", 18.0, null, "Phô mai que", 10.0 },
                    { 69, 250, 5.0, "Snack", "Chân gà ngâm sả tắc chua cay.", "Balanced", 15.0, null, "Chân gà sả tắc", 20.0 },
                    { 70, 200, 20.0, "Snack", "Nộm đu đủ bò khô, lạc rang.", "Balanced", 5.0, null, "Nộm bò khô", 15.0 },
                    { 71, 300, 45.0, "Snack", "Bánh tráng, xoài, trứng cút, bò khô.", "Balanced", 10.0, null, "Bánh tráng trộn", 5.0 },
                    { 72, 400, 50.0, "Snack", "1 gói cơm cháy chà bông.", "Balanced", 15.0, null, "Cơm cháy chà bông", 10.0 },
                    { 73, 250, 50.0, "Snack", "Các loại trái cây trộn sữa chua.", "Balanced", 5.0, null, "Hoa quả dầm", 5.0 },
                    { 74, 400, 10.0, "Lunch", "Món đặc sản chả rươi thơm ngon.", "Balanced", 25.0, null, "Chả rươi", 25.0 },
                    { 75, 450, 10.0, "Dinner", "Canh măng nấu chân/cổ cánh vịt.", "Balanced", 30.0, null, "Canh măng vịt", 25.0 },
                    { 76, 700, 80.0, "Lunch", "Bún, đậu rán, chả cốm, thịt chân giò.", "Balanced", 35.0, null, "Bún đậu mắm tôm", 35.0 },
                    { 77, 500, 20.0, "Dinner", "Cá lăng nướng, thì là, hành, mắm tôm.", "Balanced", 30.0, null, "Chả cá Lã Vọng", 30.0 },
                    { 78, 600, 70.0, "Lunch", "2 cái bánh xèo nhân tôm thịt.", "Balanced", 25.0, null, "Bánh xèo", 20.0 },
                    { 79, 400, 50.0, "Snack", "5 cái bánh khọt tôm.", "Balanced", 15.0, null, "Bánh khọt", 15.0 },
                    { 80, 550, 40.0, "Dinner", "Lẩu mắm miền Tây, nhiều rau.", "Balanced", 25.0, null, "Lẩu mắm", 30.0 },
                    { 81, 400, 60.0, "Lunch", "Cơm hến Huế cay nồng.", "Balanced", 10.0, null, "Cơm hến", 15.0 },
                    { 82, 450, 55.0, "Breakfast", "Mì Quảng tôm thịt trứng.", "Balanced", 15.0, null, "Mì Quảng", 20.0 },
                    { 83, 500, 60.0, "Lunch", "Cao lầu Hội An, thịt xá xíu.", "Balanced", 15.0, null, "Cao lầu", 25.0 },
                    { 84, 450, 55.0, "Breakfast", "Bánh mì thập cẩm đặc biệt.", "Balanced", 18.0, null, "Bánh mì Hội An", 20.0 },
                    { 85, 200, 30.0, "Snack", "Sữa bí đỏ hạt sen.", "Balanced", 6.0, null, "Sữa bí đỏ", 5.0 },
                    { 86, 50, 10.0, "Post-workout", "Detox cơ thể, giảm cân.", "Balanced", 0.0, null, "Nước ép cần tây", 1.0 },
                    { 87, 350, 25.0, "Dinner", "Khoai tây, cà rốt, đậu hà lan, sốt mayonaise.", "Balanced", 20.0, null, "Salad Nga", 8.0 },
                    { 88, 500, 10.0, "Dinner", "Bò lúc lắc khoai tây chiên.", "Balanced", 35.0, null, "Bò lúc lắc", 30.0 },
                    { 89, 550, 10.0, "Lunch", "3 cánh gà chiên mắm đậm đà.", "Balanced", 40.0, null, "Cánh gà chiên nước mắm", 25.0 },
                    { 90, 200, 10.0, "Dinner", "Canh mướp đắng nhồi thịt nạc vai.", "Balanced", 8.0, null, "Mướp đắng nhồi thịt", 15.0 },
                    { 91, 180, 2.0, "Snack", "1 quả trứng vịt lộn, rau răm.", "Balanced", 12.0, null, "Trứng vịt lộn", 14.0 },
                    { 92, 300, 50.0, "Snack", "2 viên chè trôi nước cốt dừa.", "Balanced", 8.0, null, "Chè trôi nước", 5.0 },
                    { 93, 150, 25.0, "Snack", "Sữa ngô non thơm mát.", "Balanced", 5.0, null, "Sữa ngô", 4.0 },
                    { 94, 500, 70.0, "Breakfast", "1 góc bánh chưng rán giòn.", "Balanced", 20.0, null, "Bánh nếp/Bánh chưng rán", 15.0 },
                    { 95, 200, 5.0, "Dinner", "Măng tây xanh xào tôm nõn.", "Balanced", 10.0, null, "Măng tây xào tôm", 20.0 },
                    { 96, 100, 10.0, "Dinner", "Món chay thanh đạm.", "Balanced", 5.0, null, "Cải thìa xào nấm", 5.0 },
                    { 97, 350, 10.0, "Lunch", "Đậu que giòn ngọt xào thịt bò.", "Balanced", 20.0, null, "Đậu que xào thịt bò", 25.0 },
                    { 98, 150, 20.0, "Dinner", "Canh bí đỏ dinh dưỡng.", "Balanced", 5.0, null, "Canh bí đỏ thịt băm", 10.0 },
                    { 99, 350, 5.0, "Lunch", "Cá lóc hoặc cá ba sa kho tộ.", "Balanced", 20.0, null, "Cá kho tộ", 30.0 },
                    { 100, 150, 5.0, "Dinner", "Canh cua đồng ăn với cà pháo.", "Balanced", 8.0, null, "Canh cua rau đay", 10.0 }
                });

            migrationBuilder.InsertData(
                table: "ProductCategories",
                columns: new[] { "Id", "CreatedAt", "Description", "ImageUrl", "IsActive", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1799), "Tạ, thảm, dây kháng lực...", "https://example.com/gear.jpg", true, "Dụng cụ tập luyện" },
                    { 2, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1803), "Whey, BCAA, Pre-workout...", "https://example.com/supp.jpg", true, "Thực phẩm bổ sung" },
                    { 3, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1804), "Áo gym, quần short nam...", "https://example.com/men.jpg", true, "Trang phục nam" },
                    { 4, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1805), "Bra, Legging nữ...", "https://example.com/women.jpg", true, "Trang phục nữ" },
                    { 5, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1806), "Bình nước, găng tay...", "https://example.com/acc.jpg", true, "Phụ kiện" }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "Id", "CategoryId", "CreatedAt", "Description", "ImageUrl", "IsActive", "Name", "Price", "Stock" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1824), "Tạ tay bọc cao su 5kg", "https://example.com/ta5kg.jpg", true, "Tạ đơn Hex 5kg", 150000m, 20 },
                    { 2, 1, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1830), "Thảm tập chống trượt 6mm", "https://example.com/tham.jpg", true, "Thảm Yoga TPE", 250000m, 50 },
                    { 3, 2, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1831), "Sữa tăng cơ vị Chocolate", "https://example.com/whey.jpg", true, "Whey Gold Standard 5lbs", 1850000m, 10 },
                    { 4, 2, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1833), "Hũ 300g không mùi", "https://example.com/creatine.jpg", true, "Creatine Monohydrate", 450000m, 15 },
                    { 5, 3, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1834), "Vải thun lạnh co giãn", "https://example.com/shirt.jpg", true, "Áo Thun Gym Shark", 200000m, 30 },
                    { 6, 4, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1836), "Quần tập yoga cao cấp", "https://example.com/leg.jpg", true, "Quần Legging Lululemon", 500000m, 20 },
                    { 7, 5, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1837), "Bình lắc 500ml", "https://example.com/shaker.jpg", true, "Bình nước Shaker", 90000m, 100 },
                    { 8, 5, new DateTime(2025, 12, 12, 17, 29, 47, 941, DateTimeKind.Utc).AddTicks(1838), "Bảo vệ lòng bàn tay", "https://example.com/glove.jpg", true, "Găng tay tập Gym", 120000m, 40 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AspNetRoleClaims_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "RoleNameIndex",
                table: "AspNetRoles",
                column: "NormalizedName",
                unique: true,
                filter: "[NormalizedName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserClaims_UserId",
                table: "AspNetUserClaims",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserLogins_UserId",
                table: "AspNetUserLogins",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "EmailIndex",
                table: "AspNetUsers",
                column: "NormalizedEmail");

            migrationBuilder.CreateIndex(
                name: "UserNameIndex",
                table: "AspNetUsers",
                column: "NormalizedUserName",
                unique: true,
                filter: "[NormalizedUserName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_ProductId",
                table: "CartItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_UserId",
                table: "CartItems",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_OrderId",
                table: "OrderItems",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_ProductId",
                table: "OrderItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_UserId",
                table: "Orders",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_CategoryId",
                table: "Products",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_WaterIntakes_UserId",
                table: "WaterIntakes",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AspNetRoleClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserLogins");

            migrationBuilder.DropTable(
                name: "AspNetUserRoles");

            migrationBuilder.DropTable(
                name: "AspNetUserTokens");

            migrationBuilder.DropTable(
                name: "CartItems");

            migrationBuilder.DropTable(
                name: "ExerciseRecords");

            migrationBuilder.DropTable(
                name: "ExerciseTemplates");

            migrationBuilder.DropTable(
                name: "HealthProfiles");

            migrationBuilder.DropTable(
                name: "MealTemplates");

            migrationBuilder.DropTable(
                name: "NutritionRecords");

            migrationBuilder.DropTable(
                name: "OrderItems");

            migrationBuilder.DropTable(
                name: "SleepRecords");

            migrationBuilder.DropTable(
                name: "UserProfiles");

            migrationBuilder.DropTable(
                name: "WaterIntakes");

            migrationBuilder.DropTable(
                name: "AspNetRoles");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "AspNetUsers");

            migrationBuilder.DropTable(
                name: "ProductCategories");
        }
    }
}
