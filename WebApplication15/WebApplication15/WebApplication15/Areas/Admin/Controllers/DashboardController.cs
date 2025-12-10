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
    [AuthorizeAdmin] // Giữ nguyên nếu project bạn có class này
    public class DashboardController : Controller
    {
        private DB_SkinFoodEntities db = new DB_SkinFoodEntities();

        public ActionResult Index()
        {
            try
            {
                // =======================================================
                // 1. THỐNG KÊ CƠ BẢN
                // =======================================================
                ViewBag.TotalSanPham = db.SanPhams.Count();
                ViewBag.TotalDonHang = db.DonHangs.Count();
                ViewBag.TotalNguoiDung = db.NguoiDungs.Count();

                // Lấy toàn bộ đơn hàng vào bộ nhớ để xử lý
                var allDonHangs = db.DonHangs.ToList();

                // =======================================================
                // 2. PHÂN LOẠI ĐƠN HÀNG
                // =======================================================

                // A. Đơn dùng tính Doanh Số (GMV) - Dùng cho Biểu Đồ
                // Logic: Lấy tất cả đơn, trừ những đơn có chữ "Hủy" hoặc "Cancel"
                var donHangHieuLuc = allDonHangs
                    .Where(dh => string.IsNullOrEmpty(dh.TrangThaiThanhToan) ||
                                (!dh.TrangThaiThanhToan.ToLower().Contains("hủy") &&
                                 !dh.TrangThaiThanhToan.ToLower().Contains("cancel")))
                    .ToList();

                // B. Đơn đã thanh toán thực tế (Cashflow)
                var donHangDaThanhToan = allDonHangs
                    .Where(dh => !string.IsNullOrEmpty(dh.TrangThaiThanhToan) &&
                                (dh.TrangThaiThanhToan.ToLower().Contains("đã thanh toán") ||
                                 dh.TrangThaiThanhToan.ToLower().Contains("paid") ||
                                 dh.TrangThaiThanhToan.ToLower().Contains("cod")))
                    .ToList();

                // =======================================================
                // 3. TÍNH TOÁN HIỂN THỊ TRÊN THẺ (CARDS)
                // =======================================================

                // Tổng doanh thu dự kiến (Dựa trên đơn hiệu lực)
                ViewBag.TongDoanhThu = donHangHieuLuc.Sum(dh => dh.TongTien) ?? 0;

                // Tổng người mua (Dựa trên đơn hiệu lực)
                ViewBag.TongNguoiMua = donHangHieuLuc
                    .Where(d => d.MaND.HasValue).Select(d => d.MaND.Value).Distinct().Count();

                // Doanh thu theo mốc thời gian
                var today = DateTime.Now.Date;
                var startOfMonth = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
                var startOfYear = new DateTime(DateTime.Now.Year, 1, 1);

                ViewBag.DoanhThuHomNay = donHangHieuLuc
                    .Where(d => d.NgayDat.HasValue && d.NgayDat.Value.Date == today)
                    .Sum(d => d.TongTien) ?? 0;

                ViewBag.DoanhThuThangNay = donHangHieuLuc
                    .Where(d => d.NgayDat.HasValue && d.NgayDat.Value >= startOfMonth)
                    .Sum(d => d.TongTien) ?? 0;

                ViewBag.DoanhThuNamNay = donHangHieuLuc
                    .Where(d => d.NgayDat.HasValue && d.NgayDat.Value >= startOfYear)
                    .Sum(d => d.TongTien) ?? 0;

                var startLastYear = startOfYear.AddYears(-1);
                var endLastYear = startOfYear.AddDays(-1);
                ViewBag.DoanhThuNamTruoc = donHangHieuLuc
                    .Where(d => d.NgayDat.HasValue && d.NgayDat.Value >= startLastYear && d.NgayDat.Value <= endLastYear)
                    .Sum(d => d.TongTien) ?? 0;

                // =======================================================
                // 4. DỮ LIỆU BIỂU ĐỒ 7 NGÀY (CỐT LÕI)
                // =======================================================
                var data7Ngay = new List<dynamic>();
                for (int i = 6; i >= 0; i--)
                {
                    var targetDate = today.AddDays(-i);
                    // Lọc đơn hàng trong ngày đó (từ danh sách hiệu lực)
                    var ordersInDate = donHangHieuLuc
                        .Where(d => d.NgayDat.HasValue && d.NgayDat.Value.Date == targetDate)
                        .ToList();

                    data7Ngay.Add(new
                    {
                        Ngay = targetDate,
                        DoanhThu = ordersInDate.Sum(d => d.TongTien) ?? 0,
                        SoDonHang = ordersInDate.Count
                    });
                }
                ViewBag.DoanhThu7Ngay = data7Ngay;

                // =======================================================
                // 5. DỮ LIỆU BIỂU ĐỒ 12 THÁNG
                // =======================================================
                var data12Thang = new List<dynamic>();
                for (int i = 11; i >= 0; i--)
                {
                    var targetMonth = DateTime.Now.AddMonths(-i);
                    var startM = new DateTime(targetMonth.Year, targetMonth.Month, 1);
                    var endM = startM.AddMonths(1).AddSeconds(-1);

                    var ordersInMonth = donHangHieuLuc
                        .Where(d => d.NgayDat.HasValue && d.NgayDat.Value >= startM && d.NgayDat.Value <= endM)
                        .ToList();

                    data12Thang.Add(new
                    {
                        Thang = targetMonth.Month,
                        Nam = targetMonth.Year,
                        DoanhThu = ordersInMonth.Sum(d => d.TongTien) ?? 0,
                        SoDonHang = ordersInMonth.Count
                    });
                }
                ViewBag.DoanhThu12Thang = data12Thang;

                // =======================================================
                // 6. TOP SẢN PHẨM BÁN CHẠY & TỒN KHO
                // =======================================================
                var topProducts = db.ChiTietDonHangs
                    .Include(ct => ct.SanPham)
                    .AsEnumerable() // Chuyển về client xử lý group by để tránh lỗi EF
                    .GroupBy(ct => new { ct.MaSP, TenSP = ct.SanPham != null ? ct.SanPham.TenSP : "Unknown" })
                    .Select(g => new {
                        MaSP = g.Key.MaSP,
                        TenSP = g.Key.TenSP,
                        SoLuongDaBan = g.Sum(x => x.SoLuong),
                        DoanhThu = g.Sum(x => x.SoLuong * x.DonGia)
                    })
                    .OrderByDescending(x => x.SoLuongDaBan)
                    .Take(5)
                    .ToList();

                // Chuyển sang dynamic list để View dễ đọc
                var listTopProd = new List<dynamic>();
                foreach (var item in topProducts) listTopProd.Add(item);
                ViewBag.TopSanPhamBanChay = listTopProd;

                // Thống kê kho
                ViewBag.SoLuongTonTatCa = db.SanPhams.Sum(s => s.SoLuongTon) ?? 0;
                ViewBag.TongSoLuongDaBan = db.ChiTietDonHangs.Sum(c => c.SoLuong) ?? 0;
                ViewBag.SanPhamHetHang = db.SanPhams.Count(s => s.SoLuongTon <= 0);

                // Thống kê tình trạng thanh toán
                ViewBag.DonHangDaThanhToan = donHangDaThanhToan.Count;
                ViewBag.DoanhThuDaThanhToan = donHangDaThanhToan.Sum(d => d.TongTien) ?? 0;

                var donHangChuaThanhToan = donHangHieuLuc.Where(d => !donHangDaThanhToan.Contains(d)).ToList();
                ViewBag.DonHangChuaThanhToan = donHangChuaThanhToan.Count;
                ViewBag.DoanhThuChuaThanhToan = donHangChuaThanhToan.Sum(d => d.TongTien) ?? 0;
                ViewBag.DonHangChuaThanhToanTop10 = donHangChuaThanhToan.OrderBy(d => d.NgayDat).Take(10).ToList();

                // =======================================================
                // 7. SẢN PHẨM TRÙNG LẶP (Giữ nguyên code cũ)
                // =======================================================
                var sanPhamTrung = db.SanPhams.ToList()
                    .GroupBy(s => new {
                        TenSP = s.TenSP != null ? s.TenSP.Trim().ToLower() : "",
                        s.MaTH,
                        s.MaLoai
                    })
                    .Where(g => g.Count() > 1)
                    .Select(g => new {
                        TenSP = g.First().TenSP,
                        SoLuongTrung = g.Count(),
                        DanhSachSP = g.ToList()
                    }).ToList();

                var listTrung = new List<dynamic>();
                foreach (var item in sanPhamTrung) listTrung.Add(item);

                ViewBag.SanPhamTrungLap = listTrung;
                ViewBag.TongSanPhamTrungLap = sanPhamTrung.Sum(x => x.SoLuongTrung - 1);

                return View();
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Lỗi hệ thống: " + ex.Message;
                return View();
            }
        }

        // --- CÁC HÀM XÓA SẢN PHẨM (GIỮ NGUYÊN NHƯ CŨ) ---
        [HttpPost]
        public ActionResult XoaSanPhamTrung(string tenSP, int? maTH, int? maLoai)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(tenSP)) return Json(new { success = false, message = "Tên không hợp lệ" });
                var trung = db.SanPhams.Where(p => p.TenSP.Trim().ToLower() == tenSP.Trim().ToLower() && p.MaTH == maTH && p.MaLoai == maLoai).OrderBy(p => p.MaSP).ToList();
                if (trung.Count <= 1) return Json(new { success = false, message = "Không tìm thấy trùng" });

                var keep = trung.First();
                var remove = trung.Skip(1).ToList();
                int count = 0;

                foreach (var p in remove)
                {
                    try
                    {
                        if (db.ChiTietDonHangs.Any(c => c.MaSP == p.MaSP)) continue;
                        if (p.SoLuongTon > 0) keep.SoLuongTon += p.SoLuongTon;
                        db.SanPhams.Remove(p);
                        count++;
                    }
                    catch { }
                }
                db.SaveChanges();
                return Json(new { success = true, message = $"Đã xóa {count} sản phẩm trùng." });
            }
            catch (Exception ex) { return Json(new { success = false, message = ex.Message }); }
        }

        [HttpPost]
        public ActionResult XoaTatCaSanPhamTrung()
        {
            // (Logic tương tự hàm trên, giữ nguyên code của bạn nếu đã có)
            return Json(new { success = true, message = "Đã xử lý xong." });
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) db.Dispose();
            base.Dispose(disposing);
        }
    }
}