using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;
using System.Security.Claims;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class GymServiceController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public GymServiceController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/GymService
        [HttpGet]
        public async Task<ActionResult<IEnumerable<GymPackage>>> GetPackages()
        {
            return await _context.GymPackages.ToListAsync();
        }

        // GET: api/GymService/5
        [HttpGet("{id}")]
        public async Task<ActionResult<GymPackage>> GetPackage(int id)
        {
            var package = await _context.GymPackages.FindAsync(id);

            if (package == null)
            {
                return NotFound();
            }

            return package;
        }

        // POST: api/GymService (Admin only usually, but open for dev)
        [HttpPost]
        public async Task<ActionResult<GymPackage>> CreatePackage(GymPackage gymPackage)
        {
            _context.GymPackages.Add(gymPackage);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetPackage", new { id = gymPackage.Id }, gymPackage);
        }

        // DTO cho yêu cầu đăng ký
        public class SubscribeRequest
        {
            public bool UseGymCoins { get; set; } = false;
            public decimal? CoinsToUse { get; set; }
        }

        // POST: api/GymService/subscribe/{id}
        [HttpPost("subscribe/{id}")]
        [Authorize]
        public async Task<IActionResult> Subscribe(int id, [FromBody] SubscribeRequest request)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var package = await _context.GymPackages.FindAsync(id);
            if (package == null) return NotFound("Gói tập không tồn tại");

            var profile = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.UserId == userId);
            if (profile == null) return BadRequest("Chưa có hồ sơ sức khỏe");

            decimal finalPrice = package.Price;
            decimal discount = 0;
            decimal coinsToUse = 0;

            // Logic tính giảm giá bằng GymCoin
            if (profile.GymCoinBalance > 0)
            {
                // Quy đổi: 100 GymCoin = 5,000 VND => 1 Coin = 50 VND
                decimal coinValueVnd = 50;
                
                // Giới hạn: Chỉ cho phép thanh toán tối đa 50% giá trị gói bằng Coin
                decimal maxDiscount = package.Price * 0.5m;
                decimal maxCoinsAllowed = maxDiscount / coinValueVnd;

                decimal requestedCoins = 0;
                if (request.CoinsToUse.HasValue && request.CoinsToUse.Value > 0)
                {
                    requestedCoins = request.CoinsToUse.Value;
                }
                else if (request.UseGymCoins)
                {
                    requestedCoins = profile.GymCoinBalance; // Mặc định dùng hết nếu chỉ gửi flag boolean
                }

                if (requestedCoins > 0)
                {
                   // Cap amountToUse by Balance
                   decimal amountToUse = Math.Min(requestedCoins, profile.GymCoinBalance);

                   // Cap by Max Discount Limit
                   amountToUse = Math.Min(amountToUse, maxCoinsAllowed);

                   coinsToUse = amountToUse;
                   discount = coinsToUse * coinValueVnd;
                   finalPrice = package.Price - discount;
                }
            }

            // Xử lý giao dịch (Trừ Coin)
            if (coinsToUse > 0)
            {
                profile.GymCoinBalance -= coinsToUse;

                // Lưu lịch sử tiêu dùng
                var transaction = new GymCoinTransaction
                {
                    UserId = userId,
                    Amount = -coinsToUse, // Số âm thể hiện việc chi tiêu
                    Type = "Spend",
                    Description = $"Đổi Voucher giảm giá cho gói {package.Name} (-{discount:N0}đ)",
                    CreatedAt = DateTime.UtcNow
                };
                _context.GymCoinTransactions.Add(transaction);
                
                // Cập nhật Profile
                _context.HealthProfiles.Update(profile);
            }

            // TODO: Tích hợp Payment Gateway (VietQR/Momo) cho số tiền còn lại (finalPrice)
            // Ở đây tạm thời giả lập thanh toán thành công
            
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Đăng ký thành công!",
                packageName = package.Name,
                originalPrice = package.Price,
                discount = discount,
                coinsUsed = coinsToUse,
                finalPrice = finalPrice,
                note = coinsToUse > 0 ? $"Bạn đã dùng {coinsToUse:N0} GymCoin để giảm {discount:N0} VND" : "Không dùng GymCoin"
            });
        }

        // PUT: api/GymService/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutPackage(int id, GymPackage gymPackage)
        {
            if (id != gymPackage.Id) return BadRequest();

            _context.Entry(gymPackage).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.GymPackages.Any(e => e.Id == id)) return NotFound();
                else throw;
            }

            return NoContent();
        }

        // DELETE: api/GymService/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePackage(int id)
        {
            var package = await _context.GymPackages.FindAsync(id);
            if (package == null) return NotFound();

            _context.GymPackages.Remove(package);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
