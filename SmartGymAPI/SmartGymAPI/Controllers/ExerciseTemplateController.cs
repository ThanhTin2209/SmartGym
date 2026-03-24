using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ExerciseTemplateController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ExerciseTemplateController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/ExerciseTemplate (Public - for suggestions)
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _context.ExerciseTemplates.AsNoTracking().ToListAsync();
            return Ok(list);
        }

        // POST: api/ExerciseTemplate (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] ExerciseTemplate model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            _context.ExerciseTemplates.Add(model);
            await _context.SaveChangesAsync();

            return Ok(model);
        }

        // PUT: api/ExerciseTemplate/{id} (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] ExerciseTemplate model)
        {
            if (id != model.Id) return BadRequest();
            
            var existing = await _context.ExerciseTemplates.FindAsync(id);
            if (existing == null) return NotFound();

            existing.Name = model.Name;
            existing.Category = model.Category;
            existing.DurationSeconds = model.DurationSeconds;
            existing.BaseMet = model.BaseMet;
            existing.Intensity = model.Intensity;
            existing.Level = model.Level;

            await _context.SaveChangesAsync();
            return Ok(existing);
        }

        // DELETE: api/ExerciseTemplate/{id} (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _context.ExerciseTemplates.FindAsync(id);
            if (existing == null) return NotFound();

            _context.ExerciseTemplates.Remove(existing);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        // POST: api/ExerciseTemplate/bulk-update (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpPost("bulk-update")]
        public async Task<IActionResult> BulkUpdate([FromBody] List<ExerciseTemplate> templates)
        {
            foreach (var template in templates)
            {
                var existing = await _context.ExerciseTemplates.FindAsync(template.Id);
                if (existing != null)
                {
                    existing.Name = template.Name;
                    existing.Category = template.Category;
                    existing.DurationSeconds = template.DurationSeconds;
                    existing.BaseMet = template.BaseMet;
                    existing.Intensity = template.Intensity;
                    existing.Level = template.Level;
                }
            }
            
            await _context.SaveChangesAsync();
            return Ok(new { updated = templates.Count });
        }
    }
}
