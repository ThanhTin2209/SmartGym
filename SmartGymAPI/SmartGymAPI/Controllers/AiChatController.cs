using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartGymAPI.Models;
using SmartGymAPI.Services;

namespace SmartGymAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AiChatController : ControllerBase
    {
        private readonly AiChatService _aiChatService;

        public AiChatController(AiChatService aiChatService)
        {
            _aiChatService = aiChatService;
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Chat([FromBody] AiChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Prompt))
            {
                return BadRequest("Câu hỏi không được để trống.");
            }

            var responseText = await _aiChatService.GetResponseAsync(request.Prompt);
            return Ok(new AiChatResponse { Response = responseText });
        }
    }
}
