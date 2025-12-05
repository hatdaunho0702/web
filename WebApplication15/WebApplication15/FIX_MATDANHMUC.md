# ?? KH?C PH?C M?T DANH M?C S?N PH?M

## ?? V?n ð?
B?ng **DanhMuc** (Danh m?c s?n ph?m) b? m?t ho?c không có d? li?u.

---

## ?? GI?I PHÁP NHANH (3 BÝ?C)

### ? BÝ?C 1: Ki?m tra t?nh tr?ng Database

1. M? **SQL Server Management Studio (SSMS)**
2. K?t n?i ð?n SQL Server c?a b?n
3. Ch?y file: **`Check_Database_Status.sql`**

```sql
-- Ho?c ch?y l?nh sau ð? ki?m tra nhanh:
USE DB_SkinFood1;
SELECT * FROM DanhMuc;
```

**K?t qu? mong ð?i:**
- N?u th?y **6 danh m?c** (MaDM t? 1-6) ? OK, không c?n làm g?
- N?u th?y **l?i "Invalid object name 'DanhMuc'"** ? B?ng b? xóa, c?n khôi ph?c
- N?u b?ng tr?ng (0 rows) ? C?n khôi ph?c d? li?u

---

### ? BÝ?C 2: Khôi ph?c Danh m?c

Ch?y file: **`Restore_DanhMuc.sql`**

File này s?:
- ? T?o l?i b?ng `DanhMuc` n?u b? xóa
- ? Khôi ph?c 6 danh m?c s?n ph?m
- ? T?o l?i Foreign Keys
- ? Gán danh m?c m?c ð?nh cho s?n ph?m b? m?t

**Danh sách 6 danh m?c:**
1. M? ph?m chãm sóc da m?t
2. M? ph?m trang ði?m
3. M? ph?m tóc
4. Dý?c ph?m
5. M? ph?m chãm sóc cõ th?
6. Ný?c hoa và ph? ki?n

---

### ? BÝ?C 3: C?p nh?t Entity Framework Model

1. M? **Visual Studio**
2. M? Solution `WebApplication15`
3. M? file `Models/DB_SkinFood.edmx`
4. **Right-click** trên design surface
5. Ch?n **"Update Model from Database..."**
6. Trong tab **Refresh**:
   - ? Check: **DanhMuc**
   - ? Check: **LoaiSP**
   - ? Check: **SanPham**
7. Click **Finish**
8. **Save All** (Ctrl + Shift + S)
9. **Rebuild Solution** (Ctrl + Shift + B)

---

## ?? KI?M TRA SAU KHI KHÔI PH?C

### Trong SQL Server:
```sql
USE DB_SkinFood1;

-- 1. Xem danh sách danh m?c
SELECT * FROM DanhMuc;

-- 2. Th?ng kê s?n ph?m theo danh m?c
SELECT 
    dm.TenDM,
    COUNT(sp.MaSP) AS SoLuongSanPham
FROM DanhMuc dm
LEFT JOIN SanPham sp ON dm.MaDM = sp.MaDM
GROUP BY dm.TenDM
ORDER BY dm.MaDM;

-- 3. Ki?m tra s?n ph?m không có danh m?c
SELECT * FROM SanPham 
WHERE MaDM IS NULL 
   OR MaDM NOT IN (SELECT MaDM FROM DanhMuc);
-- K?t qu? ph?i là: 0 rows
```

### Trong Web Application:

1. Ch?y ?ng d?ng (F5)
2. Ki?m tra các trang:
   - ? Trang ch? hi?n th? s?n ph?m
   - ? Menu danh m?c xu?t hi?n
   - ? Click vào t?ng danh m?c ? Hi?n th? s?n ph?m
   - ? Admin ? Qu?n l? s?n ph?m ? Dropdown danh m?c có ð?y ð?

---

## ?? NGUYÊN NHÂN GÂY M?T DANH M?C

### Có th? do:
1. **Ch?y DROP TABLE DanhMuc** (vô t?nh ho?c trong script test)
2. **TRUNCATE TABLE DanhMuc** (xóa h?t d? li?u)
3. **DELETE FROM DanhMuc** (xóa d? li?u)
4. **Restore database t? backup c?** (không có d? li?u m?i)
5. **Ch?y script SQL không ðúng th? t?**

---

## ??? PH?NG TRÁNH SAU NÀY

### 1. Backup thý?ng xuyên
```sql
-- Backup database trý?c khi thay ð?i
BACKUP DATABASE DB_SkinFood1 
TO DISK = 'D:\Backup\DB_SkinFood1_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak'
WITH INIT, FORMAT;
```

### 2. Không xóa d? li?u tham chi?u
- **KHÔNG BAO GI?** xóa b?ng `DanhMuc`, `LoaiSP`, `ThuongHieu`
- Các b?ng này là **d? li?u tham chi?u** (reference data)

### 3. S? d?ng Transaction khi test
```sql
BEGIN TRANSACTION;
-- Test code ? ðây
ROLLBACK; -- N?u không OK
-- COMMIT; -- N?u OK
```

### 4. Enable Foreign Key Constraints
Ð?m b?o Foreign Keys luôn ðý?c b?t ð? tránh xóa nh?m:
```sql
-- B?t l?i Foreign Keys n?u b? t?t
ALTER TABLE SanPham CHECK CONSTRAINT FK_SanPham_DanhMuc;
ALTER TABLE LoaiSP CHECK CONSTRAINT FK_LoaiSP_DanhMuc;
```

---

## ?? N?U V?N G?P V?N Ð?

### Ki?m tra logs:
```sql
-- Xem l?ch s? thay ð?i schema (n?u có enabled)
SELECT * FROM sys.fn_dblog(NULL, NULL);
```

### Restore t? backup:
```sql
USE master;
GO

RESTORE DATABASE DB_SkinFood1 
FROM DISK = 'D:\Backup\DB_SkinFood1_20250101.bak'
WITH REPLACE, RECOVERY;
GO
```

---

## ?? CHECKLIST HOÀN THÀNH

Sau khi làm xong, ki?m tra:

- [ ] Ch?y `Check_Database_Status.sql` ? Không có l?i
- [ ] Ch?y `Restore_DanhMuc.sql` ? Thành công
- [ ] Update Model from Database trong Visual Studio
- [ ] Rebuild Solution thành công
- [ ] Ch?y web ? Hi?n th? menu danh m?c
- [ ] Click vào danh m?c ? Hi?n th? s?n ph?m
- [ ] Admin ? Thêm/s?a s?n ph?m ? Dropdown danh m?c OK

---

## ?? K?T QU?

Sau khi hoàn thành các bý?c trên:
- ? B?ng DanhMuc ð? ðý?c khôi ph?c
- ? 6 danh m?c s?n ph?m ð? có d? li?u
- ? T?t c? s?n ph?m ð? ðý?c gán ðúng danh m?c
- ? Website ho?t ð?ng b?nh thý?ng
- ? Menu danh m?c hi?n th? ð?y ð?

---

**Chúc b?n khôi ph?c thành công! ??**

N?u c?n h? tr? thêm, h?y ch?y `Check_Database_Status.sql` và cho tôi bi?t k?t qu?.
