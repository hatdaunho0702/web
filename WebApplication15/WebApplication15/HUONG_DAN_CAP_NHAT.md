# ?? HÝ?NG D?N C?P NH?T DATABASE VÀ CODE

## ?? M?C TIÊU
C?p nh?t ?ng d?ng WebApplication15 ð? týõng thích v?i schema database m?i t? SQL script.

---

## ?? BÝ?C 1: C?P NH?T DATABASE

### Option A: T?o Database m?i t? ð?u (Khuy?n ngh? n?u chýa có d? li?u quan tr?ng)

1. M? **SQL Server Management Studio (SSMS)**
2. Ch?y toàn b? file SQL b?n ð? cung c?p ð? t?o `DB_SkinFood`
3. Database s? ðý?c t?o v?i tên `DB_SkinFood` (không có s? 1)

### Option B: C?p nh?t Database hi?n t?i (DB_SkinFood1)

1. M? **SQL Server Management Studio (SSMS)**
2. Ch?y file **`Update_DB_SkinFood1.sql`** mà tôi v?a t?o
3. Script này s?:
   - ? Thêm các c?t m?i vào b?ng `DonHang`: `TrangThaiThanhToan`, `NgayThanhToan`, `PhuongThucThanhToan`
   - ? Ð?i tên b?ng `ChiTietDonHang` ? `ChiTietDonHangs` (n?u c?n)
   - ? T?o b?ng `LienHe` (n?u chýa có)
   - ? C?p nh?t stored procedures
   - ? Thêm constraints và d? li?u m?u

---

## ?? BÝ?C 2: C?P NH?T WEB.CONFIG

Ki?m tra connection string trong file `Web.config`:

```xml
<connectionStrings>
  <add name="DB_SkinFood1Entities" 
       connectionString="metadata=res://*/Models.DB_SkinFood.csdl|res://*/Models.DB_SkinFood.ssdl|res://*/Models.DB_SkinFood.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=MSI;initial catalog=DB_SkinFood1;integrated security=True;trustservercertificate=True;MultipleActiveResultSets=True;App=EntityFramework&quot;" 
       providerName="System.Data.EntityClient" />
</connectionStrings>
```

**Lýu ?:**
- `data source=MSI` ? Ð?i thành tên SQL Server c?a b?n n?u khác
- `initial catalog=DB_SkinFood1` ? Tên database (gi? nguyên n?u dùng DB_SkinFood1)

---

## ?? BÝ?C 3: C?P NH?T ENTITY FRAMEWORK MODEL (QUAN TR?NG!)

### Cách 1: Update Model from Database (Khuy?n ngh?)

1. Trong **Visual Studio**, m? Solution Explorer
2. M? thý m?c `Models`
3. Double-click vào file **`DB_SkinFood.edmx`**
4. Trong **Model Browser**, right-click vào design surface ? **Update Model from Database...**
5. Trong tab **Refresh**:
   - ? Check t?t c? các b?ng ð? thay ð?i
   - ? Ð?c bi?t chú ?: `DonHang`, `ChiTietDonHangs`, `LienHe`
6. Click **Finish**
7. **Save All** (Ctrl + Shift + S)

### Cách 2: Xóa và t?o l?i Model (N?u cách 1 không ho?t ð?ng)

1. **Backup code** c?a các file trong thý m?c `Models` trý?c
2. Delete file `DB_SkinFood.edmx`
3. Right-click vào thý m?c `Models` ? **Add** ? **New Item**
4. Ch?n **ADO.NET Entity Data Model**
5. Ð?t tên: `DB_SkinFood`
6. Ch?n **EF Designer from database**
7. Ch?n connection string `DB_SkinFood1Entities`
8. Ch?n t?t c? các b?ng
9. **Finish**

---

## ? BÝ?C 4: KI?M TRA CODE Ð? C?P NH?T

Tôi ð? c?p nh?t các file sau cho b?n:

### 1. **Models/DB_SkinFood.Context.cs**
```csharp
// Ð? thêm mapping cho ChiTietDonHangs table
modelBuilder.Entity<ChiTietDonHang>().ToTable("ChiTietDonHangs");
```

### 2. **Models/LienHe.cs** (File m?i)
```csharp
// Entity cho b?ng LienHe ð? ðý?c t?o
```

### 3. T?t c? Controllers ð? s? d?ng ðúng:
- ? `DB_SkinFood1Entities` (tên DbContext ðúng)
- ? `ChiTietDonHangs` (tên DbSet ðúng)
- ? `TrangThaiThanhToan`, `NgayThanhToan`, `PhuongThucThanhToan` (các trý?ng m?i)

---

## ?? BÝ?C 5: TEST ?NG D?NG

### 5.1. Build Solution
```
Ctrl + Shift + B
```
Ð?m b?o không có l?i compile.

### 5.2. Ki?m tra các ch?c nãng:

#### ? Login/Register
- Ðãng nh?p v?i: `admin@skinfood.vn` / `admin123`
- Ðãng k? tài kho?n m?i

#### ? Qu?n l? s?n ph?m
- Xem danh sách s?n ph?m
- Thêm/S?a/Xóa s?n ph?m

#### ? Gi? hàng và thanh toán
- Thêm s?n ph?m vào gi?
- Xem gi? hàng
- Thanh toán v?i các phýõng th?c: COD, Chuy?n kho?n, QR
- **Ki?m tra tr?ng thái thanh toán** ðý?c lýu ðúng

#### ? Qu?n l? ðõn hàng (Admin)
- Xem danh sách ðõn hàng
- Xem chi ti?t ðõn hàng
- C?p nh?t tr?ng thái thanh toán

#### ? Dashboard (Admin)
- Th?ng kê doanh thu
- Ðõn hàng ð? thanh toán / chýa thanh toán
- S?n ph?m s?p h?t h?n

#### ? Liên h?
- G?i form liên h?
- Admin xem và qu?n l? liên h?

---

## ?? X? L? L?I THÝ?NG G?P

### L?i 1: "Invalid object name 'ChiTietDonHang'"
**Nguyên nhân:** B?ng ð? ð?i tên thành `ChiTietDonHangs`
**Gi?i pháp:** 
1. Ch?y script `Update_DB_SkinFood1.sql`
2. Update Model from Database trong Visual Studio

### L?i 2: "Invalid column name 'TrangThaiThanhToan'"
**Nguyên nhân:** C?t m?i chýa ðý?c thêm vào database
**Gi?i pháp:** Ch?y script `Update_DB_SkinFood1.sql`

### L?i 3: "Cannot open database 'DB_SkinFood1'"
**Nguyên nhân:** Database không t?n t?i ho?c connection string sai
**Gi?i pháp:**
1. Ki?m tra database có t?n t?i trong SSMS
2. Ki?m tra connection string trong Web.config
3. Ki?m tra SQL Server service ðang ch?y

### L?i 4: Build error v?i Entity Framework
**Gi?i pháp:**
1. Clean Solution (Ctrl + Shift + B, sau ðó Build ? Clean Solution)
2. Rebuild Solution
3. N?u v?n l?i, xóa thý m?c `bin` và `obj`, sau ðó rebuild

---

## ?? KI?M TRA DATABASE SAU KHI C?P NH?T

Ch?y các query sau trong SSMS ð? ki?m tra:

```sql
USE DB_SkinFood1;

-- 1. Ki?m tra c?u trúc b?ng DonHang
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DonHang';

-- 2. Ki?m tra b?ng ChiTietDonHangs
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'ChiTietDonHangs';

-- 3. Ki?m tra b?ng LienHe
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'LienHe';

-- 4. Ki?m tra stored procedures
SELECT name FROM sys.procedures 
WHERE name LIKE 'sp_%';

-- 5. Test d? li?u ðõn hàng
SELECT TOP 5 MaDH, MaND, TongTien, TrangThaiThanhToan, 
       NgayThanhToan, PhuongThucThanhToan
FROM DonHang
ORDER BY NgayDat DESC;
```

---

## ?? HOÀN T?T

Sau khi hoàn thành các bý?c trên, ?ng d?ng c?a b?n s?:
- ? K?t n?i ðúng v?i database
- ? Có ð?y ð? các ch?c nãng thanh toán
- ? Tracking ðý?c tr?ng thái ðõn hàng
- ? Có form liên h? ho?t ð?ng
- ? Dashboard hi?n th? ðúng th?ng kê

---

## ?? LÝU ? QUAN TR?NG

1. **Backup database trý?c khi c?p nh?t**: 
   ```sql
   BACKUP DATABASE DB_SkinFood1 
   TO DISK = 'D:\Backup\DB_SkinFood1_Backup.bak';
   ```

2. **Không ch?nh s?a các file auto-generated** trong thý m?c Models (các file có comment `<auto-generated>`)

3. **Luôn Update Model from Database** sau khi thay ð?i schema

4. **Test k? trý?c khi deploy** lên môi trý?ng production

---

## ?? TÀI LI?U THAM KH?O

- Entity Framework Database First: https://docs.microsoft.com/en-us/ef/ef6/
- ASP.NET MVC: https://docs.microsoft.com/en-us/aspnet/mvc/
- SQL Server Stored Procedures: https://docs.microsoft.com/en-us/sql/

---

**Chúc b?n thành công! ??**
