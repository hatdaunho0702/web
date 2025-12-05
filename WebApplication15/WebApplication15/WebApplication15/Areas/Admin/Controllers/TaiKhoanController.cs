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
        public ActionResult Create(TaiKhoan tk)
        {
            if (ModelState.IsValid)
            {
                db.TaiKhoans.Add(tk);
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen", tk.MaND);
            return View(tk);
        }

        public ActionResult Edit(int id)
        {
            var tk = db.TaiKhoans.Find(id);
            ViewBag.MaND = new SelectList(db.NguoiDungs, "MaND", "HoTen", tk.MaND);
            return View(tk);
        }

        [HttpPost]
        public ActionResult Edit(TaiKhoan tk)
        {
            if (ModelState.IsValid)
            {
                db.Entry(tk).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
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
                    db.TaiKhoans.Remove(tk);
                    db.SaveChanges();
                    return RedirectToAction("Index");
                }
            }
            catch (System.Data.Entity.Infrastructure.DbUpdateException ex)
            {
                TempData["ErrorMessage"] = "Không thể xóa tài khoản này vì còn có dữ liệu liên quan.";
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Có lỗi xảy ra khi xóa tài khoản: " + ex.Message;
            }
            return RedirectToAction("Index");
        }
    }
}