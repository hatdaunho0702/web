using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using Newtonsoft.Json;

public class ChatController : Controller
{
    private readonly string apiKey = "";

    public ActionResult ChatAI()
    {
        return View();
    }

    [HttpPost]
    public async Task<ActionResult> SendMessage(string message)
    {
        try
        {
            var httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

            var requestBody = new
            {
                model = "gpt-4o-mini",
                messages = new[]
                {
                    new { role = "system", content = "Bạn là nhân viên tư vấn của cửa hàng mỹ phẩm SkinFood. Bạn chỉ được phép trả lời các câu hỏi liên quan đến mỹ phẩm, chăm sóc da, thông tin sản phẩm, và dịch vụ của cửa hàng. Nếu khách hàng hỏi về các chủ đề không liên quan (như chính trị, thể thao, lập trình, v.v.), hãy lịch sự từ chối và hướng họ quay lại chủ đề về cửa hàng." },
                    new { role = "user", content = message }
                }
            };

            var content = new StringContent(
                JsonConvert.SerializeObject(requestBody),
                Encoding.UTF8,
                "application/json"
            );

            var response = await httpClient.PostAsync("https://api.openai.com/v1/chat/completions", content);
            var responseString = await response.Content.ReadAsStringAsync();

            dynamic data = JsonConvert.DeserializeObject(responseString);

            string reply = data.choices[0].message.content;

            return Content(reply);
        }
        catch (Exception ex)
        {
            return Content("Lỗi: " + ex.Message);
        }
    }
}