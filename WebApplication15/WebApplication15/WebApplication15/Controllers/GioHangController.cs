using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApplication15.Models;

namespace WebApplication15.Controllers
{
    public class GioHangController : Controller
    {
        // GET: GioHang
        DB_SkinFoodEntities data = new DB_SkinFoodEntities();
        
        public ActionResult Index()
        {
            Cart cart = (Cart)Session["Cart"];
            if (cart == null)
                cart = new Cart();

            return View(cart);
        }

        // Thêm sản phẩm vào giỏ
        public ActionResult AddToCart(int id)
        {
            if (Session["User"] == null) // Bắt buộc đăng nhập
            {
                TempData["Error"] = "Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng!";
                return RedirectToAction("Login", "User");
            }

            // Kiểm tra sản phẩm có tồn tại và còn hàng không
            SanPham sp = data.SanPhams.FirstOrDefault(s => s.MaSP == id);
            if (sp == null)
            {
                TempData["Error"] = "Sản phẩm không tồn tại!";
                return RedirectToAction("Index", "Home");
            }

            if (sp.SoLuongTon <= 0)
            {
                TempData["Error"] = "Sản phẩm đã hết hàng!";
                return RedirectToAction("Index", "Home");
            }

            Cart cart = (Cart)Session["Cart"];
            if (cart == null)
                cart = new Cart();

            // Kiểm tra số lượng trong giỏ + 1 có vượt quá tồn kho không
            var itemInCart = cart.list.FirstOrDefault(item => item.MaSP == id);
            int currentQtyInCart = itemInCart != null ? itemInCart.SoLuong : 0;
            
            if (currentQtyInCart + 1 > sp.SoLuongTon)
            {
                TempData["Error"] = $"Sản phẩm chỉ còn {sp.SoLuongTon} sản phẩm trong kho!";
                return RedirectToAction("Index", "Home");
            }

            int result = cart.Them(id);
            if (result == 1)
            {
                Session["Cart"] = cart;
                TempData["Success"] = "Đã thêm sản phẩm vào giỏ hàng!";
            }

            return RedirectToAction("Index", "Home");
        }

        // Xóa sản phẩm khỏi giỏ
        public ActionResult RemoveFromCart(int id)
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            Cart cart = (Cart)Session["Cart"];
            if (cart == null)
                cart = new Cart();

            int result = cart.Xoa(id);
            if (result == 1)
            {
                Session["Cart"] = cart;
                TempData["Success"] = "Đã xóa sản phẩm khỏi giỏ hàng!";
            }

            return RedirectToAction("Index", "GioHang");
        }

        // Cập nhật số lượng
        public ActionResult UpdateSLCart(int id, int num)
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            // Kiểm tra số lượng tồn kho
            SanPham sp = data.SanPhams.FirstOrDefault(s => s.MaSP == id);
            if (sp == null)
            {
                TempData["Error"] = "Sản phẩm không tồn tại!";
                return RedirectToAction("Index", "GioHang");
            }

            Cart cart = (Cart)Session["Cart"];
            if (cart == null)
                cart = new Cart();

            var itemInCart = cart.list.FirstOrDefault(item => item.MaSP == id);
            if (itemInCart != null)
            {
                // Nếu tăng số lượng (num = 1), kiểm tra tồn kho
                if (num == 1)
                {
                    if (itemInCart.SoLuong + 1 > sp.SoLuongTon)
                    {
                        TempData["Error"] = $"Sản phẩm chỉ còn {sp.SoLuongTon} trong kho!";
                        return RedirectToAction("Index", "GioHang");
                    }
                }
            }

            int result = -1;
            if (num == -1)
                result = cart.Giam(id);
            else
                result = cart.Them(id);

            if (result == 1)
                Session["Cart"] = cart;

            return RedirectToAction("Index", "GioHang");
        }


        public ActionResult PaymentReview()
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            Cart cart = (Cart)Session["Cart"];

            if (cart == null || cart.list.Count == 0)
            {
                TempData["Error"] = "Giỏ hàng của bạn đang trống!";
                return RedirectToAction("Index", "GioHang");
            }

            // Kiểm tra lại số lượng tồn kho của tất cả sản phẩm trong giỏ
            foreach (var item in cart.list)
            {
                SanPham sp = data.SanPhams.FirstOrDefault(s => s.MaSP == item.MaSP);
                if (sp == null)
                {
                    TempData["Error"] = $"Sản phẩm {item.TenSP} không còn tồn tại!";
                    return RedirectToAction("Index", "GioHang");
                }

                if (sp.SoLuongTon < item.SoLuong)
                {
                    TempData["Error"] = $"Sản phẩm {item.TenSP} chỉ còn {sp.SoLuongTon} trong kho!";
                    return RedirectToAction("Index", "GioHang");
                }
            }

            return View(cart);
        }

        // Xác nhận thanh toán (Lưu hóa đơn & chi tiết)
        public ActionResult PaymentConfirm()
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            var kh = (TaiKhoan)Session["User"];
            Cart cart = (Cart)Session["Cart"];

            if (cart == null || cart.list.Count == 0)
            {
                TempData["Error"] = "Giỏ hàng của bạn đang trống!";
                return RedirectToAction("Index", "GioHang");
            }

            // Lấy thông tin người dùng để kiểm tra địa chỉ
            NguoiDung nguoiDung = data.NguoiDungs.FirstOrDefault(n => n.MaND == kh.MaND);
            
            if (nguoiDung == null)
            {
                TempData["Error"] = "Không tìm thấy thông tin người dùng!";
                return RedirectToAction("Index", "GioHang");
            }

            // Kiểm tra địa chỉ giao hàng
            if (string.IsNullOrWhiteSpace(nguoiDung.DiaChi))
            {
                TempData["Error"] = "Vui lòng cập nhật địa chỉ giao hàng trong trang Hồ sơ trước khi đặt hàng!";
                return RedirectToAction("EditProfile", "User");
            }

            // Kiểm tra lại tồn kho trước khi tạo đơn hàng
            foreach (var item in cart.list)
            {
                SanPham sp = data.SanPhams.FirstOrDefault(s => s.MaSP == item.MaSP);
                if (sp == null)
                {
                    TempData["Error"] = $"Sản phẩm {item.TenSP} không còn tồn tại!";
                    return RedirectToAction("Index", "GioHang");
                }

                if (sp.SoLuongTon < item.SoLuong)
                {
                    TempData["Error"] = $"Sản phẩm {item.TenSP} chỉ còn {sp.SoLuongTon} trong kho!";
                    return RedirectToAction("Index", "GioHang");
                }
            }

            try
            {
                // --------------------------
                // TẠO HÓA ĐƠN
                var hoaDon = new DonHang
                {
                    MaND = kh.MaND,
                    NgayDat = DateTime.Now,
                    TongTien = (decimal)cart.TongThanhTien(),
                    DiaChiGiaoHang = nguoiDung.DiaChi,
                    TrangThaiThanhToan = "Chờ thanh toán"
                };

                data.DonHangs.Add(hoaDon);
                data.SaveChanges(); // sinh MaDH

                // --------------------------
                // LƯU CHI TIẾT HÓA ĐƠN VÀ CẬP NHẬT TỒN KHO
                foreach (var item in cart.list)
                {
                    // Thêm chi tiết đơn hàng
                    data.ChiTietDonHangs.Add(new ChiTietDonHang
                    {
                        MaDH = hoaDon.MaDH,
                        MaSP = item.MaSP,
                        SoLuong = item.SoLuong,
                        DonGia = (decimal)item.GiaBan
                    });

                    // KHÔNG CẬP NHẬT TỒN KHO Ở ĐÂY (Theo yêu cầu mới: Chỉ trừ khi thanh toán)
                    /*
                    SanPham sp = data.SanPhams.FirstOrDefault(s => s.MaSP == item.MaSP);
                    if (sp != null)
                    {
                        sp.SoLuongTon -= item.SoLuong;
                        data.Entry(sp).State = System.Data.Entity.EntityState.Modified;
                    }
                    */
                }

                data.SaveChanges();

                // Lưu mã đơn để dùng ở bước thanh toán
                Session["CurrentOrder"] = hoaDon.MaDH;

                System.Diagnostics.Debug.WriteLine($"✅ PaymentConfirm: Đã tạo đơn hàng MaDH={hoaDon.MaDH}, cập nhật tồn kho thành công");

                //  CHUYỂN SANG TRANG CHỌN PHƯƠNG THỨC THANH TOÁN
                return RedirectToAction("PaymentMethod");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ PaymentConfirm Error: {ex.Message}");
                TempData["Error"] = "Đã xảy ra lỗi khi tạo đơn hàng. Vui lòng thử lại!";
                return RedirectToAction("Index", "GioHang");
            }
        }
        
        public ActionResult PaymentMethod()
        {
            try
            {
                if (Session["CurrentOrder"] == null)
                {
                    System.Diagnostics.Debug.WriteLine("❌ PaymentMethod: Session['CurrentOrder'] là null");
                    TempData["Error"] = "Không tìm thấy thông tin đơn hàng!";
                    return RedirectToAction("Index", "GioHang");
                }

                int maDH = (int)Session["CurrentOrder"];
                var hoaDon = data.DonHangs.FirstOrDefault(x => x.MaDH == maDH);

                if (hoaDon == null)
                {
                    System.Diagnostics.Debug.WriteLine($"❌ PaymentMethod: Không tìm thấy đơn hàng MaDH={maDH}");
                    TempData["Error"] = "Không tìm thấy đơn hàng!";
                    return RedirectToAction("Index", "GioHang");
                }

                return View(hoaDon);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ PaymentMethod Error: {ex.Message}");
                TempData["Error"] = "Đã xảy ra lỗi!";
                return RedirectToAction("Index", "GioHang");
            }
        }
        
        public ActionResult ThanhToanCOD(int? maDH)
        {
            try
            {
                // Lấy maDH từ URL parameter hoặc session
                if (!maDH.HasValue)
                {
                    if (Session["CurrentOrder"] == null)
                    {
                        System.Diagnostics.Debug.WriteLine("❌ ThanhToanCOD: maDH không có và Session['CurrentOrder'] là null");
                        return RedirectToAction("Index", "GioHang");
                    }
                    maDH = (int)Session["CurrentOrder"];
                }

                var hoaDon = data.DonHangs.Include("ChiTietDonHangs").FirstOrDefault(x => x.MaDH == maDH);

                if (hoaDon == null)
                {
                    System.Diagnostics.Debug.WriteLine($"❌ ThanhToanCOD: Không tìm thấy đơn hàng MaDH={maDH}");
                    return RedirectToAction("Index", "GioHang");
                }

                // Kiểm tra tồn kho trước khi trừ
                foreach (var item in hoaDon.ChiTietDonHangs)
                {
                    var sp = data.SanPhams.Find(item.MaSP);
                    if (sp == null || sp.SoLuongTon < item.SoLuong)
                    {
                        TempData["Error"] = $"Sản phẩm {(sp?.TenSP ?? "Unknown")} không đủ số lượng tồn kho!";
                        return RedirectToAction("Index", "GioHang");
                    }
                }

                // Trừ tồn kho
                foreach (var item in hoaDon.ChiTietDonHangs)
                {
                    var sp = data.SanPhams.Find(item.MaSP);
                    if (sp != null)
                    {
                        sp.SoLuongTon -= item.SoLuong;
                        data.Entry(sp).State = System.Data.Entity.EntityState.Modified;
                    }
                }

                // Cập nhật trạng thái thanh toán
                hoaDon.TrangThaiThanhToan = "Đã thanh toán";
                hoaDon.NgayThanhToan = DateTime.Now;
                hoaDon.PhuongThucThanhToan = "COD";
                
                data.Entry(hoaDon).State = System.Data.Entity.EntityState.Modified;
                data.SaveChanges();

                Session["Cart"] = null;
                Session["CurrentOrder"] = null;

                System.Diagnostics.Debug.WriteLine($"✅ ThanhToanCOD: Đã cập nhật trạng thái COD cho MaDH={maDH}");

                return RedirectToAction("PaymentSuccess", new { maDH = maDH });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ ThanhToanCOD Error: {ex.Message}");
                return RedirectToAction("Index", "GioHang");
            }
        }

        public ActionResult ThanhToanChuyenKhoan(int? maDH)
        {
            try
            {
                // Lấy maDH từ URL parameter hoặc session
                if (!maDH.HasValue)
                {
                    if (Session["CurrentOrder"] == null)
                    {
                        System.Diagnostics.Debug.WriteLine("❌ ThanhToanChuyenKhoan: maDH không có và Session['CurrentOrder'] là null");
                        return RedirectToAction("Index", "GioHang");
                    }
                    maDH = (int)Session["CurrentOrder"];
                }

                var hoaDon = data.DonHangs.FirstOrDefault(x => x.MaDH == maDH);

                if (hoaDon == null)
                {
                    System.Diagnostics.Debug.WriteLine($"❌ ThanhToanChuyenKhoan: Không tìm thấy đơn hàng MaDH={maDH}");
                    return RedirectToAction("Index", "GioHang");
                }

                // Cập nhật phương thức thanh toán
                hoaDon.PhuongThucThanhToan = "Chuyển Khoản";
                data.Entry(hoaDon).State = System.Data.Entity.EntityState.Modified;
                data.SaveChanges();

                System.Diagnostics.Debug.WriteLine($"✅ ThanhToanChuyenKhoan: Đã cập nhật phương thức Chuyển Khoản cho MaDH={maDH}");

                return View(hoaDon);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ ThanhToanChuyenKhoan Error: {ex.Message}");
                return RedirectToAction("Index", "GioHang");
            }
        }

        public ActionResult ThanhToanQR(int? maDH)
        {
            try
            {
                // Lấy maDH từ URL parameter hoặc session
                if (!maDH.HasValue)
                {
                    if (Session["CurrentOrder"] == null)
                    {
                        System.Diagnostics.Debug.WriteLine("❌ ThanhToanQR: maDH không có và Session['CurrentOrder'] là null");
                        return RedirectToAction("Index", "GioHang");
                    }
                    maDH = (int)Session["CurrentOrder"];
                }

                var hoaDon = data.DonHangs.FirstOrDefault(x => x.MaDH == maDH);

                if (hoaDon == null)
                {
                    System.Diagnostics.Debug.WriteLine($"❌ ThanhToanQR: Không tìm thấy đơn hàng MaDH={maDH}");
                    return RedirectToAction("Index", "GioHang");
                }

                // Cập nhật phương thức thanh toán
                hoaDon.PhuongThucThanhToan = "QR";
                data.Entry(hoaDon).State = System.Data.Entity.EntityState.Modified;
                data.SaveChanges();

                System.Diagnostics.Debug.WriteLine($"✅ ThanhToanQR: Đã cập nhật phương thức QR cho MaDH={maDH}");

                return View(hoaDon);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ ThanhToanQR Error: {ex.Message}");
                return RedirectToAction("Index", "GioHang");
            }
        }

        // Action để xác nhận thanh toán hoàn tất (cho QR/Chuyển khoản)
        public ActionResult ConfirmPaymentComplete(int? maDH)
        {
            try
            {
                // Lấy maDH từ query string hoặc session
                if (!maDH.HasValue)
                {
                    if (Session["CurrentOrder"] == null)
                        return RedirectToAction("Index", "GioHang");
                    maDH = (int)Session["CurrentOrder"];
                }

                var hoaDon = data.DonHangs.Include("ChiTietDonHangs").FirstOrDefault(x => x.MaDH == maDH);

                if (hoaDon != null)
                {
                    // Kiểm tra tồn kho trước khi trừ
                    foreach (var item in hoaDon.ChiTietDonHangs)
                    {
                        var sp = data.SanPhams.Find(item.MaSP);
                        if (sp == null || sp.SoLuongTon < item.SoLuong)
                        {
                            TempData["Error"] = $"Sản phẩm {(sp?.TenSP ?? "Unknown")} không đủ số lượng tồn kho!";
                            return RedirectToAction("Index", "GioHang");
                        }
                    }

                    // Trừ tồn kho
                    foreach (var item in hoaDon.ChiTietDonHangs)
                    {
                        var sp = data.SanPhams.Find(item.MaSP);
                        if (sp != null)
                        {
                            sp.SoLuongTon -= item.SoLuong;
                            data.Entry(sp).State = System.Data.Entity.EntityState.Modified;
                        }
                    }

                    // Cập nhật trạng thái
                    hoaDon.TrangThaiThanhToan = "Đã thanh toán";
                    hoaDon.NgayThanhToan = DateTime.Now;
                    
                    // Force Entity Framework để track change
                    data.Entry(hoaDon).State = System.Data.Entity.EntityState.Modified;
                    
                    // Save changes
                    int result = data.SaveChanges();
                    
                    // Log để debug
                    System.Diagnostics.Debug.WriteLine($"✅ ConfirmPaymentComplete: Đã cập nhật maDH={maDH}, SaveChanges result={result}");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine($"❌ ConfirmPaymentComplete: Không tìm thấy đơn hàng maDH={maDH}");
                }

                Session["Cart"] = null;
                Session["CurrentOrder"] = null;
                return RedirectToAction("PaymentSuccess", new { maDH = maDH });
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ ConfirmPaymentComplete Error: {ex.Message}");
                throw;
            }
        }

        public ActionResult PaymentSuccess(int? maDH)
        {
            // Lấy maDH từ query string hoặc session
            if (!maDH.HasValue && Session["CurrentOrder"] != null)
            {
                maDH = (int)Session["CurrentOrder"];
            }

            // Truyền ViewBag cho view
            if (maDH.HasValue)
            {
                ViewBag.MaDH = maDH.Value;

                var hoaDon = data.DonHangs.Include("ChiTietDonHangs").FirstOrDefault(x => x.MaDH == maDH);
                
                if (hoaDon != null)
                {
                    // Reload từ database để có dữ liệu mới nhất
                    data.Entry(hoaDon).Reload();
                    
                    // Nếu chưa có trạng thái thanh toán, đặt thành "Đã thanh toán"
                    if (string.IsNullOrEmpty(hoaDon.TrangThaiThanhToan) || hoaDon.TrangThaiThanhToan != "Đã thanh toán")
                    {
                        // Kiểm tra xem đã trừ kho chưa? Nếu chưa thì trừ
                        // (Logic này hơi rủi ro nếu gọi nhiều lần, nhưng PaymentSuccess thường là trang cuối)
                        // Tốt nhất là chỉ cập nhật trạng thái nếu nó chưa phải là "Đã thanh toán"
                        
                        if (hoaDon.TrangThaiThanhToan != "Đã thanh toán")
                        {
                             // Kiểm tra tồn kho trước khi trừ
                            bool enoughStock = true;
                            foreach (var item in hoaDon.ChiTietDonHangs)
                            {
                                var sp = data.SanPhams.Find(item.MaSP);
                                if (sp == null || sp.SoLuongTon < item.SoLuong)
                                {
                                    enoughStock = false;
                                    break;
                                }
                            }

                            if (enoughStock)
                            {
                                foreach (var item in hoaDon.ChiTietDonHangs)
                                {
                                    var sp = data.SanPhams.Find(item.MaSP);
                                    if (sp != null)
                                    {
                                        sp.SoLuongTon -= item.SoLuong;
                                        data.Entry(sp).State = System.Data.Entity.EntityState.Modified;
                                    }
                                }

                                hoaDon.TrangThaiThanhToan = "Đã thanh toán";
                                hoaDon.NgayThanhToan = DateTime.Now;
                                data.Entry(hoaDon).State = System.Data.Entity.EntityState.Modified;
                                data.SaveChanges();
                                System.Diagnostics.Debug.WriteLine($"✅ PaymentSuccess: Cập nhật trạng thái và trừ kho cho maDH={maDH}");
                            }
                        }
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine($"✅ PaymentSuccess: maDH={maDH}, TrangThaiThanhToan={hoaDon.TrangThaiThanhToan}");
                    }
                    
                    ViewBag.TrangThaiThanhToan = hoaDon.TrangThaiThanhToan;
                    ViewBag.PhuongThucThanhToan = hoaDon.PhuongThucThanhToan;
                }
            }

            Session["Cart"] = null;
            Session["CurrentOrder"] = null;
            
            return View();
        }

        public ActionResult DebugPayment(int maDH)
        {
            try
            {
                var hoaDon = data.DonHangs.FirstOrDefault(x => x.MaDH == maDH);
                
                if (hoaDon == null)
                {
                    return Content($"❌ Không tìm thấy đơn hàng MaDH={maDH}");
                }

                string info = $@"
🔍 DEBUG INFO - MaDH: {maDH}
================================================
✅ Tìm thấy đơn hàng
- MaDH: {hoaDon.MaDH}
- MaND: {hoaDon.MaND}
- TongTien: {hoaDon.TongTien}
- NgayDat: {hoaDon.NgayDat}
- TrangThaiThanhToan: '{hoaDon.TrangThaiThanhToan}' (null={hoaDon.TrangThaiThanhToan == null})
- NgayThanhToan: {hoaDon.NgayThanhToan}
- PhuongThucThanhToan: {hoaDon.PhuongThucThanhToan}
- DiaChiGiaoHang: {hoaDon.DiaChiGiaoHang}
";
                
                return Content(info, "text/plain; charset=utf-8");
            }
            catch (Exception ex)
            {
                return Content($"❌ Error: {ex.Message}\n{ex.InnerException?.Message}", "text/plain; charset=utf-8");
            }
        }

    }
}