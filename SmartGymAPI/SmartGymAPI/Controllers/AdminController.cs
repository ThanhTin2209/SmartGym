using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using System.Linq;
using System.Threading.Tasks;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")] // Requires Admin Role
    public class AdminController : ControllerBase
    {
        private readonly UserManager<IdentityUser> _userManager;
        private readonly ApplicationDbContext _context;

        public AdminController(UserManager<IdentityUser> userManager, ApplicationDbContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        // GET: api/admin/dashboard
        [HttpGet("dashboard")]
        public async Task<IActionResult> GetDashboardStats()
        {
            var totalUsers = await _userManager.Users.CountAsync();
            var totalExercises = await _context.ExerciseRecords.CountAsync();
            var totalTemplates = await _context.ExerciseTemplates.CountAsync();
            var totalMeals = await _context.MealTemplates.CountAsync();

            return Ok(new
            {
                TotalUsers = totalUsers,
                TotalExerciseRecords = totalExercises,
                TotalExerciseTemplates = totalTemplates,
                TotalMealTemplates = totalMeals,
                SystemStatus = "Healthy",
                DbConnection = "OK"
            });
        }

        // GET: api/admin/users
        [HttpGet("users")]
        public async Task<IActionResult> GetAllUsers()
        {
            var users = await _userManager.Users.ToListAsync();
            var userList = new List<object>();

            foreach (var user in users)
            {
                var roles = await _userManager.GetRolesAsync(user);
                userList.Add(new
                {
                    user.Id,
                    user.UserName,
                    user.Email,
                    user.EmailConfirmed,
                    user.LockoutEnd,
                    Roles = roles
                });
            }

            return Ok(userList);
        }

        // POST: api/admin/users/lock/{id}
        [HttpPost("users/lock/{id}")]
        public async Task<IActionResult> LockUser(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null) return NotFound();

            // Lock for 100 years
            await _userManager.SetLockoutEndDateAsync(user, DateTimeOffset.UtcNow.AddYears(100));
            return Ok(new { message = $"Đã khóa tài khoản {user.UserName}." });
        }

        // POST: api/admin/users/unlock/{id}
        [HttpPost("users/unlock/{id}")]
        public async Task<IActionResult> UnlockUser(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null) return NotFound();

            await _userManager.SetLockoutEndDateAsync(user, null);
            return Ok(new { message = $"Đã mở khóa tài khoản {user.UserName}." });
        }

        // POST: api/admin/users/role
        [HttpPost("users/role")]
        public async Task<IActionResult> ChangeUserRole([FromBody] ChangeRoleDto model)
        {
            var user = await _userManager.FindByIdAsync(model.UserId);
            if (user == null) return NotFound(new { message = "User not found" });

            var currentRoles = await _userManager.GetRolesAsync(user);
            
            // Remove all current roles
            var removeResult = await _userManager.RemoveFromRolesAsync(user, currentRoles);
            if (!removeResult.Succeeded) return BadRequest(new { message = "Failed to remove current roles" });

            // Add new role
            var addResult = await _userManager.AddToRoleAsync(user, model.NewRole);
            if (addResult.Succeeded)
            {
                return Ok(new { message = $"Đã cập nhật quyền thành {model.NewRole} cho {user.UserName}" });
            }

            return BadRequest(addResult.Errors);
        }

        // DELETE: api/admin/users/{id}
        [HttpDelete("users/{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null) return NotFound();

            var result = await _userManager.DeleteAsync(user);
            if (result.Succeeded)
            {
                return Ok(new { message = $"Đã xóa tài khoản {user.UserName}." });
            }
            return BadRequest(result.Errors);
        }

        // ==================== DATA MANAGEMENT ====================

        // GET: api/admin/data/exercises
        [HttpGet("data/exercises")]
        public async Task<IActionResult> GetAllExercises()
        {
            var exercises = await (from e in _context.ExerciseRecords
                                   join u in _context.Users on e.UserId equals u.Id
                                   orderby e.Date descending
                                   select new
                                   {
                                       e.Id,
                                       e.UserId,
                                       UserName = u.UserName,
                                       e.ExerciseName,
                                       e.Category,
                                       e.DurationSeconds,
                                       e.CaloriesBurned,
                                       e.Date
                                   }).ToListAsync();

            return Ok(exercises);
        }

        // GET: api/admin/data/nutrition
        [HttpGet("data/nutrition")]
        public async Task<IActionResult> GetAllNutrition()
        {
            var nutrition = await (from n in _context.NutritionRecords
                                   join u in _context.Users on n.UserId equals u.Id
                                   orderby n.Date descending
                                   select new
                                   {
                                       n.Id,
                                       n.UserId,
                                       UserName = u.UserName,
                                       n.MealType,
                                       n.Calories,
                                       n.Protein,
                                       n.Carbs,
                                       n.Fat,
                                       n.MealSlot,
                                       n.Date
                                   }).ToListAsync();

            return Ok(nutrition);
        }

        // GET: api/admin/data/sleep
        [HttpGet("data/sleep")]
        public async Task<IActionResult> GetAllSleep()
        {
            var sleep = await (from s in _context.SleepRecords
                               join u in _context.Users on s.UserId equals u.Id
                               orderby s.StartAt descending
                               select new
                               {
                                   s.Id,
                                   s.UserId,
                                   UserName = u.UserName,
                                   s.DurationMinutes,
                                   s.Type,
                                   Date = s.StartAt
                               }).ToListAsync();

            return Ok(sleep);
        }

        // GET: api/admin/data/water
        [HttpGet("data/water")]
        public async Task<IActionResult> GetAllWater()
        {
            var water = await (from w in _context.WaterIntakes
                               join u in _context.Users on w.UserId equals u.Id
                               orderby w.Date descending
                               select new
                               {
                                   w.Id,
                                   w.UserId,
                                   UserName = u.UserName,
                                   Amount = w.Amount,
                                   w.Date
                               }).ToListAsync();

            return Ok(water);
        }

        // DELETE: api/admin/data/exercise/{id}
        [HttpDelete("data/exercise/{id}")]
        public async Task<IActionResult> DeleteExercise(int id)
        {
            var record = await _context.ExerciseRecords.FindAsync(id);
            if (record == null) return NotFound();

            _context.ExerciseRecords.Remove(record);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa bản ghi tập luyện" });
        }

        // DELETE: api/admin/data/nutrition/{id}
        [HttpDelete("data/nutrition/{id}")]
        public async Task<IActionResult> DeleteNutrition(int id)
        {
            var record = await _context.NutritionRecords.FindAsync(id);
            if (record == null) return NotFound();

            _context.NutritionRecords.Remove(record);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa bản ghi dinh dưỡng" });
        }

        // DELETE: api/admin/data/sleep/{id}
        [HttpDelete("data/sleep/{id}")]
        public async Task<IActionResult> DeleteSleep(int id)
        {
            var record = await _context.SleepRecords.FindAsync(id);
            if (record == null) return NotFound();

            _context.SleepRecords.Remove(record);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa bản ghi giấc ngủ" });
        }

        // DELETE: api/admin/data/water/{id}
        [HttpDelete("data/water/{id}")]
        public async Task<IActionResult> DeleteWater(int id)
        {
            var record = await _context.WaterIntakes.FindAsync(id);
            if (record == null) return NotFound();

            _context.WaterIntakes.Remove(record);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa bản ghi nước uống" });
        }

        // ==================== SETTINGS & BACKUP ====================

        // GET: api/admin/settings
        [HttpGet("settings")]
        public async Task<IActionResult> GetSettings()
        {
            var totalUsers = await _userManager.Users.CountAsync();
            var totalExerciseRecords = await _context.ExerciseRecords.CountAsync();
            var totalNutritionRecords = await _context.NutritionRecords.CountAsync();
            var totalSleepRecords = await _context.SleepRecords.CountAsync();
            var totalWaterRecords = await _context.WaterIntakes.CountAsync();
            var totalExerciseTemplates = await _context.ExerciseTemplates.CountAsync();
            var totalMealTemplates = await _context.MealTemplates.CountAsync();

            return Ok(new
            {
                TotalUsers = totalUsers,
                TotalExerciseRecords = totalExerciseRecords,
                TotalNutritionRecords = totalNutritionRecords,
                TotalSleepRecords = totalSleepRecords,
                TotalWaterRecords = totalWaterRecords,
                TotalExerciseTemplates = totalExerciseTemplates,
                TotalMealTemplates = totalMealTemplates,
                ServerTime = DateTime.UtcNow
            });
        }

        // POST: api/admin/backup/export
        [HttpPost("backup/export")]
        public async Task<IActionResult> ExportBackup()
        {
            var exercises = await _context.ExerciseRecords.ToListAsync();
            var nutrition = await _context.NutritionRecords.ToListAsync();
            var sleep = await _context.SleepRecords.ToListAsync();
            var water = await _context.WaterIntakes.ToListAsync();

            var backup = new
            {
                ExportDate = DateTime.UtcNow,
                ExerciseRecords = exercises,
                NutritionRecords = nutrition,
                SleepRecords = sleep,
                WaterIntakes = water
            };

            return Ok(backup);
        }

        // DELETE: api/admin/data/clear-all
        [HttpDelete("data/clear-all")]
        public async Task<IActionResult> ClearAllData()
        {
            // Remove all user data records
            _context.ExerciseRecords.RemoveRange(_context.ExerciseRecords);
            _context.NutritionRecords.RemoveRange(_context.NutritionRecords);
            _context.SleepRecords.RemoveRange(_context.SleepRecords);
            _context.WaterIntakes.RemoveRange(_context.WaterIntakes);

            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã xóa toàn bộ dữ liệu người dùng" });
        }
    }

    public class ChangeRoleDto
    {
        public string UserId { get; set; }
        public string NewRole { get; set; } // "Admin" or "User"
    }
}
