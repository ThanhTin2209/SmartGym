using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.DTOs;
using SmartGymAPI.Models;
using System.Security.Claims;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class WaterIntakeController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<IdentityUser> _userManager;

        public WaterIntakeController(ApplicationDbContext context, UserManager<IdentityUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        }

        [HttpGet]
        public async Task<IActionResult> GetWaterIntakes()
        {
            var userId = GetUserId();

            var result = await _context.WaterIntakes
                .Where(w => w.UserId == userId)
                .OrderByDescending(w => w.Date)
                .ToListAsync();

            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> AddWaterIntake([FromBody] AddWaterIntakeDto data)
        {
            if (data == null)
                return BadRequest(new { message = "Request body is required." });

            if (data.Amount <= 0)
                ModelState.AddModelError(nameof(data.Amount), "Amount must be greater than 0.");

            if (!ModelState.IsValid)
                return ValidationProblem(ModelState);

            var userId = GetUserId();

            var intake = new WaterIntake
            {
                UserId = userId,
                Amount = data.Amount,
                Date = (data.Date.HasValue && data.Date.Value != default) ? data.Date.Value.ToUniversalTime() : DateTime.UtcNow
            };

            _context.WaterIntakes.Add(intake);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetWaterIntakes), new { id = intake.Id }, new
            {
                message = "Đã lưu lượng nước uống thành công!",
                data = intake
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateWaterIntake(int id, [FromBody] AddWaterIntakeDto data)
        {
            if (data == null)
                return BadRequest(new { message = "Request body is required." });

            if (data.Amount <= 0)
                ModelState.AddModelError(nameof(data.Amount), "Amount must be greater than 0.");

            if (!ModelState.IsValid)
                return ValidationProblem(ModelState);

            var userId = GetUserId();
            var intake = await _context.WaterIntakes.FindAsync(id);

            if (intake == null || intake.UserId != userId)
                return NotFound(new { message = "Không tìm thấy dữ liệu!" });

            intake.Amount = data.Amount;
            intake.Date = (data.Date.HasValue && data.Date.Value != default) ? data.Date.Value.ToUniversalTime() : DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(intake);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteWaterIntake(int id)
        {
            var userId = GetUserId();
            var intake = await _context.WaterIntakes.FindAsync(id);

            if (intake == null || intake.UserId != userId)
                return NotFound(new { message = "Không tìm thấy dữ liệu!" });

            _context.WaterIntakes.Remove(intake);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa thành công!" });
        }

        [HttpGet("today")]
        public async Task<IActionResult> GetTodayIntake()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;

            var total = await _context.WaterIntakes
                .Where(w => w.UserId == userId && w.Date.Date == today)
                .SumAsync(w => w.Amount);

            return Ok(new { date = today, totalAmount = total });
        }

        [HttpGet("last7days")]
        public async Task<IActionResult> GetLast7Days()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;
            var startDay = today.AddDays(-6);

            var data = await _context.WaterIntakes
                .Where(w => w.UserId == userId && w.Date.Date >= startDay)
                .GroupBy(w => w.Date.Date)
                .Select(g => new { date = g.Key, total = g.Sum(x => x.Amount) })
                .OrderBy(x => x.date)
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("last30days")]
        public async Task<IActionResult> GetLast30Days()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;
            var startDay = today.AddDays(-29);

            var data = await _context.WaterIntakes
                .Where(w => w.UserId == userId && w.Date.Date >= startDay)
                .GroupBy(w => w.Date.Date)
                .Select(g => new { date = g.Key, total = g.Sum(x => x.Amount) })
                .OrderBy(x => x.date)
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("progress-today")]
        public async Task<IActionResult> GetTodayProgress()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;

            var totalToday = await _context.WaterIntakes
                .Where(w => w.UserId == userId && w.Date.Date == today)
                .SumAsync(w => w.Amount);

            // Try UserProfiles first, fallback to HealthProfiles
            double? weight = null;

            var userProfile = await _context.UserProfiles
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (userProfile != null)
            {
                weight = userProfile.Weight;
            }
            else
            {
                var healthProfile = await _context.HealthProfiles
                    .FirstOrDefaultAsync(h => h.UserId == userId);
                if (healthProfile != null)
                    weight = healthProfile.Weight;
            }

            if (!weight.HasValue || weight.Value <= 0)
            {
                return Ok(new
                {
                    date = today,
                    totalWater = totalToday,
                    dailyGoal = 0.0,
                    progressPercent = 0.0,
                    warning = "Cần cập nhật cân nặng trong hồ sơ để tính mục tiêu hàng ngày."
                });
            }

            double dailyGoal = Math.Round(weight.Value * 35, 2);
            double progress = (dailyGoal > 0) ? (totalToday / dailyGoal) * 100 : 0;

            return Ok(new
            {
                date = today,
                totalWater = totalToday,
                dailyGoal = dailyGoal,
                progressPercent = Math.Round(progress, 2)
            });
        }

        [HttpGet("chart-7-days")]
        public async Task<IActionResult> GetChart7Days()
        {
            var userId = GetUserId();
            var startDate = DateTime.UtcNow.Date.AddDays(-6);

            var data = await _context.WaterIntakes
                .Where(w => w.UserId == userId && w.Date.Date >= startDate)
                .GroupBy(w => w.Date.Date)
                .Select(g => new { date = g.Key, total = g.Sum(x => x.Amount) })
                .OrderBy(x => x.date)
                .ToListAsync();

            var chart = Enumerable.Range(0, 7)
                .Select(i => startDate.AddDays(i))
                .Select(day => new { date = day, total = data.FirstOrDefault(x => x.date == day)?.total ?? 0 })
                .ToList();

            return Ok(chart);
        }

        [HttpGet("chart-30-days")]
        public async Task<IActionResult> GetChart30Days()
        {
            var userId = GetUserId();
            var startDate = DateTime.UtcNow.Date.AddDays(-29);

            var data = await _context.WaterIntakes
                .Where(w => w.UserId == userId && w.Date.Date >= startDate)
                .GroupBy(w => w.Date.Date)
                .Select(g => new { date = g.Key, total = g.Sum(x => x.Amount) })
                .OrderBy(x => x.date)
                .ToListAsync();

            var chart = Enumerable.Range(0, 30)
                .Select(i => startDate.AddDays(i))
                .Select(day => new { date = day, total = data.FirstOrDefault(x => x.date == day)?.total ?? 0 })
                .ToList();

            return Ok(chart);
        }
    }
}