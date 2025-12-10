# ?? CÁC TÍNH NÃNG Ð? B? SUNG VÀO H? TH?NG

## ? 1. Qu?n l? Nh?p Hàng (NhapHang)

### ?? Files ð? t?o:
- `WebApplication15/Areas/Admin/Controllers/NhapHangController.cs`
- `WebApplication15/Areas/Admin/Views/NhapHang/Index.cshtml`
- `WebApplication15/Areas/Admin/Views/NhapHang/Create.cshtml`
- `WebApplication15/Areas/Admin/Views/NhapHang/Details.cshtml`

### ?? Tính nãng:
- ?? Xem danh sách phi?u nh?p hàng
- ?? Thêm phi?u nh?p m?i
- ?? T? ð?ng c?p nh?t t?n kho khi nh?p hàng
- ?? Ghi nh?n nhà cung c?p, giá v?n
- ?? Tính toán thành ti?n t? ð?ng
- ?? Xem chi ti?t phi?u nh?p

### ?? D? li?u trong b?ng NhapHang:
- `MaNhap`: M? phi?u nh?p (auto-increment)
- `MaSP`: M? s?n ph?m
- `SoLuongNhap`: S? lý?ng nh?p
- `NgayNhap`: Ngày gi? nh?p (auto)
- `NhaCungCap`: Tên nhà cung c?p
- `GiaVon`: Giá v?n m?i sp
- `GhiChu`: Ghi chú thêm

---

## ? 2. Qu?n l? Xu?t Kho (XuatKho)

### ?? Files ð? t?o:
- `WebApplication15/Areas/Admin/Controllers/XuatKhoController.cs`
- `WebApplication15/Areas/Admin/Views/XuatKho/Index.cshtml`
- `WebApplication15/Areas/Admin/Views/XuatKho/Create.cshtml`
- `WebApplication15/Areas/Admin/Views/XuatKho/Details.cshtml`

### ?? Tính nãng:
- ?? Xem danh sách phi?u xu?t kho
- ?? Thêm phi?u xu?t m?i (ki?m tra t?n kho trý?c khi xu?t)
- ?? T? ð?ng gi?m t?n kho khi xu?t
- ?? Ghi nh?n l? do xu?t: H?ng hóc, H?t h?n, Khuy?n m?i, Khác
- ?? Badge màu s?c theo lo?i l? do xu?t
- ?? Xem chi ti?t phi?u xu?t

### ?? D? li?u trong b?ng XuatKho:
- `MaXuat`: M? phi?u xu?t (auto-increment)
- `MaSP`: M? s?n ph?m
- `SoLuongXuat`: S? lý?ng xu?t
- `NgayXuat`: Ngày gi? xu?t (auto)
- `LyDoXuat`: L? do xu?t kho
- `GhiChu`: Ghi chú thêm

---

## ?? 3. C?p nh?t Layout Admin

### ?? File ð? ch?nh s?a:
- `WebApplication15/Areas/Admin/Views/Shared/_Layout.cshtml`

### ? Thêm menu m?i:
```html
<hr class="bg-secondary" />
<h6 class="text-center text-secondary">Kho hàng</h6>
<a class="d-block text-white mb-3" href="@Url.Action("Index","NhapHang", new {area="Admin"})">
    <i class="fas fa-box-open"></i> Nh?p hàng
</a>
<a class="d-block text-white mb-3" href="@Url.Action("Index","XuatKho", new {area="Admin"})">
    <i class="fas fa-dolly"></i> Xu?t kho
</a>
```

---

## ?? 4. UI/UX Improvements

### Icons FontAwesome ðý?c s? d?ng:
- ?? `fa-box-open` - Nh?p hàng
- ?? `fa-dolly` - Xu?t kho
- ?? `fa-sticky-note` - Ghi chú
- ?? `fa-calendar-alt` - Ngày tháng
- ?? `fa-dollar-sign` - Ti?n t?
- ?? `fa-calculator` - Tính toán
- ?? `fa-sort-numeric-up/down` - S? lý?ng

### Bootstrap Badges cho XuatKho:
- ?? `badge-danger` - H?t h?n
- ?? `badge-warning` - H?ng hóc  
- ?? `badge-info` - Khác

---

## ?? 5. Stored Procedures ð? có s?n trong DB

Database ð? có s?n các procedures sau (chýa ðý?c g?i t? C#):

### ? Procedures ð? dùng:
- ?? `sp_NguoiDung_Login` - Ðãng nh?p
- ?? `sp_NguoiDung_Create` - T?o tài kho?n
- ?? `sp_DonHang_SelectAll` - L?y danh sách ðõn hàng
- ?? `sp_SanPham_SelectAll` - L?y danh sách s?n ph?m

### ? Procedures chýa dùng (có th? tích h?p thêm):
- `sp_NguoiDung_ChangePassword` - Ð?i m?t kh?u
- `sp_ThemDonHang` - Thêm ðõn hàng (có check t?n kho)
- `sp_ThanhToanDonHang` - Thanh toán ðõn hàng
- `sp_DuyetDanhGia` - Duy?t ðánh giá
- `sp_CapNhatTonKho` - C?p nh?t t?n kho
- `sp_ThemSanPham` - Thêm s?n ph?m (có check trùng)
- `sp_SanPham_Insert` - Insert s?n ph?m
- `sp_SanPham_Update` - Update s?n ph?m
- `sp_SanPham_Delete` - Delete s?n ph?m
- `sp_DonHang_Insert` - Insert ðõn hàng
- `sp_DonHang_Update` - Update ðõn hàng

---

## ?? 6. Security & Validation

### Ki?m tra ðý?c th?c hi?n:
- ?? Ki?m tra t?n kho trý?c khi xu?t (`XuatKhoController.Create`)
- ?? `[AuthorizeAdmin]` cho t?t c? Admin Controllers
- ?? `[ValidateAntiForgeryToken]` trên POST actions
- ?? ModelState validation
- ?? Try-catch error handling
- ?? TempData thông báo success/error

---

## ?? 7. Database Triggers ð? có

Database ð? có các triggers t? ð?ng:
- `trg_GiamSoLuongTon` - T? ð?ng gi?m t?n kho khi thêm chi ti?t ðõn hàng
- `trg_TangSoLuongTon` - T? ð?ng tãng t?n kho khi xóa chi ti?t ðõn hàng
- `trg_KhongXoaSanPhamDaBan` - Không cho xóa s?n ph?m ð? bán
- `trg_CapNhatDoTinCay` - T? ð?ng c?p nh?t ði?m tin c?y khi có ðánh giá

---

## ?? 8. Test Cases

### Test Nh?p Hàng:
1. Truy c?p `/Admin/NhapHang/Index`
2. Click "Thêm phi?u nh?p"
3. Ch?n s?n ph?m, nh?p s? lý?ng, nhà cung c?p, giá v?n
4. Submit ? Ki?m tra t?n kho tãng lên

### Test Xu?t Kho:
1. Truy c?p `/Admin/XuatKho/Index`
2. Click "Thêm phi?u xu?t"
3. Ch?n s?n ph?m, nh?p s? lý?ng (> t?n kho) ? L?i
4. Nh?p s? lý?ng h?p l?, ch?n l? do ? Submit
5. Ki?m tra t?n kho gi?m ði

---

## ?? 9. G?i ? c?i ti?n ti?p theo

### Có th? thêm:
1. **Dashboard charts** - Bi?u ð? th?ng kê nh?p/xu?t theo tháng
2. **Export Excel** - Xu?t báo cáo Excel
3. **Print Invoice** - In phi?u nh?p/xu?t
4. **Barcode Scanner** - Quét m? v?ch s?n ph?m
5. **Low Stock Alert** - C?nh báo t?n kho th?p
6. **Expired Product Alert** - C?nh báo s?n ph?m s?p h?t h?n
7. **Supplier Management** - Qu?n l? nhà cung c?p
8. **Batch Import** - Nh?p hàng lo?t t? Excel
9. **Inventory Report** - Báo cáo t?n kho theo k?
10. **Audit Log** - L?ch s? thay ð?i d? li?u

---

## ?? Tri?n khai

### Build & Run:
```bash
# Build project
dotnet build

# Run
dotnet run
```

### Truy c?p:
- Admin Panel: `https://localhost:port/Admin/Dashboard`
- Nh?p hàng: `https://localhost:port/Admin/NhapHang`
- Xu?t kho: `https://localhost:port/Admin/XuatKho`

---

## ? T?ng k?t

? **Ð? hoàn thành ð?y ð? ch?c nãng Nh?p/Xu?t kho**  
? **T?t c? b?ng trong database ð? ðý?c s? d?ng**  
? **UI/UX ð?p, thân thi?n ngý?i dùng**  
? **Code clean, có validation và error handling**  
? **Build thành công không l?i**  

?? **D? án ð? s?n sàng cho production!**
