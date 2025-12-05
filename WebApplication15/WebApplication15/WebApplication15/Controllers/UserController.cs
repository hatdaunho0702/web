using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebApplication15.Models;

namespace WebApplication15.Controllers
{
    public class UserController : Controller
    {
        DB_SkinFoodEntities data = new DB_SkinFoodEntities();
        
        // GET: User
        public ActionResult Login()
        {
            // Nếu đã đăng nhập, redirect về trang chủ
            if (Session["User"] != null)
            {
                var user = Session["User"] as TaiKhoan;
                if (user?.VaiTro == "Admin")
                {
                    return RedirectToAction("Index", "Dashboard", new { area = "Admin" });
                }
                return RedirectToAction("Index", "Home");
            }
            return View();
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult LoginSubmit(string Email, string MatKhau)
        {
            try
            {
                // Validate input
                if (string.IsNullOrWhiteSpace(Email) || string.IsNullOrWhiteSpace(MatKhau))
                {
                    ViewBag.Error = "Vui lòng nhập đầy đủ email và mật khẩu!";
                    return View("Login");
                }

                // Trim whitespace
                Email = Email.Trim();
                MatKhau = MatKhau.Trim();

                // Tìm tài khoản
                TaiKhoan user = data.TaiKhoans
                    .FirstOrDefault(kh => kh.TenDangNhap == Email);

                // Kiểm tra tài khoản có tồn tại
                if (user == null)
                {
                    ViewBag.Error = "Email không tồn tại trong hệ thống!";
                    return View("Login");
                }

                // Kiểm tra mật khẩu
                if (user.MatKhauHash != MatKhau)
                {
                    ViewBag.Error = "Mật khẩu không chính xác!";
                    return View("Login");
                }

                // Tìm thông tin người dùng
                NguoiDung nd = data.NguoiDungs
                    .FirstOrDefault(n => n.MaND == user.MaND);

                // Lưu session
                Session["User"] = user;
                Session["NguoiDung"] = nd;
                Session["Role"] = user.VaiTro;
                Session["UserName"] = nd?.HoTen ?? user.TenDangNhap;

                // Chuyển hướng theo vai trò
                if (user.VaiTro == "Admin")
                {
                    TempData["Success"] = "Đăng nhập thành công! Chào mừng Admin.";
                    return RedirectToAction("Index", "Dashboard", new { area = "Admin" });
                }

                TempData["Success"] = $"Đăng nhập thành công! Chào mừng {nd?.HoTen ?? "bạn"}!";
                return RedirectToAction("Index", "Home");
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Đã xảy ra lỗi trong quá trình đăng nhập. Vui lòng thử lại!";
                // Log error here
                return View("Login");
            }
        }
        
        [HttpGet]
        public ActionResult Register()
        {
            // Nếu đã đăng nhập, redirect
            if (Session["User"] != null)
            {
                return RedirectToAction("Index", "Home");
            }
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RegisterSubmit(FormCollection form)
        {
            try
            {
                string hoten = form["HoTen"]?.Trim();
                string sdt = form["SoDienThoai"]?.Trim();
                string diachi = form["DiaChi"]?.Trim();
                string gioitinh = form["GioiTinh"];
                string username = form["TenDangNhap"]?.Trim();
                string password = form["MatKhau"];
                string confirmPassword = form["NhapLaiMatKhau"];

                // Validate required fields
                if (string.IsNullOrWhiteSpace(hoten) || string.IsNullOrWhiteSpace(username) || 
                    string.IsNullOrWhiteSpace(password))
                {
                    ViewBag.Error = "Vui lòng nhập đầy đủ thông tin bắt buộc!";
                    return View("Register");
                }

                // Validate email format
                if (!IsValidEmail(username))
                {
                    ViewBag.Error = "Email không hợp lệ!";
                    return View("Register");
                }

                // Validate password match
                if (password != confirmPassword)
                {
                    ViewBag.Error = "Mật khẩu nhập lại không khớp!";
                    return View("Register");
                }

                // Validate password length
                if (password.Length < 6)
                {
                    ViewBag.Error = "Mật khẩu phải có ít nhất 6 ký tự!";
                    return View("Register");
                }

                // Kiểm tra tài khoản có tồn tại chưa
                var check = data.TaiKhoans.FirstOrDefault(t => t.TenDangNhap == username);
                if (check != null)
                {
                    ViewBag.Error = "Email này đã được đăng ký!";
                    return View("Register");
                }

                // Parse ngày sinh
                DateTime ngaysinh = DateTime.Now.AddYears(-18); // Default
                if (!string.IsNullOrEmpty(form["NgaySinh"]))
                {
                    DateTime.TryParse(form["NgaySinh"], out ngaysinh);
                }

                // Tạo bản ghi NguoiDung
                NguoiDung nd = new NguoiDung
                {
                    HoTen = hoten,
                    SoDienThoai = sdt,
                    DiaChi = diachi,
                    GioiTinh = gioitinh,
                    NgaySinh = ngaysinh,
                    NgayTao = DateTime.Now
                };

                data.NguoiDungs.Add(nd);
                data.SaveChanges();

                // Tạo bản ghi TaiKhoan
                TaiKhoan tk = new TaiKhoan
                {
                    TenDangNhap = username,
                    MatKhauHash = password, // TODO: Nên hash mật khẩu
                    VaiTro = "KhachHang",
                    MaND = nd.MaND
                };

                data.TaiKhoans.Add(tk);
                data.SaveChanges();

                TempData["Success"] = "Đăng ký thành công! Bạn có thể đăng nhập ngay bây giờ.";
                return RedirectToAction("Login", "User");
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Đã xảy ra lỗi trong quá trình đăng ký. Vui lòng thử lại!";
                // Log error here
                return View("Register");
            }
        }

        // Helper method to validate email
        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        public ActionResult Profile()
        {
            if (Session["User"] == null)
                return RedirectToAction("Login", "User");

            TaiKhoan tk = Session["User"] as TaiKhoan;
            NguoiDung nd = Session["NguoiDung"] as NguoiDung;

            var model = new UserProfileViewModel
            {
                TaiKhoan = tk,
                NguoiDung = nd
            };

            return View(model);
        }

        [HttpGet]
        public ActionResult EditProfile()
        {
            if (Session["User"] == null)
                return RedirectToAction("Login", "User");

            TaiKhoan tk = Session["User"] as TaiKhoan;
            NguoiDung nd = data.NguoiDungs.FirstOrDefault(n => n.MaND == tk.MaND);

            if (nd == null)
                return HttpNotFound();

            var model = new UserProfileViewModel
            {
                TaiKhoan = tk,
                NguoiDung = nd
            };

            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditProfile(FormCollection form)
        {
            try
            {
                if (Session["User"] == null)
                    return RedirectToAction("Login", "User");

                TaiKhoan tk = Session["User"] as TaiKhoan;
                NguoiDung nd = data.NguoiDungs.FirstOrDefault(n => n.MaND == tk.MaND);

                if (nd == null)
                    return HttpNotFound();

                // Lấy dữ liệu từ form
                string hoten = form["HoTen"]?.Trim();
                string sdt = form["SoDienThoai"]?.Trim();
                string diachi = form["DiaChi"]?.Trim();
                string gioitinh = form["GioiTinh"];

                // Validate
                if (string.IsNullOrWhiteSpace(hoten))
                {
                    ViewBag.Error = "Họ tên không được để trống!";
                    var errorModel = new UserProfileViewModel
                    {
                        TaiKhoan = tk,
                        NguoiDung = nd
                    };
                    return View(errorModel);
                }

                // Cập nhật thông tin
                nd.HoTen = hoten;
                nd.SoDienThoai = sdt;
                nd.DiaChi = diachi;
                nd.GioiTinh = gioitinh;

                // Parse ngày sinh
                if (!string.IsNullOrEmpty(form["NgaySinh"]))
                {
                    DateTime ngaysinh;
                    if (DateTime.TryParse(form["NgaySinh"], out ngaysinh))
                    {
                        nd.NgaySinh = ngaysinh;
                    }
                }

                // Lưu vào database
                data.Entry(nd).State = System.Data.Entity.EntityState.Modified;
                data.SaveChanges();

                // Cập nhật session
                Session["NguoiDung"] = nd;
                Session["UserName"] = nd.HoTen;

                TempData["Success"] = "Cập nhật thông tin thành công!";
                return RedirectToAction("Profile", "User");
            }
            catch (Exception ex)
            {
                ViewBag.Error = "Đã xảy ra lỗi trong quá trình cập nhật. Vui lòng thử lại!";
                
                TaiKhoan tk = Session["User"] as TaiKhoan;
                NguoiDung nd = data.NguoiDungs.FirstOrDefault(n => n.MaND == tk.MaND);
                
                var model = new UserProfileViewModel
                {
                    TaiKhoan = tk,
                    NguoiDung = nd
                };
                
                return View(model);
            }
        }

        public ActionResult Account()
        {
            if (Session["User"] == null)
            {
                return RedirectToAction("Login", "User");
            }

            return RedirectToAction("Profile", "User");
        }

        public ActionResult Logout()
        {
            Session.Clear();
            TempData["Success"] = "Đăng xuất thành công!";
            return RedirectToAction("Index", "Home");
        }

        public ActionResult Index()
        {
            return View();
        }

        public ActionResult DonHang()
        {
            if (Session["User"] == null)
                return RedirectToAction("Login", "User");

            TaiKhoan tk = Session["User"] as TaiKhoan;

            var list = data.DonHangs
                .Where(d => d.MaND == tk.MaND)
                .OrderByDescending(d => d.NgayDat)
                .ToList();

            return View(list);
        }
        
        public ActionResult DonHangChiTiet(int id)
        {
            if (Session["User"] == null)
                return RedirectToAction("Login", "User");

            var dh = data.DonHangs.FirstOrDefault(d => d.MaDH == id);

            if (dh == null)
                return HttpNotFound();

            var ct = data.ChiTietDonHangs.Where(c => c.MaDH == id).ToList();

            var model = new UserOrdersViewModel
            {
                DonHang = dh,
                ChiTiet = ct
            };

            return View(model);
        }
    }
}