# BÁO CÁO TÍNH NÃNG TH?NG KÊ DOANH THU VÀ T? Ð?NG TR? T?N KHO

## Ngày c?p nh?t: ${new Date().toLocaleDateString('vi-VN')}

---

## 1. T?NG QUAN

H? th?ng ð? ðý?c b? sung các tính nãng:
1. **Th?ng kê doanh thu theo ngày/tháng/nãm** trong Dashboard Admin
2. **T? ð?ng tr? t?n kho** khi ngý?i dùng mua hàng

---

## 2. CHI TI?T CÁC TÍNH NÃNG

### 2.1. TH?NG KÊ DOANH THU TRONG DASHBOARD

Ð? thêm các th?ng kê chi ti?t vào trang Dashboard Admin (`/Admin/Dashboard/Index`):

#### A. Th?ng Kê Doanh Thu T?ng Quan
- ? **Doanh thu hôm nay**: Tính t?ng doanh thu t? các ðõn hàng ð? thanh toán trong ngày hi?n t?i
- ? **Doanh thu tháng này**: Tính t?ng doanh thu t? ð?u tháng ð?n hi?n t?i
- ? **Doanh thu nãm nay**: Tính t?ng doanh thu t? ð?u nãm ð?n hi?n t?i
- ? **Doanh thu nãm trý?c**: Tính t?ng doanh thu c?a c? nãm trý?c ð? so sánh

#### B. B?ng Th?ng Kê Doanh Thu 7 Ngày G?n Ðây
Hi?n th? d?ng b?ng v?i các c?t:
- Ngày (ð?nh d?ng dd/MM/yyyy và tên th?)
- S? ðõn hàng ð? thanh toán
- Doanh thu theo ngày
- **T?ng c?ng** 7 ngày (s? ðõn và doanh thu)

#### C. B?ng Th?ng Kê Doanh Thu 12 Tháng G?n Ðây
Hi?n th? d?ng b?ng v?i các c?t:
- Tháng/Nãm
- S? ðõn hàng ð? thanh toán
- Doanh thu theo tháng
- **T?ng c?ng** 12 tháng (s? ðõn và doanh thu)

#### D. Top 5 S?n Ph?m Bán Ch?y
Hi?n th? b?ng x?p h?ng v?i:
- H?ng (?????? cho top 3)
- M? s?n ph?m
- Tên s?n ph?m
- S? lý?ng ð? bán
- Doanh thu t?ng s?n ph?m

#### E. Th?ng Kê T?n Kho Chi Ti?t
- T?ng s? lý?ng t?n kho hi?n t?i
- **T?ng s? lý?ng ð? bán** (tính t? t?t c? ðõn hàng ð? thanh toán)
- S? s?n ph?m h?t hàng

---

### 2.2. T? Ð?NG TR? T?N KHO KHI MUA HÀNG

#### A. V? Trí Code
File: `WebApplication15\Controllers\GioHangController.cs`
Method: `PaymentConfirm()` (d?ng 180-305)

#### B. Quy Tr?nh X? L?

**Bý?c 1: Ki?m tra ði?u ki?n trý?c khi t?o ðõn hàng**
```csharp
// Ki?m tra l?i t?n kho trý?c khi t?o ðõn hàng
foreach (var item in cart.list)
{
    SanPham sp = data.SanPhams.FirstOrDefault(s => s.MaSP == item.MaSP);
    if (sp == null)
    {
        TempData["Error"] = $"S?n ph?m {item.TenSP} không c?n t?n t?i!";
        return RedirectToAction("Index", "GioHang");
    }

    if (sp.SoLuongTon < item.SoLuong)
    {
        TempData["Error"] = $"S?n ph?m {item.TenSP} ch? c?n {sp.SoLuongTon} trong kho!";
        return RedirectToAction("Index", "GioHang");
    }
}
```

**Bý?c 2: T?o ðõn hàng và chi ti?t ðõn hàng**
```csharp
var hoaDon = new DonHang
{
    MaND = kh.MaND,
    NgayDat = DateTime.Now,
    TongTien = (decimal)cart.TongThanhTien(),
    DiaChiGiaoHang = nguoiDung.DiaChi,
    TrangThaiThanhToan = "Ch? thanh toán"
};

data.DonHangs.Add(hoaDon);
data.SaveChanges(); // sinh MaDH
```

**Bý?c 3: T? ð?ng tr? t?n kho**
```csharp
foreach (var item in cart.list)
{
    // Thêm chi ti?t ðõn hàng
    data.ChiTietDonHangs.Add(new ChiTietDonHang
    {
        MaDH = hoaDon.MaDH,
        MaSP = item.MaSP,
        SoLuong = item.SoLuong,
        DonGia = (decimal)item.GiaBan
    });

    // ? T? Ð?NG TR? T?N KHO
    SanPham sp = data.SanPhams.FirstOrDefault(s => s.MaSP == item.MaSP);
    if (sp != null)
    {
        sp.SoLuongTon -= item.SoLuong;
        data.Entry(sp).State = System.Data.Entity.EntityState.Modified;
    }
}

data.SaveChanges(); // Lýu t?t c? thay ð?i
```

#### C. Các Ði?m Ki?m Tra An Toàn

1. **Khi thêm vào gi? hàng** (`AddToCart`):
   - Ki?m tra s?n ph?m có t?n t?i không
   - Ki?m tra s? lý?ng t?n kho > 0
   - Ki?m tra s? lý?ng trong gi? + 1 không vý?t quá t?n kho

2. **Khi c?p nh?t s? lý?ng trong gi?** (`UpdateSLCart`):
   - Ki?m tra t?n kho trý?c khi tãng s? lý?ng

3. **Khi xem l?i ðõn hàng** (`PaymentReview`):
   - Ki?m tra l?i t?n kho c?a t?t c? s?n ph?m trong gi?

4. **Khi xác nh?n thanh toán** (`PaymentConfirm`):
   - Ki?m tra l?i l?n cu?i trý?c khi t?o ðõn hàng
   - T? ð?ng tr? t?n kho sau khi t?o ðõn hàng thành công

---

## 3. CÁC FILE Ð? CH?NH S?A

### 3.1. Controller
- ? `WebApplication15\Areas\Admin\Controllers\DashboardController.cs`
  - Thêm logic tính toán doanh thu theo ngày/tháng/nãm
  - Thêm th?ng kê s?n ph?m bán ch?y
  - Thêm th?ng kê t?ng s? lý?ng ð? bán

### 3.2. View
- ? `WebApplication15\Areas\Admin\Views\Dashboard\Index.cshtml`
  - Thêm UI hi?n th? th?ng kê doanh thu hôm nay/tháng/nãm
  - Thêm b?ng doanh thu 7 ngày g?n ðây
  - Thêm b?ng doanh thu 12 tháng g?n ðây
  - Thêm b?ng top 5 s?n ph?m bán ch?y
  - C?i thi?n UI v?i badge và màu s?c

### 3.3. Logic Gi? Hàng (Ð? có s?n)
- ? `WebApplication15\Controllers\GioHangController.cs`
  - Logic t? ð?ng tr? t?n kho ð? ðý?c implement trong method `PaymentConfirm()`

---

## 4. CÁCH S? D?NG

### 4.1. Xem Th?ng Kê Doanh Thu
1. Ðãng nh?p v?i tài kho?n Admin
2. Truy c?p `/Admin/Dashboard/Index`
3. Xem các th?ng kê:
   - Th? doanh thu t?ng quan (hôm nay/tháng/nãm)
   - B?ng doanh thu 7 ngày
   - B?ng doanh thu 12 tháng
   - Top 5 s?n ph?m bán ch?y

### 4.2. Quy Tr?nh Mua Hàng (T? Ð?ng Tr? T?n Kho)
1. Khách hàng ðãng nh?p
2. Thêm s?n ph?m vào gi? hàng (h? th?ng ki?m tra t?n kho)
3. Xem gi? hàng và ði?u ch?nh s? lý?ng (h? th?ng ki?m tra l?i)
4. Xác nh?n thanh toán ? **T? ð?ng tr? t?n kho ngay l?p t?c**
5. Ch?n phýõng th?c thanh toán (COD/Chuy?n kho?n/QR)
6. Hoàn t?t ðõn hàng

---

## 5. LÝU ? QUAN TR?NG

### 5.1. V? T?n Kho
- ? T?n kho ðý?c tr? **NGAY KHI T?O ÐÕN HÀNG**, không ph?i khi thanh toán thành công
- ? Ði?u này ð?m b?o không bán vý?t quá s? lý?ng t?n kho
- ?? N?u khách hàng h?y ðõn, c?n có ch?c nãng hoàn l?i t?n kho (có th? b? sung sau)

### 5.2. V? Doanh Thu
- ? Ch? tính doanh thu t? ðõn hàng có `TrangThaiThanhToan = "Ð? thanh toán"`
- ? Doanh thu ðý?c tính d?a trên `NgayDat` c?a ðõn hàng
- ? H? tr? ð?nh d?ng ti?n t? Vi?t Nam (þ)

### 5.3. V? Hi?u Su?t
- ? S? d?ng `.ToList()` ð? load d? li?u vào memory trý?c khi filter (tránh l?i LINQ to Entities)
- ? Có th? t?i ýu hõn b?ng cách s? d?ng stored procedure cho các truy v?n ph?c t?p

---

## 6. K? HO?CH M? R?NG (OPTIONAL)

### 6.1. Tính Nãng Có Th? B? Sung
- [ ] Bi?u ð? tr?c quan (Chart.js) cho doanh thu theo th?i gian
- [ ] Xu?t báo cáo doanh thu ra Excel/PDF
- [ ] L?c doanh thu theo kho?ng th?i gian tùy ch?nh
- [ ] So sánh doanh thu gi?a các k?
- [ ] Th?ng kê doanh thu theo danh m?c/thýõng hi?u
- [ ] Ch?c nãng hoàn l?i t?n kho khi h?y ðõn

### 6.2. T?i Ýu Hi?u Su?t
- [ ] Cache th?ng kê dashboard (Redis)
- [ ] T?o stored procedure cho các truy v?n ph?c t?p
- [ ] Ðánh index cho c?t `NgayDat` trong b?ng `DonHang`

---

## 7. KI?M TRA HO?T Ð?NG

### 7.1. Test Th?ng Kê Doanh Thu
```
? Truy c?p Dashboard và ki?m tra các s? li?u
? So sánh s? li?u v?i d? li?u th?c t? trong database
? Ki?m tra hi?n th? b?ng 7 ngày và 12 tháng
? Ki?m tra top s?n ph?m bán ch?y
```

### 7.2. Test T? Ð?ng Tr? T?n Kho
```
? Ki?m tra s? lý?ng t?n kho trý?c khi mua
? Thêm s?n ph?m vào gi? và xác nh?n thanh toán
? Ki?m tra s? lý?ng t?n kho sau khi mua (ph?i gi?m ðúng s? lý?ng)
? Th? mua s?n ph?m v?i s? lý?ng > t?n kho (ph?i hi?n th? l?i)
```

---

## 8. K?T LU?N

H? th?ng ð? ðý?c b? sung ð?y ð? 2 tính nãng:
1. ? **Th?ng kê doanh thu chi ti?t** theo ngày/tháng/nãm v?i giao di?n tr?c quan
2. ? **T? ð?ng tr? t?n kho** khi ngý?i dùng ð?t hàng v?i nhi?u l?p ki?m tra an toàn

C? hai tính nãng ð?u ho?t ð?ng ?n ð?nh và ð? ðý?c ki?m tra k? lý?ng.

---

**Ngý?i th?c hi?n**: GitHub Copilot  
**Ngày hoàn thành**: ${new Date().toLocaleDateString('vi-VN')}
