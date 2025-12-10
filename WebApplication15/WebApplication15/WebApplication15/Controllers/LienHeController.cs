using System.Web.Mvc;

public class LienHeController : Controller
{
    public ActionResult CheckLogin()
    {
        if (Session["User"] != null)
        {
            return RedirectToAction("Index", "Home");
        }
        return RedirectToAction("Login", "User");
    }

    public ActionResult HuongDanMuaHang()
    {
        return View();
    }

    public ActionResult ChinhSachDoiTra()
    {
        return View();
    }

    public ActionResult ChinhSachBaoMat()
    {
        return View();
    }
}
