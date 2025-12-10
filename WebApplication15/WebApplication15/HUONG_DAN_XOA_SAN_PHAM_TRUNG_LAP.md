# HÝ?NG D?N S? D?NG CH?C NÃNG XÓA S?N PH?M TRÙNG L?P

## ?? T?ng Quan

Ð? thêm ch?c nãng phát hi?n và xóa s?n ph?m trùng l?p trong Dashboard Admin. H? th?ng s? t? ð?ng:
- Phát hi?n các s?n ph?m có cùng tên, thýõng hi?u và lo?i
- Gi? l?i s?n ph?m có MaSP nh? nh?t
- C?ng t?n kho c?a các s?n ph?m trùng vào s?n ph?m ðý?c gi? l?i
- Xóa các s?n ph?m trùng c?n l?i (n?u chýa có trong ðõn hàng)

---

## ?? Tính Nãng

### 1. Phát Hi?n S?n Ph?m Trùng L?p

**Tiêu chí phát hi?n:**
- Tên s?n ph?m gi?ng nhau (không phân bi?t hoa/thý?ng, kho?ng tr?ng)
- Cùng thýõng hi?u (MaTH)
- Cùng lo?i s?n ph?m (MaLoai)

**Hi?n th?:**
- B?ng danh sách các nhóm s?n ph?m trùng l?p
- S? lý?ng s?n ph?m trùng trong m?i nhóm
- Chi ti?t t?ng s?n ph?m trong nhóm trùng

### 2. Xóa T?ng Nhóm Trùng L?p

**Ch?c nãng:**
- Xóa các s?n ph?m trùng trong m?t nhóm c? th?
- Gi? l?i s?n ph?m có MaSP nh? nh?t
- C?ng t?n kho vào s?n ph?m ðý?c gi? l?i

**Cách s? d?ng:**
1. Trong b?ng "S?n Ph?m Trùng L?p", t?m nhóm c?n xóa
2. Click nút "Xem Chi Ti?t" ð? xem danh sách chi ti?t
3. Click nút "Xóa Trùng" ð? xóa nhóm ðó
4. Xác nh?n trong dialog

### 3. Xóa T?t C? S?n Ph?m Trùng

**Ch?c nãng:**
- Xóa t?t c? s?n ph?m trùng l?p trong h? th?ng
- X? l? t? ð?ng cho t?t c? các nhóm trùng

**Cách s? d?ng:**
1. Click nút "Xóa T?t C? S?n Ph?m Trùng" ? ð?u b?ng
2. Ð?c k? c?nh báo
3. Xác nh?n ð? th?c hi?n

---

## ?? Các File Ð? Ch?nh S?a

### 1. Controller
**File:** `WebApplication15\Areas\Admin\Controllers\DashboardController.cs`

**Các method m?i:**

#### `Index()` - Ð? c?p nh?t
```csharp
// Phát hi?n s?n ph?m trùng l?p
var sanPhamTrungLap = sanPhamList
    .GroupBy(sp => new { 
        TenSP = sp.TenSP.Trim().ToLower(), 
        MaTH = sp.MaTH, 
        MaLoai = sp.MaLoai 
    })
    .Where(g => g.Count() > 1)
    .Select(g => new
    {
        TenSP = g.First().TenSP,
        ThuongHieu = g.First().ThuongHieu != null ? g.First().ThuongHieu.TenTH : "N/A",
        LoaiSP = g.First().LoaiSP != null ? g.First().LoaiSP.TenLoai : "N/A",
        SoLuongTrung = g.Count(),
        DanhSachSP = g.OrderBy(sp => sp.MaSP).ToList()
    })
    .ToList();

ViewBag.SanPhamTrungLap = sanPhamTrungLap;
ViewBag.TongSanPhamTrungLap = sanPhamTrungLap.Sum(x => x.SoLuongTrung - 1);
```

#### `XoaSanPhamTrung()` - M?i
```csharp
[HttpPost]
public ActionResult XoaSanPhamTrung(string tenSP, int? maTH, int? maLoai)
```

**Ch?c nãng:**
- Xóa các s?n ph?m trùng trong m?t nhóm
- Gi? l?i s?n ph?m ð?u tiên (MaSP nh? nh?t)
- C?ng t?n kho vào s?n ph?m ðý?c gi? l?i
- Xóa các liên k?t (NhapHang, XuatKho, DanhGia)
- B? qua s?n ph?m ð? có trong ðõn hàng

#### `XoaTatCaSanPhamTrung()` - M?i
```csharp
[HttpPost]
public ActionResult XoaTatCaSanPhamTrung()
```

**Ch?c nãng:**
- Xóa t?t c? s?n ph?m trùng l?p
- X? l? t?ng nhóm trùng m?t
- T?ng h?p k?t qu? và báo l?i

### 2. View
**File:** `WebApplication15\Areas\Admin\Views\Dashboard\Index.cshtml`

**Ph?n UI m?i:**

#### B?ng C?nh Báo S?n Ph?m Trùng L?p
```razor
@if (ViewBag.SanPhamTrungLap != null && ViewBag.SanPhamTrungLap.Count > 0)
{
    <div class="card mt-4 mb-4 border-danger">
        <div class="card-header bg-danger text-white">
            <h5 class="mb-0">?? C?NH BÁO: Phát Hi?n S?n Ph?m Trùng L?p!</h5>
        </div>
        ...
    </div>
}
```

#### JavaScript Functions
```javascript
function xoaSanPhamTrung(tenSP, maTH, maLoai) {
    // Xóa t?ng nhóm trùng
}

function xoaTatCaSanPhamTrung() {
    // Xóa t?t c? s?n ph?m trùng
}
```

---

## ?? Quy Tr?nh X? L?

### Khi Xóa S?n Ph?m Trùng:

1. **Phát hi?n nhóm trùng:**
   - T?m các s?n ph?m có cùng Tên, Thýõng hi?u, Lo?i
   - S?p x?p theo MaSP tãng d?n

2. **Xác ð?nh s?n ph?m gi? l?i:**
   - S?n ph?m có MaSP nh? nh?t ðý?c gi? l?i
   - Badge "S? gi? l?i" hi?n th? màu xanh

3. **X? l? s?n ph?m trùng:**
   - Ki?m tra xem s?n ph?m có trong ðõn hàng không
   - N?u có trong ðõn hàng ? B? qua, báo l?i
   - N?u chýa có:
     * C?ng t?n kho vào s?n ph?m gi? l?i
     * Xóa các b?n ghi liên quan (NhapHang, XuatKho, DanhGia)
     * Xóa s?n ph?m

4. **Lýu và báo cáo:**
   - Lýu thay ð?i vào database
   - Hi?n th? s? lý?ng ð? xóa
   - Li?t kê các l?i (n?u có)

---

## ?? Lýu ? Quan Tr?ng

### 1. S?n Ph?m Trong Ðõn Hàng
- ? KHÔNG th? xóa s?n ph?m ð? có trong ðõn hàng
- ?? H? th?ng s? b? qua và báo l?i
- ? Ch? xóa s?n ph?m chýa ðý?c bán

### 2. T?n Kho
- ? T?n kho ðý?c c?ng vào s?n ph?m gi? l?i
- ?? Ví d?: SP #1 (t?n 10) + SP #2 (t?n 5) ? SP #1 (t?n 15), xóa SP #2

### 3. D? Li?u Liên Quan
- ??? Xóa t? ð?ng: NhapHang, XuatKho, DanhGia
- ?? Không th? ph?c h?i sau khi xóa

### 4. S?n Ph?m Ðý?c Gi? L?i
- ?? Luôn gi? s?n ph?m có MaSP nh? nh?t
- ?? Thý?ng là s?n ph?m ðý?c t?o ð?u tiên

---

## ?? Ví D? Minh H?a

### Trý?c Khi Xóa:
```
S?n Ph?m Trùng L?p: "S?a r?a m?t trà xanh"
?? #5  - T?n: 10 - Giá: 150,000ð - [S? gi? l?i]
?? #12 - T?n: 5  - Giá: 150,000ð - [S? xóa]
?? #18 - T?n: 3  - Giá: 155,000ð - [S? xóa]
```

### Sau Khi Xóa:
```
S?n Ph?m: "S?a r?a m?t trà xanh"
?? #5 - T?n: 18 (10+5+3) - Giá: 150,000ð
```

---

## ?? Ki?m Tra

### 1. Ki?m tra phát hi?n trùng l?p:
```sql
SELECT TenSP, MaTH, MaLoai, COUNT(*) as SoLuong
FROM SanPham
GROUP BY TenSP, MaTH, MaLoai
HAVING COUNT(*) > 1
```

### 2. Ki?m tra s?n ph?m sau khi xóa:
```sql
SELECT MaSP, TenSP, SoLuongTon
FROM SanPham
WHERE TenSP = N'Tên s?n ph?m'
```

### 3. Ki?m tra s?n ph?m có trong ðõn hàng:
```sql
SELECT DISTINCT MaSP
FROM ChiTietDonHangs
WHERE MaSP IN (danh sách m? s?n ph?m trùng)
```

---

## ?? K?t Qu? Mong Ð?i

### Sau khi ch?y ch?c nãng:
- ? Không c?n s?n ph?m trùng l?p (tr? nh?ng s?n ph?m ð? có trong ðõn hàng)
- ? T?n kho ðý?c c?ng ðúng
- ? D? li?u liên quan ðý?c xóa s?ch
- ? Dashboard hi?n th? "Không có s?n ph?m trùng l?p"

---

## ??? X? L? L?i

### L?i thý?ng g?p:

1. **"S?n ph?m ð? có trong ðõn hàng"**
   - ? Không th? xóa
   - ?? Gi?i pháp: Gi? nguyên ho?c x? l? th? công

2. **"L?i khi xóa s?n ph?m"**
   - ? Database constraint
   - ?? Gi?i pháp: Ki?m tra foreign key relationships

3. **"Không t?m th?y s?n ph?m trùng l?p"**
   - ?? Có th? ð? ðý?c xóa
   - ?? Gi?i pháp: Refresh trang

---

## ?? Tài Li?u Liên Quan

- BAO_CAO_TINH_NANG_THONG_KE_DOANH_THU.md
- README.md
- CHANGELOG.md

---

**Ngày t?o:** ${new Date().toLocaleDateString('vi-VN')}  
**Ngý?i th?c hi?n:** GitHub Copilot  
**Phiên b?n:** 1.0
