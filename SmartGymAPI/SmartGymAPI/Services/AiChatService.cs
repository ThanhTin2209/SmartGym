using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;

namespace SmartGymAPI.Services
{
    public class AiChatService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;

        public AiChatService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _apiKey = configuration["Gemini:ApiKey"];
        }

        public async Task<string> GetResponseAsync(string prompt)
        {
            if (string.IsNullOrEmpty(_apiKey))
            {
                return "API Key chưa được cấu hình. Vui lòng kiểm tra appsettings.json.";
            }

            var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={_apiKey}";
            
            var requestBody = new
            {
                contents = new[]
                {
                    new { parts = new[] { new { text = prompt } } }
                }
            };

            var json = JsonSerializer.Serialize(requestBody);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            int maxRetries = 3;
            int delay = 1000;

            for (int i = 0; i < maxRetries; i++)
            {
                try
                {
                    // Re-create content for each retry as HttpClient request content can be disposed
                    var currentContent = new StringContent(json, Encoding.UTF8, "application/json"); 
                    
                    var response = await _httpClient.PostAsync(url, currentContent);
                    var responseString = await response.Content.ReadAsStringAsync();

                    if (!response.IsSuccessStatusCode)
                    {
                        if ((response.StatusCode == System.Net.HttpStatusCode.ServiceUnavailable || 
                             response.StatusCode == System.Net.HttpStatusCode.TooManyRequests) && i < maxRetries - 1)
                        {
                            await Task.Delay(delay);
                            delay *= 2; // Exponential backoff
                            continue;
                        }
                        
                        return $"Lỗi từ Gemini API: {response.StatusCode} - {responseString}";
                    }

                    using var doc = JsonDocument.Parse(responseString);
                    if (doc.RootElement.TryGetProperty("candidates", out var candidates) && candidates.GetArrayLength() > 0)
                    {
                        var text = candidates[0]
                            .GetProperty("content")
                            .GetProperty("parts")[0]
                            .GetProperty("text")
                            .GetString();
                        return text ?? "Không có nội dung trả về.";
                    }

                    return "Không tìm thấy câu trả lời hợp lệ từ Gemini.";
                }
                catch (Exception ex)
                {
                    return $"Lỗi xử lý: {ex.Message}";
                }
            }
            return "Server đang bận, vui lòng thử lại sau.";
        }
    }
}
