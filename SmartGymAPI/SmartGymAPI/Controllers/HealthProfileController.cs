using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartGymAPI.Data;
using SmartGymAPI.Models;
using SmartGymAPI.Utils; // 👉 để gọi HealthUtils
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // 🧩 Yêu cầu JWT token
    public class HealthProfileController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public HealthProfileController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 🟢 API tạo hồ sơ người dùng
        [HttpPost]
        public async Task<IActionResult> CreateProfile([FromBody] HealthProfile model)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (_context.HealthProfiles.Any(h => h.UserId == userId))
            {
                return BadRequest(new { message = "Hồ sơ đã tồn tại!" });
            }

            model.UserId = userId;
            // 👉 Tính BMI trước khi lưu
            model.Bmi = HealthUtils.TinhBmi(model.Height, model.Weight);
            // 👉 Tính DailyCalorieGoal trước khi lưu
            model.DailyCalorieGoal = model.CalculateDailyCalories();

            _context.HealthProfiles.Add(model);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Tạo hồ sơ người dùng thành công!",
                fullName = model.FullName,
                age = model.Age,
                height = model.Height,
                weight = model.Weight,
                gender = model.Gender,
                goal = model.Goal,
                bmi = model.Bmi,
                phanLoai = HealthUtils.PhanLoaiBmi(model.Bmi),
                activityLevel = model.ActivityLevel,
                dailyCalorieGoal = model.DailyCalorieGoal
            });
        }

        // 🔵 API cập nhật hồ sơ người dùng
        [HttpPut]
        public async Task<IActionResult> UpdateProfile([FromBody] HealthProfile update)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var existing = _context.HealthProfiles.FirstOrDefault(h => h.UserId == userId);

            if (existing == null)
            {
                return NotFound(new { message = "Không tìm thấy hồ sơ!" });
            }

            existing.FullName = update.FullName;
            existing.Age = update.Age;
            existing.Height = update.Height;
            existing.Weight = update.Weight;
            existing.Gender = update.Gender;
            existing.Goal = update.Goal;
            existing.ActivityLevel = update.ActivityLevel;

            // 👉 Tính lại BMI khi cập nhật
            existing.Bmi = HealthUtils.TinhBmi(existing.Height, existing.Weight);
            // 👉 Tính lại DailyCalorieGoal khi cập nhật
            existing.DailyCalorieGoal = existing.CalculateDailyCalories();

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Cập nhật hồ sơ thành công!",
                fullName = existing.FullName,
                age = existing.Age,
                height = existing.Height,
                weight = existing.Weight,
                gender = existing.Gender,
                goal = existing.Goal,
                bmi = existing.Bmi,
                phanLoai = HealthUtils.PhanLoaiBmi(existing.Bmi),
                activityLevel = existing.ActivityLevel,
                dailyCalorieGoal = existing.DailyCalorieGoal
            });
        }

        // 🟠 API kiểm tra xem user có hồ sơ chưa
        [HttpGet("check")]
        public IActionResult CheckProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var hasProfile = _context.HealthProfiles.Any(h => h.UserId == userId);

            return Ok(new { hasProfile });
        }

        // 📥 API lấy hồ sơ người dùng hiện tại
        [HttpGet]
        public IActionResult GetProfile()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var profile = _context.HealthProfiles.FirstOrDefault(h => h.UserId == userId);

            if (profile == null)
            {
                return NotFound(new { message = "Không tìm thấy hồ sơ!" });
            }

            return Ok(new
            {
                fullName = profile.FullName,
                age = profile.Age,
                height = profile.Height,
                weight = profile.Weight,
                gender = profile.Gender,
                goal = profile.Goal,
                bmi = profile.Bmi,
                phanLoai = HealthUtils.PhanLoaiBmi(profile.Bmi),
                activityLevel = profile.ActivityLevel,
                dailyCalorieGoal = profile.DailyCalorieGoal,
                walletAddress = profile.WalletAddress,
                gymCoinBalance = profile.GymCoinBalance
            });
        }
    }
}