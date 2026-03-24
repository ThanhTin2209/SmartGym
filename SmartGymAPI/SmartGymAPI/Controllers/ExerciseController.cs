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
    public class ExerciseController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ExerciseController> _logger;

        public ExerciseController(ApplicationDbContext context, ILogger<ExerciseController> logger)
        {
            _context = context;
            _logger = logger;
        }

        private string? GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        // POST: /api/exercise
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ExerciseDto dto)
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            if (dto == null || string.IsNullOrWhiteSpace(dto.ExerciseName))
                return BadRequest(new { message = "Invalid payload: ExerciseName required" });

            if (dto.DurationSeconds < 0)
                return BadRequest(new { message = "Invalid payload: DurationSeconds must be >= 0" });

            var profile = await _context.HealthProfiles.AsNoTracking().FirstOrDefaultAsync(h => h.UserId == userId);
            double? weightForCalc = dto.WeightKg ?? profile?.Weight;
            double weightUsed = weightForCalc ?? 70.0;

            double? finalCalories;
            string finalSource;

            if (dto.CaloriesBurned.HasValue)
            {
                finalCalories = dto.CaloriesBurned.Value;
                finalSource = string.IsNullOrWhiteSpace(dto.CaloriesSource) ? "user" : dto.CaloriesSource;
                var met = GetMet(dto.Category);
                var serverEstimate = EstimateCalories(met, weightUsed, dto.DurationSeconds);
                if (serverEstimate > 0)
                {
                    var diff = Math.Abs(finalCalories.Value - serverEstimate);
                    if (serverEstimate > 0 && diff / serverEstimate > 0.3)
                    {
                        _logger.LogInformation("Client calories differs >30% from server estimate. userId={UserId}, client={Client}, server={Server}, exercise={ExerciseName}",
                            userId, finalCalories.Value, serverEstimate, dto.ExerciseName);
                    }
                }
            }
            else
            {
                var met = GetMet(dto.Category);
                finalCalories = EstimateCalories(met, weightUsed, dto.DurationSeconds);
                finalSource = "server_compute";
            }

            // Normalize incoming date to UTC
            DateTime timestampUtc;
            if (dto.Date.HasValue)
            {
                var incoming = dto.Date.Value;
                if (incoming.Kind == DateTimeKind.Utc)
                    timestampUtc = incoming;
                else if (incoming.Kind == DateTimeKind.Local)
                    timestampUtc = incoming.ToUniversalTime();
                else
                    timestampUtc = DateTime.SpecifyKind(incoming, DateTimeKind.Local).ToUniversalTime();
            }
            else
            {
                timestampUtc = DateTime.UtcNow;
            }

            _logger.LogDebug("Create Exercise: userId={UserId}, incomingDate={Incoming}, storedUtc={StoredUtc}",
                userId, dto.Date?.ToString("o") ?? "(null)", timestampUtc.ToString("o"));

            var rec = new ExerciseRecord
            {
                UserId = userId,
                ExerciseName = dto.ExerciseName,
                Category = dto.Category,
                DurationSeconds = dto.DurationSeconds,
                Sets = dto.Sets,
                Reps = dto.Reps,
                WeightKg = dto.WeightKg,
                CaloriesBurned = finalCalories,
                CaloriesSource = finalSource,
                WeightUsedForCalories = weightForCalc,
                Date = timestampUtc,
                Notes = dto.Notes
            };

            try
            {
                _context.ExerciseRecords.Add(rec);

                // --- LOGIC TÍNH ĐIỂM GYM COIN (ANTI-CHEAT) ---
                // Quy đổi: 100 Calories = 1 GymCoin
                if (finalCalories.HasValue && finalCalories.Value > 0)
                {
                    // 1. Anti-Cheat: Kiểm tra tốc độ đốt calo (Burn Rate Check)
                    // Giới hạn hợp lý: Tối đa 20 kcal/phút (VĐV chuyên nghiệp cường độ cao cũng khó vượt qua)
                    double durationMin = (rec.DurationSeconds > 0) ? rec.DurationSeconds / 60.0 : 0;
                    double maxReasonableCalories = durationMin * 20.0;
                    
                    // Nếu không có thời gian tập, chỉ cho tối đa 100 kcal (1 coin) để tránh spam
                    if (durationMin <= 0) maxReasonableCalories = 100;

                    // Số calo hợp lệ để tính tiền (chặn gian lận nhập 10000 kcal trong 1 phút)
                    double validCaloriesForCoins = 0;
                    
                    if (finalCalories.Value > maxReasonableCalories)
                    {
                        validCaloriesForCoins = maxReasonableCalories; // Cap lại
                    }
                    else
                    {
                        validCaloriesForCoins = finalCalories.Value;
                    }

                    // 2. Tính xu
                    double coinsEarned = Math.Floor(validCaloriesForCoins / 100.0);

                    // 3. Daily Cap Check (Giới hạn ngày: 50 Xu)
                    if (coinsEarned > 0)
                    {
                        var startOfToday = DateTime.UtcNow.Date;
                        var earnedToday = await _context.GymCoinTransactions
                            .Where(t => t.UserId == userId && t.Type == "Earn" && t.CreatedAt >= startOfToday)
                            .SumAsync(t => t.Amount);

                        decimal maxDaily = 50;
                        decimal remaining = maxDaily - earnedToday;

                        if (remaining <= 0)
                        {
                            coinsEarned = 0; // Hết lượt trong ngày
                        }
                        else if ((decimal)coinsEarned > remaining)
                        {
                            coinsEarned = (double)remaining; // Chỉ nhận phần còn lại
                        }
                    }

                    if (coinsEarned > 0)
                    {
                        var profileForUpdate = await _context.HealthProfiles.FirstOrDefaultAsync(h => h.UserId == userId);
                        if (profileForUpdate != null)
                        {
                            // Cộng tiền
                            profileForUpdate.GymCoinBalance = profileForUpdate.GymCoinBalance + (decimal)coinsEarned;

                            // Ghi chú nếu bị cắt giảm
                            string note = "";
                            if (validCaloriesForCoins < finalCalories.Value)
                            {
                                note = $" (Calo điều chỉnh từ {finalCalories.Value})";
                            }
                            
                            // Lưu lịch sử
                            var history = new GymCoinTransaction
                            {
                                UserId = userId,
                                Amount = (decimal)coinsEarned,
                                Type = "Earn",
                                Description = $"Tập luyện: {dto.ExerciseName} ({Math.Round(validCaloriesForCoins)} kcal){note}",
                                CreatedAt = DateTime.UtcNow
                            };
                            _context.GymCoinTransactions.Add(history);
                        }
                    }
                }
                // --- KẾT THÚC LOGIC GYM COIN ---

                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to save new ExerciseRecord for user {UserId}", userId);
                return StatusCode(500, new { message = "Failed to save exercise record" });
            }

            var createdDto = new ExerciseDto
            {
                ExerciseName = rec.ExerciseName,
                Category = rec.Category,
                DurationSeconds = rec.DurationSeconds,
                Sets = rec.Sets,
                Reps = rec.Reps,
                WeightKg = rec.WeightKg,
                CaloriesBurned = rec.CaloriesBurned,
                CaloriesSource = rec.CaloriesSource,
                Date = DateTime.SpecifyKind(rec.Date, DateTimeKind.Utc),
                Notes = rec.Notes
            };

            return CreatedAtAction(nameof(GetById), new { id = rec.Id }, createdDto);
        }

        // GET: /api/exercise/{id}
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var rec = await _context.ExerciseRecords.AsNoTracking().FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId);
            if (rec == null) return NotFound();

            var dto = new ExerciseDto
            {
                ExerciseName = rec.ExerciseName,
                Category = rec.Category,
                DurationSeconds = rec.DurationSeconds,
                Sets = rec.Sets,
                Reps = rec.Reps,
                WeightKg = rec.WeightKg,
                CaloriesBurned = rec.CaloriesBurned,
                CaloriesSource = rec.CaloriesSource,
                Date = DateTime.SpecifyKind(rec.Date, DateTimeKind.Utc),
                Notes = rec.Notes
            };

            return Ok(dto);
        }

        // GET: /api/exercise?date=... or ?start=...&end=...
        [HttpGet]
        public async Task<IActionResult> GetByDate([FromQuery] string? date, [FromQuery] string? start, [FromQuery] string? end)
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            IQueryable<ExerciseRecord> q = _context.ExerciseRecords.Where(e => e.UserId == userId);

            DateTime utcStart;
            DateTime utcEnd;

            if (!string.IsNullOrEmpty(start) && !string.IsNullOrEmpty(end))
            {
                if (DateTimeOffset.TryParse(start, out var sOff) && DateTimeOffset.TryParse(end, out var eOff))
                {
                    utcStart = sOff.ToUniversalTime().UtcDateTime;
                    utcEnd = eOff.ToUniversalTime().UtcDateTime;
                }
                else
                {
                    return BadRequest(new { message = "Invalid start/end format. Use ISO 8601." });
                }
            }
            else if (!string.IsNullOrEmpty(date))
            {
                if (DateTimeOffset.TryParse(date, out var dOff))
                {
                    var localStart = new DateTimeOffset(dOff.Year, dOff.Month, dOff.Day, 0, 0, 0, dOff.Offset);
                    var localEnd = localStart.AddDays(1);
                    utcStart = localStart.ToUniversalTime().UtcDateTime;
                    utcEnd = localEnd.ToUniversalTime().UtcDateTime;
                }
                else if (DateTime.TryParse(date, out var d))
                {
                    var localStart = new DateTime(d.Year, d.Month, d.Day, 0, 0, 0, DateTimeKind.Local);
                    var localEnd = localStart.AddDays(1);
                    utcStart = localStart.ToUniversalTime();
                    utcEnd = localEnd.ToUniversalTime();
                }
                else
                {
                    return BadRequest(new { message = "Invalid date format. Use ISO 8601 or yyyy-MM-dd." });
                }
            }
            else
            {
                var localToday = DateTime.Now.Date;
                var localStart = new DateTime(localToday.Year, localToday.Month, localToday.Day, 0, 0, 0, DateTimeKind.Local);
                var localEnd = localStart.AddDays(1);
                utcStart = localStart.ToUniversalTime();
                utcEnd = localEnd.ToUniversalTime();
            }

            _logger.LogDebug("GetByDate: userId={UserId}, utcStart={Start}, utcEnd={End}", userId, utcStart.ToString("o"), utcEnd.ToString("o"));

            var list = await q
                .Where(x => x.Date >= utcStart && x.Date < utcEnd)
                .OrderByDescending(e => e.Date)
                .AsNoTracking()
                .ToListAsync();

            var result = list.Select(x => new ExerciseDto
            {
                ExerciseName = x.ExerciseName,
                Category = x.Category,
                DurationSeconds = x.DurationSeconds,
                Sets = x.Sets,
                Reps = x.Reps,
                WeightKg = x.WeightKg,
                CaloriesBurned = x.CaloriesBurned,
                CaloriesSource = x.CaloriesSource,
                Date = DateTime.SpecifyKind(x.Date, DateTimeKind.Utc),
                Notes = x.Notes
            }).ToList();

            return Ok(result);
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromBody] ExerciseDto dto)
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var rec = await _context.ExerciseRecords.FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId);
            if (rec == null) return NotFound();

            if (string.IsNullOrWhiteSpace(dto.ExerciseName))
                return BadRequest(new { message = "Invalid payload: ExerciseName required" });
            if (dto.DurationSeconds < 0)
                return BadRequest(new { message = "Invalid payload: DurationSeconds must be >= 0" });

            rec.ExerciseName = dto.ExerciseName;
            rec.Category = dto.Category;
            rec.DurationSeconds = dto.DurationSeconds;
            rec.Sets = dto.Sets;
            rec.Reps = dto.Reps;
            rec.WeightKg = dto.WeightKg;

            if (dto.Date.HasValue)
            {
                var incoming = dto.Date.Value;
                if (incoming.Kind == DateTimeKind.Utc)
                    rec.Date = incoming;
                else if (incoming.Kind == DateTimeKind.Local)
                    rec.Date = incoming.ToUniversalTime();
                else
                    rec.Date = DateTime.SpecifyKind(incoming, DateTimeKind.Local).ToUniversalTime();
            }

            rec.Notes = dto.Notes;

            var profile = await _context.HealthProfiles.AsNoTracking().FirstOrDefaultAsync(h => h.UserId == userId);
            double? weightForCalc = rec.WeightKg ?? profile?.Weight;
            double weightUsed = weightForCalc ?? 70.0;

            if (dto.CaloriesBurned.HasValue)
            {
                rec.CaloriesBurned = dto.CaloriesBurned.Value;
                rec.CaloriesSource = string.IsNullOrWhiteSpace(dto.CaloriesSource) ? "user" : dto.CaloriesSource;
                rec.WeightUsedForCalories = weightForCalc;
            }
            else
            {
                var met = GetMet(rec.Category);
                rec.CaloriesBurned = EstimateCalories(met, weightUsed, rec.DurationSeconds);
                rec.CaloriesSource = "server_compute";
                rec.WeightUsedForCalories = weightForCalc;
            }

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to update ExerciseRecord id={Id} for user {UserId}", id, userId);
                return StatusCode(500, new { message = "Failed to update exercise record" });
            }

            var updatedDto = new ExerciseDto
            {
                ExerciseName = rec.ExerciseName,
                Category = rec.Category,
                DurationSeconds = rec.DurationSeconds,
                Sets = rec.Sets,
                Reps = rec.Reps,
                WeightKg = rec.WeightKg,
                CaloriesBurned = rec.CaloriesBurned,
                CaloriesSource = rec.CaloriesSource,
                Date = DateTime.SpecifyKind(rec.Date, DateTimeKind.Utc),
                Notes = rec.Notes
            };

            return Ok(updatedDto);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            var rec = await _context.ExerciseRecords.FirstOrDefaultAsync(e => e.Id == id && e.UserId == userId);
            if (rec == null) return NotFound();

            _context.ExerciseRecords.Remove(rec);

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to delete ExerciseRecord id={Id} for user {UserId}", id, userId);
                return StatusCode(500, new { message = "Failed to delete exercise record" });
            }

            return NoContent();
        }

        [HttpGet("summary")]
        public async Task<IActionResult> Summary([FromQuery] string? start, [FromQuery] string? end)
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            DateTime utcStart;
            DateTime utcEnd;

            if (!string.IsNullOrEmpty(start) && !string.IsNullOrEmpty(end)
                && DateTimeOffset.TryParse(start, out var sOff) && DateTimeOffset.TryParse(end, out var eOff))
            {
                utcStart = sOff.ToUniversalTime().UtcDateTime;
                utcEnd = eOff.ToUniversalTime().UtcDateTime;
            }
            else
            {
                var localEnd = DateTime.Now.Date.AddDays(1);
                var localStart = localEnd.AddDays(-7);
                utcStart = localStart.ToUniversalTime();
                utcEnd = localEnd.ToUniversalTime();
            }

            var data = await _context.ExerciseRecords
                .Where(x => x.UserId == userId && x.Date >= utcStart && x.Date < utcEnd)
                .AsNoTracking()
                .GroupBy(x => x.Date.Date)
                .Select(g => new { date = g.Key, totalDuration = g.Sum(x => x.DurationSeconds), totalCalories = g.Sum(x => x.CaloriesBurned ?? 0) })
                .OrderBy(x => x.date)
                .ToListAsync();

            return Ok(data);
        }

        // GET: /api/exercise/suggestions?availableSeconds=900&count=6
        [HttpGet("suggestions")]
        public async Task<IActionResult> Suggestions([FromQuery] int? availableSeconds, [FromQuery] int count = 6)
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            // Load user profile (BMI, age, gender, goal, level)
            var profile = await _context.HealthProfiles.AsNoTracking().FirstOrDefaultAsync(h => h.UserId == userId);
            var userProfile = await _context.UserProfiles.AsNoTracking().FirstOrDefaultAsync(u => u.UserId == userId);
            
            var goal = (profile?.Goal ?? "Maintain").ToLowerInvariant();
            var userLevel = (profile?.Level ?? "Beginner").Trim();
            var weightForCalc = profile?.Weight ?? 70.0;
            var height = profile?.Height ?? 170.0;
            var age = userProfile?.Age ?? 30;
            var gender = (userProfile?.Gender ?? "Male").ToLowerInvariant();

            // Calculate BMI
            double bmi = weightForCalc / Math.Pow(height / 100.0, 2);

            // Load templates
            var templates = await _context.ExerciseTemplates.AsNoTracking().ToListAsync();

            // Score each template based on user profile
            var scored = templates
                .Select(t =>
                {
                    var score = ScoreSuggestionSmart(t, goal, userLevel, bmi, age, gender, availableSeconds);
                    var estCalories = EstimateCalories(t.BaseMet, weightForCalc, t.DurationSeconds);
                    return new
                    {
                        Template = t,
                        Score = score,
                        EstimatedCalories = estCalories
                    };
                })
                .OrderByDescending(x => x.Score)
                .ThenByDescending(x => x.EstimatedCalories)
                .Take(Math.Max(1, Math.Min(count, 50)))
                .ToList();

            var result = scored.Select(x => new ExerciseSuggestionDto
            {
                Name = x.Template.Name,
                Category = x.Template.Category,
                DurationSeconds = x.Template.DurationSeconds,
                Intensity = x.Template.Intensity,
                EstimatedCalories = Math.Round(x.EstimatedCalories, 2),
                ReasonTag = BuildReasonTagSmart(x.Template, goal, userLevel, bmi, age, gender, availableSeconds)
            }).ToList();

            return Ok(result);
        }

        // GET: /api/exercise/progress?range=week&mode=minutes
        [HttpGet("progress")]
        public async Task<IActionResult> Progress([FromQuery] string range = "week", [FromQuery] string mode = "minutes")
        {
            var userId = GetUserId();
            if (string.IsNullOrWhiteSpace(userId)) return Unauthorized();

            // determine window
            DateTime utcStart;
            DateTime utcEnd = DateTime.UtcNow;
            var nowLocal = DateTime.Now.Date;

            switch ((range ?? "week").ToLowerInvariant())
            {
                case "day":
                    var localStartDay = new DateTime(nowLocal.Year, nowLocal.Month, nowLocal.Day, 0, 0, 0, DateTimeKind.Local);
                    utcStart = localStartDay.ToUniversalTime();
                    utcEnd = utcStart.AddDays(1);
                    break;
                case "month":
                    var firstOfMonth = new DateTime(nowLocal.Year, nowLocal.Month, 1, 0, 0, 0, DateTimeKind.Local);
                    utcStart = firstOfMonth.ToUniversalTime();
                    break;
                default: // week
                    var localEnd = nowLocal.AddDays(1);
                    utcEnd = localEnd.ToUniversalTime();
                    var localStart = localEnd.AddDays(-7);
                    utcStart = localStart.ToUniversalTime();
                    break;
            }

            // fetch records in window
            var records = await _context.ExerciseRecords
                .AsNoTracking()
                .Where(x => x.UserId == userId && x.Date >= utcStart && x.Date < utcEnd)
                .ToListAsync();

            // compute actual and target
            double actual = 0;
            double target = 0;
            var profile = await _context.HealthProfiles.AsNoTracking().FirstOrDefaultAsync(h => h.UserId == userId);
            var goal = (profile?.Goal ?? "Maintain").ToLowerInvariant();

            if ((mode ?? "minutes").ToLowerInvariant() == "calories")
            {
                actual = records.Sum(r => r.CaloriesBurned ?? 0);
                // target: derive from DailyCalorieGoal if present, else estimate from profile
                if (profile != null && profile.DailyCalorieGoal > 0)
                {
                    // target for range = dailyGoal * days
                    var days = (utcEnd - utcStart).TotalDays;
                    target = profile.DailyCalorieGoal * days;
                    // adjust by goal preference (fatloss -> lower target)
                    if (goal.Contains("fat")) target *= 0.9;
                    if (goal.Contains("muscle")) target *= 1.05;
                }
                else
                {
                    // fallback: estimate target calories burned from recommended activity minutes
                    var recommendedMinutes = ComputeRecommendedMinutes(goal, profile?.Level);
                    var estMet = 6.0; // average
                    var weight = profile?.Weight ?? 70.0;
                    target = EstimateCalories(estMet, weight, (int)(recommendedMinutes * 60));
                }
            }
            else // minutes
            {
                actual = records.Sum(r => r.DurationSeconds) / 60.0;
                target = ComputeRecommendedMinutes(goal, profile?.Level);
                // scale target by window length (if range != week)
                if ((range ?? "week").ToLowerInvariant() == "day") target = target / 7.0;
                if ((range ?? "week").ToLowerInvariant() == "month")
                {
                    var daysInMonth = DateTime.DaysInMonth(DateTime.UtcNow.Year, DateTime.UtcNow.Month);
                    target = target * (daysInMonth / 7.0);
                }
            }

            double percent = target <= 0 ? 0 : Math.Min(100.0, (actual / target) * 100.0);
            var status = percent >= 100 ? "Achieved" : (percent >= 70 ? "OnTrack" : "Behind");

            var resp = new ProgressResponseDto
            {
                Range = range,
                Percent = Math.Round(percent, 1),
                Actual = Math.Round(actual, 2),
                Target = Math.Round(target, 2),
                Unit = (mode ?? "minutes").ToLowerInvariant() == "calories" ? "kcal" : "minutes",
                Status = status
            };

            return Ok(resp);
        }

        /* ----------------- Helpers used above ----------------- */

        private double ScoreSuggestion(ExerciseTemplate t, string goal, string userLevel, int? availableSeconds)
        {
            double score = 0;

            // goal affinity
            if (goal.Contains("fat") && t.Category?.ToLowerInvariant().Contains("cardio") == true) score += 40;
            if (goal.Contains("musc") && t.Category?.ToLowerInvariant().Contains("strength") == true) score += 40;
            if (goal.Contains("maintain")) score += 20;

            // duration fit
            if (availableSeconds.HasValue && availableSeconds.Value > 0)
            {
                var diff = Math.Abs(t.DurationSeconds - availableSeconds.Value);
                var fit = Math.Max(0, 1.0 - (diff / Math.Max(availableSeconds.Value, 1)));
                score += fit * 30;
            }
            else
            {
                score += 10;
            }

            // level match
            if (!string.IsNullOrWhiteSpace(userLevel) && !string.IsNullOrWhiteSpace(t.Level))
            {
                if (t.Level.Equals(userLevel, StringComparison.OrdinalIgnoreCase)) score += 20;
                else
                {
                    // small credit if template is slightly easier than user
                    if (t.Level.Equals("Beginner", StringComparison.OrdinalIgnoreCase) && userLevel.Equals("Intermediate", StringComparison.OrdinalIgnoreCase)) score += 10;
                    if (t.Level.Equals("Intermediate", StringComparison.OrdinalIgnoreCase) && userLevel.Equals("Advanced", StringComparison.OrdinalIgnoreCase)) score += 10;
                }
            }

            return score;
        }

        private string BuildReasonTag(ExerciseTemplate t, string goal, string userLevel, int? availableSeconds)
        {
            var reasons = new List<string>();
            if (goal.Contains("fat") && t.Category?.ToLowerInvariant().Contains("cardio") == true) reasons.Add("Good for fat loss");
            if (goal.Contains("musc") && t.Category?.ToLowerInvariant().Contains("strength") == true) reasons.Add("Builds muscle");
            if (availableSeconds.HasValue && Math.Abs(t.DurationSeconds - availableSeconds.Value) <= Math.Max(60, availableSeconds.Value * 0.25)) reasons.Add("Fits your time");
            if (!string.IsNullOrWhiteSpace(userLevel) && t.Level.Equals(userLevel, StringComparison.OrdinalIgnoreCase)) reasons.Add("Matches your level");
            return string.Join("; ", reasons);
        }

        // SMART SUGGESTION METHODS
        private double ScoreSuggestionSmart(ExerciseTemplate t, string goal, string userLevel, double bmi, int age, string gender, int? availableSeconds)
        {
            double score = 0;
            var category = t.Category?.ToLowerInvariant() ?? "";
            var intensity = t.Intensity?.ToLowerInvariant() ?? "";

            // BMI-based scoring
            if (bmi < 18.5) // Underweight - need muscle building
            {
                if (category == "strength") score += 50;
                if (category == "cardio" && intensity == "low") score += 20;
            }
            else if (bmi >= 18.5 && bmi < 25) // Normal - balanced
            {
                if (category == "cardio") score += 30;
                if (category == "strength") score += 30;
                if (category == "mobility") score += 20;
            }
            else if (bmi >= 25 && bmi < 30) // Overweight - focus cardio
            {
                if (category == "cardio") score += 50;
                if (intensity == "moderate" || intensity == "high") score += 20;
                if (category == "strength") score += 15;
            }
            else // Obese - low impact cardio
            {
                if (category == "cardio" && (intensity == "low" || intensity == "moderate")) score += 50;
                if (category == "mobility") score += 30;
            }

            // Age-based scoring
            if (age < 30) // Young - high intensity OK
            {
                if (intensity == "high" || intensity == "very high") score += 20;
            }
            else if (age >= 30 && age < 50) // Middle age - moderate
            {
                if (intensity == "moderate" || intensity == "high") score += 20;
            }
            else // Senior - low intensity
            {
                if (intensity == "low" || intensity == "moderate") score += 25;
                if (category == "mobility") score += 15;
            }

            // Gender-based scoring
            if (gender == "male" || gender == "nam")
            {
                if (category == "strength") score += 15;
            }
            else // Female
            {
                if (category == "cardio") score += 10;
                if (category == "mobility") score += 10;
            }

            // Goal affinity
            if (goal.Contains("fat") || goal.Contains("giảm")) 
            {
                if (category == "cardio") score += 30;
            }
            if (goal.Contains("musc") || goal.Contains("tăng") || goal.Contains("cơ")) 
            {
                if (category == "strength") score += 30;
            }

            // Duration fit
            if (availableSeconds.HasValue && availableSeconds.Value > 0)
            {
                var diff = Math.Abs(t.DurationSeconds - availableSeconds.Value);
                var fit = Math.Max(0, 1.0 - (diff / Math.Max(availableSeconds.Value, 1)));
                score += fit * 25;
            }

            // Level match
            if (!string.IsNullOrWhiteSpace(userLevel) && !string.IsNullOrWhiteSpace(t.Level))
            {
                if (t.Level.Equals(userLevel, StringComparison.OrdinalIgnoreCase)) score += 15;
            }

            return score;
        }

        private string BuildReasonTagSmart(ExerciseTemplate t, string goal, string userLevel, double bmi, int age, string gender, int? availableSeconds)
        {
            var reasons = new List<string>();
            var category = t.Category?.ToLowerInvariant() ?? "";
            var intensity = t.Intensity?.ToLowerInvariant() ?? "";

            // BMI reasons
            if (bmi < 18.5 && category == "strength") reasons.Add("Phù hợp để tăng cơ");
            else if (bmi >= 25 && category == "cardio") reasons.Add("Giúp giảm cân hiệu quả");
            else if (bmi >= 18.5 && bmi < 25) reasons.Add("Phù hợp với BMI của bạn");

            // Age reasons
            if (age >= 50 && (intensity == "low" || category == "mobility")) reasons.Add("An toàn cho độ tuổi");
            else if (age < 30 && intensity == "high") reasons.Add("Phù hợp với lứa tuổi trẻ");

            // Goal reasons
            if (goal.Contains("fat") || goal.Contains("giảm")) 
            {
                if (category == "cardio") reasons.Add("Đốt cháy mỡ thừa");
            }
            if (goal.Contains("musc") || goal.Contains("tăng") || goal.Contains("cơ")) 
            {
                if (category == "strength") reasons.Add("Xây dựng cơ bắp");
            }

            // Duration
            if (availableSeconds.HasValue && Math.Abs(t.DurationSeconds - availableSeconds.Value) <= 300) 
                reasons.Add("Phù hợp thời gian");

            return reasons.Count > 0 ? string.Join(" • ", reasons) : "Phù hợp với bạn";
        }

        private double ComputeRecommendedMinutes(string goal, string? level)
        {
            // baseline weekly minutes
            double baseline = 150; // moderate activity per week
            if (goal.Contains("fat")) baseline = 200;
            if (goal.Contains("musc")) baseline = 180;

            // adjust by level
            var lvl = (level ?? "Beginner").ToLowerInvariant();
            if (lvl == "beginner") baseline *= 0.8;
            if (lvl == "advanced") baseline *= 1.2;

            return baseline; // minutes per week
        }

        private double GetMet(string? category)
        {
            var cat = (category ?? string.Empty).ToLowerInvariant();
            return cat switch
            {
                "cardio" => 8.0,
                "strength" => 6.0,
                "mobility" => 3.0,
                _ => 5.0
            };
        }

        private double EstimateCalories(double met, double weightKg, int durationSeconds)
        {
            if (weightKg <= 0 || durationSeconds <= 0) return 0;
            double durationHours = durationSeconds / 3600.0;
            return Math.Round(met * weightKg * durationHours, 2);
        }
    }
}