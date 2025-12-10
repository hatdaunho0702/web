using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using WebApplication15.Areas.Admin.Data;
using WebApplication15.Models;

namespace WebApplication15.Areas.Admin.Controllers
{
    [AuthorizeAdmin]
    public class NhapHangController : Controller
    {
        private DB_SkinFoodEntities db = new DB_SkinFoodEntities();

        // GET: Admin/NhapHang
        public ActionResult Index(string search)
        {
            try
            {
                var nhapHangs = db.NhapHangs
                    .Include(n => n.SanPham)
                    .OrderByDescending(n => n.NgayNhap)
                    .AsQueryable();

                // T?m ki?m
                if (!string.IsNullOrEmpty(search))
                {
                    search = search.ToLower().Trim();
                    nhapHangs = nhapHangs.Where(n => 
                        n.SanPham.TenSP.ToLower().Contains(search) ||
                        n.NhaCungCap.ToLower().Contains(search) ||
                        n.GhiChu.ToLower().Contains(search)
                    );
                }

                return View(nhapHangs.ToList());
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in NhapHang Index: {ex.Message}");
                TempData["ErrorMessage"] = "Có l?i x?y ra khi t?i d? li?u: " + ex.Message;
                return View(new List<NhapHang>());
            }
        }

        // GET: Admin/NhapHang/Create
        public ActionResult Create()
        {
            try
            {
                var sanPhams = db.SanPhams
                    .Where(sp => sp.SoLuongTon >= 0)
                    .OrderBy(sp => sp.TenSP)
                    .ToList();

                ViewBag.MaSP = new SelectList(sanPhams, "MaSP", "TenSP");
                return View();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in NhapHang Create: {ex.Message}");
                TempData["ErrorMessage"] = "Có l?i x?y ra: " + ex.Message;
                return RedirectToAction("Index");
            }
        }

        // POST: Admin/NhapHang/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(NhapHang nhapHang)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Ki?m tra s?n ph?m t?n t?i
                    var sanPham = db.SanPhams.Find(nhapHang.MaSP);
                    if (sanPham == null)
                    {
                        TempData["ErrorMessage"] = "S?n ph?m không t?n t?i!";
                        ViewBag.MaSP = new SelectList(db.SanPhams, "MaSP", "TenSP", nhapHang.MaSP);
                        return View(nhapHang);
                    }

                    // Ki?m tra s? lý?ng nh?p
                    if (nhapHang.SoLuongNhap <= 0)
                    {
                        TempData["ErrorMessage"] = "S? lý?ng nh?p ph?i l?n hõn 0!";
                        ViewBag.MaSP = new SelectList(db.SanPhams, "MaSP", "TenSP", nhapHang.MaSP);
                        return View(nhapHang);
                    }

                    // Ki?m tra giá v?n
                    if (nhapHang.GiaVon == null || nhapHang.GiaVon <= 0)
                    {
                        TempData["ErrorMessage"] = "Giá v?n ph?i l?n hõn 0!";
                        ViewBag.MaSP = new SelectList(db.SanPhams, "MaSP", "TenSP", nhapHang.MaSP);
                        return View(nhapHang);
                    }

                    nhapHang.NgayNhap = DateTime.Now;
                    db.NhapHangs.Add(nhapHang);
                    
                    // C?p nh?t t?n kho
                    sanPham.SoLuongTon = (sanPham.SoLuongTon ?? 0) + nhapHang.SoLuongNhap;
                    
                    db.SaveChanges();
                    TempData["SuccessMessage"] = $"Nh?p hàng thành công! Ð? nh?p {nhapHang.SoLuongNhap} s?n ph?m {sanPham.TenSP}.";
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error in NhapHang Create POST: {ex.Message}");
                    TempData["ErrorMessage"] = "L?i khi nh?p hàng: " + ex.Message;
                }
            }
            else
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors);
                foreach (var error in errors)
                {
                    System.Diagnostics.Debug.WriteLine($"ModelState Error: {error.ErrorMessage}");
                }
                TempData["ErrorMessage"] = "Vui l?ng ki?m tra l?i thông tin nh?p!";
            }

            ViewBag.MaSP = new SelectList(db.SanPhams, "MaSP", "TenSP", nhapHang.MaSP);
            return View(nhapHang);
        }

        // GET: Admin/NhapHang/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                TempData["ErrorMessage"] = "Không t?m th?y m? nh?p hàng!";
                return RedirectToAction("Index");
            }

            try
            {
                var nhapHang = db.NhapHangs
                    .Include(n => n.SanPham)
                    .FirstOrDefault(n => n.MaNhap == id);
                
                if (nhapHang == null)
                {
                    TempData["ErrorMessage"] = "Không t?m th?y phi?u nh?p hàng!";
                    return RedirectToAction("Index");
                }
                
                return View(nhapHang);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in NhapHang Details: {ex.Message}");
                TempData["ErrorMessage"] = "Có l?i x?y ra: " + ex.Message;
                return RedirectToAction("Index");
            }
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
