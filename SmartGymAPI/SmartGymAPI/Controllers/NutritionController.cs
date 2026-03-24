using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;
using SmartGymAPI.DTOs;
using System.Security.Claims;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NutritionController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public NutritionController(ApplicationDbContext context)
        {
            _context = context;
        }

        private string GetUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        // Helper: map DTO -> Entity
        private NutritionRecord MapDtoToEntity(NutritionDto dto, string userId, NutritionRecord? existing = null)
        {
            var rec = existing ?? new NutritionRecord();
            rec.UserId = userId;
            rec.MealType = dto.MealType ?? rec.MealType;
            rec.Calories = dto.Calories;
            rec.Protein = dto.Protein;
            rec.Carbs = dto.Carbs;
            rec.Fat = dto.Fat;
            rec.Date = dto.Date.HasValue ? dto.Date.Value.ToUniversalTime() : (existing?.Date ?? DateTime.UtcNow);
            rec.MealSlot = string.IsNullOrWhiteSpace(dto.MealSlot) ? (existing?.MealSlot ?? "lunch") : dto.MealSlot;
            rec.ConsumedAt = dto.ConsumedAt.HasValue ? dto.ConsumedAt.Value.ToUniversalTime() : existing?.ConsumedAt;
            return rec;
        }

        // 🟢 Thêm bản ghi dinh dưỡng
        [HttpPost]
        public async Task<IActionResult> AddNutrition([FromBody] NutritionDto dto)
        {
            if (dto == null) return BadRequest(new { message = "Yêu cầu không hợp lệ." });

            var userId = GetUserId();
            var entity = MapDtoToEntity(dto, userId);
            _context.NutritionRecords.Add(entity);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetById), new { id = entity.Id }, entity);
        }

        // 🟠 Lấy bản ghi theo Id
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var rec = await _context.NutritionRecords.FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);
            if (rec == null) return NotFound(new { message = "Không tìm thấy bản ghi." });
            return Ok(rec);
        }

        // 📥 Lấy tất cả bản ghi dinh dưỡng
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = GetUserId();
            var list = await _context.NutritionRecords
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.Date)
                .ToListAsync();
            return Ok(list);
        }

        // 🔄 Cập nhật bản ghi
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromBody] NutritionDto dto)
        {
            var userId = GetUserId();
            var rec = await _context.NutritionRecords.FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);
            if (rec == null) return NotFound(new { message = "Không tìm thấy bản ghi." });

            rec = MapDtoToEntity(dto, userId, rec);

            await _context.SaveChangesAsync();
            return Ok(rec);
        }

        // ❌ Xóa bản ghi
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var rec = await _context.NutritionRecords.FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);
            if (rec == null) return NotFound(new { message = "Không tìm thấy bản ghi." });

            _context.NutritionRecords.Remove(rec);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa bản ghi." });
        }

        // 📊 Tổng dinh dưỡng hôm nay (group by Date.Date UTC)
        [HttpGet("today")]
        public async Task<IActionResult> GetToday()
        {
            var userId = GetUserId();
            var todayUtc = DateTime.UtcNow.Date;

            var list = await _context.NutritionRecords
                .Where(n => n.UserId == userId && n.Date.Date == todayUtc)
                .ToListAsync();

            var totalCalories = list.Sum(n => n.Calories);
            var totalProtein = list.Sum(n => n.Protein);
            var totalCarbs = list.Sum(n => n.Carbs);
            var totalFat = list.Sum(n => n.Fat);

            return Ok(new { date = todayUtc, totalCalories, totalProtein, totalCarbs, totalFat, records = list });
        }

        // 📈 Tiến độ hôm nay (dùng DailyCalorieGoal từ HealthProfile)
        [HttpGet("progress-today")]
        public async Task<IActionResult> GetProgressToday()
        {
            var userId = GetUserId();
            var todayUtc = DateTime.UtcNow.Date;

            var totalCalories = await _context.NutritionRecords
                .Where(n => n.UserId == userId && n.Date.Date == todayUtc)
                .SumAsync(n => n.Calories);

            var profile = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.UserId == userId);
            int dailyGoal = profile?.DailyCalorieGoal ?? 2000;

            double percent = dailyGoal > 0 ? (totalCalories / (double)dailyGoal) * 100.0 : 0.0;

            return Ok(new
            {
                date = todayUtc,
                totalCalories,
                dailyGoal,
                progressPercent = Math.Round(percent, 2)
            });
        }

        // 📊 Thống kê 7 ngày
        [HttpGet("last7days")]
        public async Task<IActionResult> GetLast7Days()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;
            var startDay = today.AddDays(-6);

            var data = await _context.NutritionRecords
                .Where(n => n.UserId == userId && n.Date.Date >= startDay)
                .GroupBy(n => n.Date.Date)
                .Select(g => new { date = g.Key, totalCalories = g.Sum(x => x.Calories) })
                .OrderBy(x => x.date)
                .ToListAsync();

            return Ok(data);
        }

        // 📊 Thống kê 30 ngày
        [HttpGet("last30days")]
        public async Task<IActionResult> GetLast30Days()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;
            var startDay = today.AddDays(-29);

            var data = await _context.NutritionRecords
                .Where(n => n.UserId == userId && n.Date.Date >= startDay)
                .GroupBy(n => n.Date.Date)
                .Select(g => new { date = g.Key, totalCalories = g.Sum(x => x.Calories) })
                .OrderBy(x => x.date)
                .ToListAsync();

            return Ok(data);
        }

        // 🔔 Gợi ý bữa ăn (đơn giản, cục bộ) - có thể mở rộng thành service/DB
        [HttpGet("suggestions")]
        public IActionResult GetSuggestions([FromQuery] int remainingCalories = 500, [FromQuery] string mealTime = "any")
        {
            // Mẫu gợi ý cục bộ; bạn có thể thay bằng DB/service
            var suggestions = new[]
            {
                new { name = "Yến mạch + sữa chua", category = "breakfast", calories = 280, protein = 12.0, carbs = 45.0, fat = 6.0 },
                new { name = "Ức gà áp chảo + rau", category = "lunch", calories = 350, protein = 35.0, carbs = 20.0, fat = 12.0 },
                new { name = "Cơm gạo lứt + cá hồi", category = "dinner", calories = 520, protein = 32.0, carbs = 55.0, fat = 18.0 },
                new { name = "Salad trứng + bơ", category = "snack", calories = 300, protein = 16.0, carbs = 10.0, fat = 20.0 },
                new { name = "Chuối + bơ đậu phộng", category = "snack", calories = 220, protein = 8.0, carbs = 28.0, fat = 9.0 }
            };

            // Lọc đơn giản theo remainingCalories và mealTime
            var filtered = suggestions
                .Where(s => s.calories <= Math.Max(remainingCalories, 250) + (int)(remainingCalories * 0.2))
                .Where(s => mealTime == "any" || s.category == mealTime.ToLower())
                .ToList();

            return Ok(filtered);
        }
    }
}