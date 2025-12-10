using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using WebApplication15.Areas.Admin.Data;
using WebApplication15.Models;

namespace WebApplication15.Areas.Admin.Controllers
{
    [AuthorizeAdmin]
    public class XuatKhoController : Controller
    {
        private DB_SkinFoodEntities db = new DB_SkinFoodEntities();

        // GET: Admin/XuatKho
        public ActionResult Index()
        {
            var xuatKhos = db.XuatKhoes
                .Include(x => x.SanPham)
                .OrderByDescending(x => x.NgayXuat)
                .ToList();
            return View(xuatKhos);
        }

        // GET: Admin/XuatKho/Create
        public ActionResult Create()
        {
            ViewBag.MaSP = new SelectList(db.SanPhams, "MaSP", "TenSP");
            ViewBag.LyDoXuat = new SelectList(new[] { "H?ng hóc", "H?t h?n", "Khuy?n m?i", "Khác" });
            return View();
        }

        // POST: Admin/XuatKho/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(XuatKho xuatKho)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    var sanPham = db.SanPhams.Find(xuatKho.MaSP);
                    if (sanPham == null)
                    {
                        TempData["ErrorMessage"] = "S?n ph?m không t?n t?i!";
                        return RedirectToAction("Create");
                    }

                    if (sanPham.SoLuongTon < xuatKho.SoLuongXuat)
                    {
                        TempData["ErrorMessage"] = "S? lý?ng t?n kho không ð?!";
                        ViewBag.MaSP = new SelectList(db.SanPhams, "MaSP", "TenSP", xuatKho.MaSP);
                        ViewBag.LyDoXuat = new SelectList(new[] { "H?ng hóc", "H?t h?n", "Khuy?n m?i", "Khác" });
                        return View(xuatKho);
                    }

                    xuatKho.NgayXuat = DateTime.Now;
                    db.XuatKhoes.Add(xuatKho);
                    
                    // Gi?m t?n kho
                    sanPham.SoLuongTon = (sanPham.SoLuongTon ?? 0) - xuatKho.SoLuongXuat;
                    
                    db.SaveChanges();
                    TempData["SuccessMessage"] = "Xu?t kho thành công!";
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    TempData["ErrorMessage"] = "L?i: " + ex.Message;
                }
            }

            ViewBag.MaSP = new SelectList(db.SanPhams, "MaSP", "TenSP", xuatKho.MaSP);
            ViewBag.LyDoXuat = new SelectList(new[] { "H?ng hóc", "H?t h?n", "Khuy?n m?i", "Khác" });
            return View(xuatKho);
        }

        // GET: Admin/XuatKho/Details/5
        public ActionResult Details(int id)
        {
            var xuatKho = db.XuatKhoes.Include(x => x.SanPham).FirstOrDefault(x => x.MaXuat == id);
            if (xuatKho == null)
            {
                return HttpNotFound();
            }
            return View(xuatKho);
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
