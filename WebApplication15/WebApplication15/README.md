# ?? SKINFOOD - H? TH?NG QU?N L? BÁN M? PH?M

## ?? Mô t? d? án

Website bán m? ph?m v?i ð?y ð? tính nãng:
- **Frontend**: Trang ch?, danh m?c s?n ph?m, gi? hàng, thanh toán, chatbot AI
- **Admin Panel**: Qu?n l? s?n ph?m, ðõn hàng, nh?p/xu?t kho, ðánh giá, tài kho?n
- **Database**: SQL Server v?i Stored Procedures, Functions, Triggers

---

## ??? Công ngh? s? d?ng

- **Backend**: ASP.NET MVC 5, C# 7.3, .NET Framework 4.7.2
- **Database**: SQL Server 2019+, Entity Framework 6.x
- **Frontend**: Razor, Bootstrap 5, jQuery, Font Awesome
- **API**: OpenAI GPT (Chatbot)

---

## ?? Yêu c?u h? th?ng

- Visual Studio 2019/2022
- SQL Server 2019+
- .NET Framework 4.7.2 SDK
- IIS Express (ði kèm VS)

---

## ?? Hý?ng d?n cài ð?t

### Bý?c 1: Clone project
```bash
git clone https://github.com/hatdaunho0702/web
cd web/WebApplication15/WebApplication15
```

### Bý?c 2: Restore database
1. M? SQL Server Management Studio (SSMS)
2. Ch?y file SQL: `QL_MyPham (1).sql`
3. Ð?m b?o database `DB_SkinFood` ðý?c t?o thành công

### Bý?c 3: C?u h?nh connection string
M? file `Web.config`, t?m và c?p nh?t connection string:

```xml
<connectionStrings>
    <add name="DB_SkinFoodEntities" 
         connectionString="metadata=res://*/Models.DB_SkinFood.csdl|res://*/Models.DB_SkinFood.ssdl|res://*/Models.DB_SkinFood.msl;
         provider=System.Data.SqlClient;
         provider connection string=&quot;
         data source=YOUR_SERVER_NAME;
         initial catalog=DB_SkinFood;
         integrated security=True;
         MultipleActiveResultSets=True;
         App=EntityFramework&quot;" 
         providerName="System.Data.EntityClient" />
</connectionStrings>
```

**Thay `YOUR_SERVER_NAME` b?ng tên SQL Server c?a b?n** (vd: `localhost`, `.\\SQLEXPRESS`, etc.)

### Bý?c 4: Restore NuGet packages
Trong Visual Studio:
1. Nh?n chu?t ph?i vào Solution
2. Ch?n **"Restore NuGet Packages"**
3. Ch? hoàn t?t

### Bý?c 5: Build project
```
Ctrl + Shift + B
```
ho?c:
```
Build ? Build Solution
```

### Bý?c 6: Ch?y project
```
F5 (Run with debugging)
```
ho?c:
```
Ctrl + F5 (Run without debugging)
```

---

## ?? Tài kho?n m?c ð?nh

### Admin
```
Email: admin@skinfood.vn
Password: admin123
```

### User (Khách hàng)
```
Email: an@gmail.com
Password: 123456
```

Ho?c ðãng k? tài kho?n m?i t?i: `/User/Register`

---

## ?? C?u trúc d? án

```
WebApplication15/
??? Areas/Admin/          # Admin panel
?   ??? Controllers/      # Admin controllers
?   ??? Views/            # Admin views
??? Controllers/          # User controllers
??? Models/               # Entity models & ViewModels
??? Views/                # User views
?   ??? Home/
?   ??? User/
?   ??? GioHang/
?   ??? Shared/
??? Content/              # CSS, Images
??? Scripts/              # JavaScript
??? App_Start/            # Configuration
??? Web.config            # Settings
```

---

## ?? Tính nãng chính

### ?? Ngý?i dùng
- ? Xem danh sách s?n ph?m (l?c theo danh m?c, lo?i, thýõng hi?u)
- ? Chi ti?t s?n ph?m + ðánh giá
- ? Gi? hàng (thêm, xóa, c?p nh?t)
- ? Ð?t hàng online
- ? Qu?n l? ðõn hàng cá nhân
- ? C?p nh?t profile
- ? Chatbot AI h? tr?

### ?? Admin
- ? Dashboard th?ng kê
- ? Qu?n l? s?n ph?m (CRUD)
- ? Qu?n l? ðõn hàng
- ? Nh?p hàng (t? ð?ng c?p nh?t t?n kho)
- ? Xu?t kho (gi?m t?n kho)
- ? Duy?t ðánh giá
- ? Qu?n l? tài kho?n
- ? Qu?n l? danh m?c/lo?i/thýõng hi?u

---

## ?? Database Schema

### Tables (13)
- `NguoiDung` - Ngý?i dùng
- `TaiKhoan` - Ðãng nh?p
- `DanhMuc` - Danh m?c
- `LoaiSP` - Lo?i s?n ph?m
- `ThuongHieu` - Thýõng hi?u
- `SanPham` - S?n ph?m
- `DonHang` - Ðõn hàng
- `ChiTietDonHangs` - Chi ti?t ðõn
- `DanhGia` - Ðánh giá
- `ThuocTinhMyPham` - Thu?c tính
- `NhapHang` - Phi?u nh?p
- `XuatKho` - Phi?u xu?t
- `sysdiagrams` - Diagrams

### Stored Procedures (20+)
- Login/Register/ChangePassword
- CRUD S?n ph?m
- CRUD Ðõn hàng
- C?p nh?t t?n kho
- Thanh toán
- Duy?t ðánh giá

### Functions (3)
- Tính t?ng ti?n ðõn hàng
- T?ng ti?n theo khách hàng
- Ði?m trung b?nh s?n ph?m

### Triggers (4)
- Auto gi?m t?n kho khi bán
- Auto tãng t?n kho khi h?y
- Ch?n xóa s?n ph?m ð? bán
- Auto c?p nh?t ði?m tin c?y

---

## ?? Routes

### User Routes
```
/                            - Trang ch?
/Home/DanhMucSP/{id}         - S?n ph?m theo danh m?c
/Home/ChiTietSP/{id}         - Chi ti?t s?n ph?m
/User/Login                  - Ðãng nh?p
/User/Register               - Ðãng k?
/User/Profile                - Profile
/GioHang/Index               - Gi? hàng
/GioHang/ThanhToan           - Thanh toán
/Chat/ChatAI                 - Chatbot
```

### Admin Routes
```
/Admin/Dashboard             - Dashboard
/Admin/SanPham               - Qu?n l? SP
/Admin/DonHang               - Qu?n l? ÐH
/Admin/NhapHang              - Nh?p hàng
/Admin/XuatKho               - Xu?t kho
/Admin/DanhGias              - Ðánh giá
/Admin/TaiKhoan              - Tài kho?n
```

---

## ?? Troubleshooting

### L?i: "Cannot connect to database"
**Gi?i pháp:**
1. Ki?m tra SQL Server ðang ch?y
2. C?p nh?t connection string trong `Web.config`
3. Ki?m tra tên database: `DB_SkinFood`

### L?i: "Login failed for user"
**Gi?i pháp:**
1. S? d?ng **Windows Authentication** (m?c ð?nh)
2. Ho?c ð?i sang SQL Server Authentication trong connection string:
```xml
User ID=sa;Password=your_password;
```

### L?i: "The type or namespace could not be found"
**Gi?i pháp:**
1. Restore NuGet packages
2. Clean solution: `Build ? Clean Solution`
3. Rebuild: `Build ? Rebuild Solution`

### L?i: "Entity Framework provider not found"
**Gi?i pháp:**
```bash
Install-Package EntityFramework -Version 6.4.4
```

---

## ?? Liên h? & H? tr?

- **Email**: hatdaunho0702@gmail.com
- **GitHub**: https://github.com/hatdaunho0702
- **Facebook**: [Link n?u có]

---

## ?? License

MIT License - Free to use for educational purposes

---

## ????? Tác gi?

- **Developer**: [Tên c?a b?n]
- **University**: [Tên trý?ng]
- **Year**: 2025

---

## ?? Ghi chú

D? án này ðý?c phát tri?n cho môn h?c **H? Qu?n Tr? Cõ S? D? Li?u**.

**Các tài li?u tham kh?o:**
- `BAO_CAO_KIEM_TRA_TOAN_BO_HE_THONG.md` - Báo cáo chi ti?t
- `CAC_TINH_NANG_DA_BO_SUNG.md` - Changelog
- `QL_MyPham (1).sql` - Database script

---

## ?? Next Steps

Sau khi cài ð?t thành công:

1. ? Test ðãng nh?p Admin
2. ? Test t?o s?n ph?m
3. ? Test ð?t hàng t? user
4. ? Test nh?p/xu?t kho
5. ? Ki?m tra responsive design
6. ? Test chatbot AI (c?n API key)

---

**?? Chúc b?n s? d?ng thành công!**

N?u g?p v?n ð?, vui l?ng t?o issue trên GitHub ho?c liên h? qua email.

---

?? **Last Updated:** ${new Date().toLocaleDateString('vi-VN')}
