using System;
using System.Data.Entity;
using System.Web.Mvc;
using WebApplication15.Models;

public class LienHeController : Controller
{
    private DB_SkinFoodEntities db = new DB_SkinFoodEntities();

    public ActionResult Index()
    {
        return View();
    }

    [HttpPost]
    public ActionResult GuiLienHe(LienHe model)
    {
        if (ModelState.IsValid)
        {
            model.NgayGui = DateTime.Now;  

            db.LienHes.Add(model);
            db.SaveChanges();

            TempData["Success"] = "Gửi liên hệ thành công! Chúng tôi sẽ phản hồi sớm nhất.";
            return RedirectToAction("Index");
        }

        TempData["Error"] = "Gửi thất bại. Vui lòng thử lại!";
        return View("Index");
    }
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
