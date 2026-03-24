using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.DTOs;
using SmartGymAPI.Models;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SleepController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<SleepController> _logger;

        public SleepController(ApplicationDbContext context, ILogger<SleepController> logger)
        {
            _context = context;
            _logger = logger;
        }

        private string GetUserId() => User.FindFirstValue(ClaimTypes.NameIdentifier)!;

        [HttpPost]
        public async Task<IActionResult> AddSleep([FromBody] SleepDto dto)
        {
            var userId = GetUserId();

            // Logging received DTO for debugging
            _logger.LogInformation("[DEBUG] AddSleep gọi. UserId={UserId} dto.StartAt={StartAt} dto.EndAt={EndAt} dto.Type={Type}",
                userId, dto?.StartAt, dto?.EndAt, dto?.Type);

            if (dto == null) return BadRequest(new { message = "Yêu cầu không hợp lệ: cần dữ liệu trong body." });

            DateTime startUtc;
            try
            {
                startUtc = dto.StartAt.ToUniversalTime();
            }
            catch (Exception ex)
            {
                _logger.LogWarning("[WARN] Không parse được StartAt: {Ex}", ex.Message);
                return BadRequest(new { message = "Định dạng StartAt không hợp lệ." });
            }

            DateTime? endUtc = null;
            if (dto.EndAt.HasValue)
            {
                try
                {
                    endUtc = dto.EndAt.Value.ToUniversalTime();
                }
                catch (Exception ex)
                {
                    _logger.LogWarning("[WARN] Không parse được EndAt: {Ex}", ex.Message);
                    return BadRequest(new { message = "Định dạng EndAt không hợp lệ." });
                }
            }

            _logger.LogInformation("[DEBUG] Chuyển sang UTC. startUtc={StartUtc} endUtc={EndUtc}", startUtc, endUtc);

            if (endUtc.HasValue && endUtc <= startUtc)
                return BadRequest(new { message = "Thời điểm kết thúc phải lớn hơn thời điểm bắt đầu." });

            var duration = endUtc.HasValue ? (int)Math.Round((endUtc.Value - startUtc).TotalMinutes) : 0;
            if (duration < 0) duration = 0;
            if (duration > 24 * 60) return BadRequest(new { message = "Thời lượng quá dài (vượt quá 24 giờ)." });

            // NOTE: Overlap check commented out temporarily for debugging.
            /*
            var overlap = await _context.SleepRecords
                .Where(s => s.UserId == userId && s.EndAt != null)
                .AnyAsync(s => !(s.EndAt <= startUtc || s.StartAt >= (endUtc ?? startUtc)));
            if (overlap)
            {
                return BadRequest(new { message = "Bản ghi mới trùng lặp với bản ghi hiện có." });
            }
            */

            var rec = new SleepRecord
            {
                UserId = userId,
                StartAt = startUtc,
                EndAt = endUtc,
                DurationMinutes = duration,
                Type = string.IsNullOrWhiteSpace(dto.Type) ? "Night" : dto.Type,
                CreatedAt = DateTime.UtcNow
            };

            try
            {
                _context.SleepRecords.Add(rec);
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[ERROR] Lỗi khi lưu bản ghi trong AddSleep cho UserId={UserId}", userId);
                return StatusCode(500, new { message = "Lỗi máy chủ khi lưu bản ghi." });
            }

            _logger.LogInformation("[INFO] Tạo bản ghi giấc ngủ thành công. Id={Id} UserId={UserId} StartAt={StartAt} EndAt={EndAt}",
                rec.Id, rec.UserId, rec.StartAt, rec.EndAt);

            return CreatedAtAction(nameof(GetById), new { id = rec.Id }, rec);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            var rec = await _context.SleepRecords.FirstOrDefaultAsync(s => s.Id == id && s.UserId == userId);
            if (rec == null) return NotFound(new { message = "Không tìm thấy bản ghi." });
            return Ok(rec);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var userId = GetUserId();
            var list = await _context.SleepRecords
                .Where(s => s.UserId == userId)
                .OrderByDescending(s => s.StartAt)
                .ToListAsync();
            return Ok(list);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateSleepDto dto)
        {
            var userId = GetUserId();
            var rec = await _context.SleepRecords.FirstOrDefaultAsync(s => s.Id == id && s.UserId == userId);
            if (rec == null) return NotFound(new { message = "Không tìm thấy bản ghi." });

            if (dto.StartAt.HasValue)
            {
                try
                {
                    rec.StartAt = dto.StartAt.Value.ToUniversalTime();
                }
                catch (Exception ex)
                {
                    _logger.LogWarning("[WARN] Không parse được StartAt khi cập nhật: {Ex}", ex.Message);
                    return BadRequest(new { message = "Định dạng StartAt không hợp lệ." });
                }
            }

            if (dto.EndAt.HasValue)
            {
                try
                {
                    rec.EndAt = dto.EndAt.Value.ToUniversalTime();
                }
                catch (Exception ex)
                {
                    _logger.LogWarning("[WARN] Không parse được EndAt khi cập nhật: {Ex}", ex.Message);
                    return BadRequest(new { message = "Định dạng EndAt không hợp lệ." });
                }
            }

            if (!string.IsNullOrWhiteSpace(dto.Type)) rec.Type = dto.Type!;

            if (rec.EndAt.HasValue && rec.EndAt <= rec.StartAt)
                return BadRequest(new { message = "Thời điểm kết thúc phải lớn hơn thời điểm bắt đầu." });

            rec.DurationMinutes = rec.EndAt.HasValue
                ? (int)Math.Round((rec.EndAt.Value - rec.StartAt).TotalMinutes)
                : 0;

            if (rec.DurationMinutes > 24 * 60) return BadRequest(new { message = "Thời lượng quá dài (vượt quá 24 giờ)." });

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[ERROR] Lỗi khi cập nhật bản ghi Id={Id} UserId={UserId}", id, userId);
                return StatusCode(500, new { message = "Lỗi máy chủ khi cập nhật bản ghi." });
            }

            return Ok(rec);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            var rec = await _context.SleepRecords.FirstOrDefaultAsync(s => s.Id == id && s.UserId == userId);
            if (rec == null) return NotFound(new { message = "Không tìm thấy bản ghi." });

            _context.SleepRecords.Remove(rec);
            try
            {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[ERROR] Lỗi khi xóa bản ghi Id={Id} UserId={UserId}", id, userId);
                return StatusCode(500, new { message = "Lỗi máy chủ khi xóa bản ghi." });
            }

            return Ok(new { message = "Đã xóa bản ghi." });
        }

        [HttpGet("today")]
        public async Task<IActionResult> GetToday()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;
            var list = await _context.SleepRecords
                .Where(s => s.UserId == userId && s.StartAt.Date == today)
                .ToListAsync();
            var totalMinutes = list.Sum(s => s.DurationMinutes);
            return Ok(new { date = today, totalMinutes, records = list });
        }

        [HttpGet("last7days")]
        public async Task<IActionResult> GetLast7Days()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;
            var startDay = today.AddDays(-6);
            var data = await _context.SleepRecords
                .Where(s => s.UserId == userId && s.StartAt.Date >= startDay)
                .GroupBy(s => s.StartAt.Date)
                .Select(g => new { date = g.Key, totalMinutes = g.Sum(x => x.DurationMinutes) })
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
            var data = await _context.SleepRecords
                .Where(s => s.UserId == userId && s.StartAt.Date >= startDay)
                .GroupBy(s => s.StartAt.Date)
                .Select(g => new { date = g.Key, totalMinutes = g.Sum(x => x.DurationMinutes) })
                .OrderBy(x => x.date)
                .ToListAsync();
            return Ok(data);
        }

        [HttpGet("progress-today")]
        public async Task<IActionResult> GetProgressToday()
        {
            var userId = GetUserId();
            var today = DateTime.UtcNow.Date;
            var totalMinutes = await _context.SleepRecords
                .Where(s => s.UserId == userId && s.StartAt.Date == today)
                .SumAsync(s => s.DurationMinutes);

            int nightlyGoal = 480; // mặc định 8 giờ
            var profile = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.UserId == userId);
            if (profile != null)
            {
                // nếu có trường sleep goal trong profile, có thể gán nightlyGoal = profile.SleepGoalMinutes;
            }

            double percent = nightlyGoal > 0 ? (totalMinutes / (double)nightlyGoal) * 100.0 : 0.0;

            return Ok(new
            {
                date = today,
                totalMinutes,
                nightlyGoal,
                progressPercent = Math.Round(percent, 2)
            });
        }
    }
}