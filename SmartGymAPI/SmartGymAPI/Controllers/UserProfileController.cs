using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using SmartGymAPI.Data;
using SmartGymAPI.Models;
using System.Linq;
using System.Threading.Tasks;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UserProfileController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<IdentityUser> _userManager;

        public UserProfileController(ApplicationDbContext context, UserManager<IdentityUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // POST: api/UserProfile
        [HttpPost]
        public async Task<IActionResult> CreateProfile([FromBody] UserProfile model)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            var existing = _context.UserProfiles.FirstOrDefault(p => p.UserId == user.Id);
            if (existing != null)
                return BadRequest(new { message = "Hồ sơ đã tồn tại." });

            model.UserId = user.Id;
            _context.UserProfiles.Add(model);
            await _context.SaveChangesAsync();

            return Ok(new { success = true, message = "Đã lưu thông tin cá nhân thành công!" });
        }

        // GET: api/UserProfile
        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            var profile = _context.UserProfiles.FirstOrDefault(p => p.UserId == user.Id);
            if (profile == null)
                return NotFound(new { message = "Chưa có thông tin cá nhân." });

            return Ok(profile);
        }
    }
}
