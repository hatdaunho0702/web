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
    public class TaiKhoanController : Controller
    {
        DB_SkinFoodEntities db = new DB_SkinFoodEntities();

        public ActionResult Index()
        {
            return View(db.TaiKhoans.ToList());
        }

        public ActionResult Create()
        {
            ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(TaiKhoan tk)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Kiểm tra trùng tên đăng nhập
                    var existing = db.TaiKhoans.FirstOrDefault(t => t.TenDangNhap == tk.TenDangNhap);
                    if (existing != null)
                    {
                        TempData["ErrorMessage"] = "Tên đăng nhập đã tồn tại!";
                        ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen", tk.MaND);
                        return View(tk);
                    }
                    
                    // Kiểm tra người dùng đã có tài khoản chưa
                    var hasAccount = db.TaiKhoans.FirstOrDefault(t => t.MaND == tk.MaND);
                    if (hasAccount != null)
                    {
                        TempData["ErrorMessage"] = "Người dùng này đã có tài khoản!";
                        ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen", tk.MaND);
                        return View(tk);
                    }
                    
                    db.TaiKhoans.Add(tk);
                    db.SaveChanges();
                    TempData["SuccessMessage"] = "Tạo tài khoản thành công!";
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    TempData["ErrorMessage"] = "Lỗi: " + ex.Message;
                }
            }
            ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen", tk.MaND);
            return View(tk);
        }

        public ActionResult Edit(int id)
        {
            var tk = db.TaiKhoans.Find(id);
            if (tk == null)
                return HttpNotFound();
                
            ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen", tk.MaND);
            return View(tk);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(TaiKhoan tk)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    db.Entry(tk).State = EntityState.Modified;
                    db.SaveChanges();
                    TempData["SuccessMessage"] = "Cập nhật tài khoản thành công!";
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    TempData["ErrorMessage"] = "Lỗi: " + ex.Message;
                }
            }
            ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen", tk.MaND);
            return View(tk);
        }

        public ActionResult Delete(int id)
        {
            try
            {
                var tk = db.TaiKhoans.Find(id);
                if (tk != null)
                {
                    // Không cho xóa tài khoản admin
                    if (tk.VaiTro == "Admin")
                    {
                        TempData["ErrorMessage"] = "Không thể xóa tài khoản Admin!";
                        return RedirectToAction("Index");
                    }
                    
                    db.TaiKhoans.Remove(tk);
                    db.SaveChanges();
                    TempData["SuccessMessage"] = "Xóa tài khoản thành công!";
                    return RedirectToAction("Index");
                }
            }
            catch (System.Data.Entity.Infrastructure.DbUpdateException)
            {
                TempData["ErrorMessage"] = "Không thể xóa tài khoản này vì còn có dữ liệu liên quan.";
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Có lỗi xảy ra khi xóa tài khoản: " + ex.Message;
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