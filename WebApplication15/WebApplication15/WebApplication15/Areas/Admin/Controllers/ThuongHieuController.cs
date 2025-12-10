using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApplication15.Areas.Admin.Data;
using WebApplication15.Models;

namespace WebApplication15.Areas.Admin.Controllers
{
    [AuthorizeAdmin]
    public class ThuongHieuController : Controller
    {
        DB_SkinFoodEntities db = new DB_SkinFoodEntities();

        // GET: Admin/ThuongHieu
        public ActionResult Index() => View(db.ThuongHieux.ToList());

        public ActionResult Create() => View();

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ThuongHieu th)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Kiểm tra trùng tên thương hiệu
                    var existing = db.ThuongHieux.FirstOrDefault(t => t.TenTH == th.TenTH);
                    if (existing != null)
                    {
                        TempData["ErrorMessage"] = "Thương hiệu này đã tồn tại!";
                        return View(th);
                    }
                    
                    db.ThuongHieux.Add(th);
                    db.SaveChanges();
                    TempData["SuccessMessage"] = "Thêm thương hiệu thành công!";
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    TempData["ErrorMessage"] = "Lỗi: " + ex.Message;
                }
            }
            return View(th);
        }

        public ActionResult Edit(int id)
        {
            var th = db.ThuongHieux.Find(id);
            if (th == null)
                return HttpNotFound();
            return View(th);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(ThuongHieu th)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    db.Entry(th).State = EntityState.Modified;
                    db.SaveChanges();
                    TempData["SuccessMessage"] = "Cập nhật thương hiệu thành công!";
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    TempData["ErrorMessage"] = "Lỗi: " + ex.Message;
                }
            }
            return View(th);
        }

        public ActionResult Delete(int id)
        {
            try
            {
                var th = db.ThuongHieux.Find(id);
                if (th != null)
                {
                    db.ThuongHieux.Remove(th);
                    db.SaveChanges();
                    TempData["SuccessMessage"] = "Xóa thương hiệu thành công!";
                    return RedirectToAction("Index");
                }
            }
            catch (System.Data.Entity.Infrastructure.DbUpdateException)
            {
                TempData["ErrorMessage"] = "Không thể xóa thương hiệu này vì còn có sản phẩm liên quan.";
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Có lỗi xảy ra khi xóa thương hiệu: " + ex.Message;
            }
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}