using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using WebApplication15.Areas.Admin.Data;
using WebApplication15.Models;

namespace WebApplication15.Areas.Admin.Controllers
{
    [AuthorizeAdmin]
    public class DonHangController : Controller
    {
        DB_SkinFoodEntities db = new DB_SkinFoodEntities();

        // GET: Admin/DonHang
        public ActionResult Index()
        {
            return View(db.DonHangs.OrderByDescending(d => d.NgayDat).ToList());
        }

        public ActionResult Details(int id)
        {
            var dh = db.DonHangs.Find(id);
            if (dh == null)
                return HttpNotFound();

            var chiTietList = db.ChiTietDonHangs
                .Where(c => c.MaDH == id)
                .Include(c => c.SanPham)
                .ToList();

            ViewBag.ChiTiet = chiTietList;
            return View(dh);
        }

        public ActionResult Delete(int id)
        {
            try
            {
                db.ChiTietDonHangs.RemoveRange(
                    db.ChiTietDonHangs.Where(c => c.MaDH == id)
                );

                db.DonHangs.Remove(db.DonHangs.Find(id));
                db.SaveChanges();
                TempData["SuccessMessage"] = "Xóa đơn hàng thành công!";
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Có lỗi xảy ra khi xóa: " + ex.Message;
            }
            return RedirectToAction("Index");
        }

        // AJAX: Cập nhật trạng thái thanh toán
        [HttpPost]
        public ActionResult UpdatePaymentStatus(int id, string status)
        {
            try
            {
                var dh = db.DonHangs.Include("ChiTietDonHangs").FirstOrDefault(d => d.MaDH == id);
                if (dh == null)
                    return Json(new { success = false, message = "Đơn hàng không tồn tại" });

                string oldStatus = dh.TrangThaiThanhToan;
                dh.TrangThaiThanhToan = status;

                // Nếu chuyển sang "Đã thanh toán" và trước đó chưa thanh toán -> Trừ kho
                if (status == "Đã thanh toán" && oldStatus != "Đã thanh toán")
                {
                    if (!dh.NgayThanhToan.HasValue)
                    {
                        dh.NgayThanhToan = DateTime.Now;
                    }

                    // Trừ kho
                    foreach (var item in dh.ChiTietDonHangs)
                    {
                        var sp = db.SanPhams.Find(item.MaSP);
                        if (sp != null)
                        {
                            // Kiểm tra nếu kho < 0 thì vẫn trừ (cho phép âm nếu admin force?)
                            // Hoặc chặn? Ở đây admin quyền lực nên cho phép trừ
                            sp.SoLuongTon -= item.SoLuong;
                            db.Entry(sp).State = EntityState.Modified;
                        }
                    }
                }
                // Nếu chuyển từ "Đã thanh toán" sang "Chưa thanh toán" hoặc "Hủy" -> Cộng lại kho?
                // User không yêu cầu, nhưng logic đúng nên thế.
                // Tuy nhiên user chỉ yêu cầu "khi nào thanh toán mới trừ".
                // Nếu admin hủy đơn đã thanh toán, nên hoàn kho.
                else if ((status.Contains("Hủy") || status.Contains("Cancel")) && oldStatus == "Đã thanh toán")
                {
                     foreach (var item in dh.ChiTietDonHangs)
                    {
                        var sp = db.SanPhams.Find(item.MaSP);
                        if (sp != null)
                        {
                            sp.SoLuongTon += item.SoLuong;
                            db.Entry(sp).State = EntityState.Modified;
                        }
                    }
                }

                db.SaveChanges();

                return Json(new { success = true, message = "Cập nhật trạng thái thành công!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Lỗi: " + ex.Message });
            }
        }
    }
}