using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Services;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using SmartGymAPI.Models;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class BlockchainController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public BlockchainController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost("create-wallet")]
        public async Task<IActionResult> CreateWallet()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var profile = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.UserId == userId);

            if (profile == null)
            {
                return BadRequest(new { success = false, message = "Vui lòng tạo hồ sơ sức khỏe trước." });
            }

            if (!string.IsNullOrEmpty(profile.WalletAddress))
            {
                return BadRequest(new { success = false, message = "Bạn đã có ví rồi!" });
            }

            var wallet = BlockchainService.GenerateWallet();
            profile.WalletAddress = wallet.Address;
            profile.PrivateKey = wallet.PrivateKey;
            profile.GymCoinBalance = 100; // Tặng ngay 100 GYM làm quà tân thủ

            // Lưu lịch sử nhận quà
            var transaction = new GymCoinTransaction
            {
                UserId = userId,
                Amount = 100,
                Type = "Earn",
                Description = "Quà tặng tạo ví thành viên mới",
                CreatedAt = DateTime.UtcNow
            };
            _context.GymCoinTransactions.Add(transaction);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                address = wallet.Address,
                message = "Tạo ví thành công!"
            });
        }

        [HttpGet("balance/{address}")]
        public async Task<IActionResult> GetBalance(string address)
        {
            var profile = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.WalletAddress == address);
            if (profile == null)
            {
                return Ok(new { balance = 0 });
            }

            return Ok(new { balance = profile.GymCoinBalance });
        }

        [HttpGet("history")]
        public async Task<IActionResult> GetHistory()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var transactions = await _context.GymCoinTransactions
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return Ok(transactions);
        }

        [HttpPost("daily-checkin")]
        public async Task<IActionResult> DailyCheckIn()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var today = DateTime.UtcNow.Date;

            // Kiểm tra đã điểm danh chưa
            var hasCheckedIn = await _context.GymCoinTransactions
                .AnyAsync(t => t.UserId == userId && t.Type == "DailyLogin" && t.CreatedAt >= today);

            if (hasCheckedIn)
            {
                return BadRequest(new { message = "Hôm nay bạn đã điểm danh rồi! Quay lại vào ngày mai nhé." });
            }

            var profile = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.UserId == userId);
            if (profile == null) return BadRequest(new { message = "Chưa có hồ sơ." });

            decimal reward = 10; // Thưởng 10 xu
            profile.GymCoinBalance += reward;

            _context.GymCoinTransactions.Add(new GymCoinTransaction
            {
                UserId = userId,
                Amount = reward,
                Type = "DailyLogin",
                Description = "Điểm danh hàng ngày",
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();

            return Ok(new { success = true, balance = profile.GymCoinBalance, message = $"Điểm danh thành công! Nhận {reward} GymCoin." });
        }
    }
}
