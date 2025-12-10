using System;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using Newtonsoft.Json;

public class ChatController : Controller
{
    // QUAN TRỌNG: Không hard-code API key! Đọc từ Web.config hoặc biến môi trường
    private readonly string apiKey = ConfigurationManager.AppSettings["OpenAI_API_Key"] ?? "";

    public ActionResult ChatAI()
    {
        // Kiểm tra API key
        if (string.IsNullOrEmpty(apiKey))
        {
            ViewBag.Error = "Chức năng Chat AI chưa được cấu hình. Vui lòng liên hệ quản trị viên.";
        }
        return View();
    }

    [HttpPost]
    public async Task<ActionResult> SendMessage(string message)
    {
        try
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(message))
            {
                return Content("Vui lòng nhập tin nhắn.");
            }
            
            // Kiểm tra API key
            if (string.IsNullOrEmpty(apiKey))
            {
                return Content("Chức năng Chat AI chưa được cấu hình.");
            }

            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

            var requestBody = new
            {
                model = "gpt-4o-mini",
                input = message
            };

            var content = new StringContent(
                JsonConvert.SerializeObject(requestBody),
                Encoding.UTF8,
                "application/json"
            );

            // API endpoint không chính xác - cần sửa
            var response = await httpClient.PostAsync("https://api.openai.com/v1/chat/completions", content);
            
            if (!response.IsSuccessStatusCode)
            {
                return Content("Lỗi kết nối với AI API. Vui lòng thử lại sau.");
            }
            
            var responseString = await response.Content.ReadAsStringAsync();
            dynamic data = JsonConvert.DeserializeObject(responseString);

            // Sửa lại cách parse response theo API OpenAI thực tế
            string reply = data.choices[0].message.content;

            return Content(reply);
        }
        catch (HttpRequestException httpEx)
        {
            System.Diagnostics.Debug.WriteLine($"HTTP Error: {httpEx.Message}");
            return Content("Không thể kết nối với dịch vụ AI. Vui lòng thử lại sau.");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error: {ex.Message}");
            return Content("Đã xảy ra lỗi. Vui lòng thử lại sau.");
        }
    }
}
