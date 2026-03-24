using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SmartGymAPI.Data;
using SmartGymAPI.Models;
using System.Threading.Tasks;

namespace SmartGymAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MealController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public MealController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/meal (Public)
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _context.MealTemplates.AsNoTracking().ToListAsync();
            return Ok(list);
        }

        // POST: api/meal (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] MealTemplate model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            _context.MealTemplates.Add(model);
            await _context.SaveChangesAsync();

            return Ok(model);
        }

        // PUT: api/meal/{id} (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] MealTemplate model)
        {
            if (id != model.Id) return BadRequest();
            
            var existing = await _context.MealTemplates.FindAsync(id);
            if (existing == null) return NotFound();

            existing.Name = model.Name;
            existing.Description = model.Description;
            existing.Category = model.Category;
            existing.Calories = model.Calories;
            existing.Protein = model.Protein;
            existing.Carbs = model.Carbs;
            existing.Fat = model.Fat;
            existing.DietType = model.DietType;
            existing.ImageUrl = model.ImageUrl;

            await _context.SaveChangesAsync();
            return Ok(existing);
        }

        // DELETE: api/meal/{id} (Admin only)
        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _context.MealTemplates.FindAsync(id);
            if (existing == null) return NotFound();

            _context.MealTemplates.Remove(existing);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
