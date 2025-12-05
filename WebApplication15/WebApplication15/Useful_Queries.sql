-- ==================================================================================
-- CÁC QUERY H?U ÍCH Ð? KI?M TRA VÀ QU?N L? DATABASE
-- ==================================================================================

USE DB_SkinFood1;
GO

-- ==================================================================================
-- 1. KI?M TRA C?U TRÚC DATABASE
-- ==================================================================================

-- Xem t?t c? các b?ng
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

-- Xem c?u trúc b?ng DonHang
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DonHang'
ORDER BY ORDINAL_POSITION;
GO

-- Xem c?u trúc b?ng ChiTietDonHangs
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChiTietDonHangs'
ORDER BY ORDINAL_POSITION;
GO

-- ==================================================================================
-- 2. TH?NG KÊ D? LI?U
-- ==================================================================================

-- T?ng quan h? th?ng
SELECT 
    (SELECT COUNT(*) FROM NguoiDung) AS TongNguoiDung,
    (SELECT COUNT(*) FROM TaiKhoan) AS TongTaiKhoan,
    (SELECT COUNT(*) FROM SanPham) AS TongSanPham,
    (SELECT COUNT(*) FROM DonHang) AS TongDonHang,
    (SELECT COUNT(*) FROM DanhGia) AS TongDanhGia,
    (SELECT COUNT(*) FROM LienHe) AS TongLienHe;
GO

-- Th?ng kê ðõn hàng theo tr?ng thái
SELECT 
    TrangThaiThanhToan,
    COUNT(*) AS SoLuong,
    SUM(TongTien) AS TongDoanhThu,
    AVG(TongTien) AS GiaTriTrungBinh
FROM DonHang
GROUP BY TrangThaiThanhToan;
GO

-- Top 10 s?n ph?m bán ch?y
SELECT TOP 10
    sp.TenSP,
    SUM(ct.SoLuong) AS SoLuongBan,
    SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
FROM ChiTietDonHangs ct
INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
GROUP BY sp.TenSP
ORDER BY SoLuongBan DESC;
GO

-- Khách hàng mua nhi?u nh?t
SELECT TOP 10
    nd.HoTen,
    nd.SoDienThoai,
    COUNT(dh.MaDH) AS SoDonHang,
    SUM(dh.TongTien) AS TongChiTieu
FROM NguoiDung nd
INNER JOIN DonHang dh ON nd.MaND = dh.MaND
WHERE dh.TrangThaiThanhToan = N'Ð? thanh toán'
GROUP BY nd.HoTen, nd.SoDienThoai
ORDER BY TongChiTieu DESC;
GO

-- ==================================================================================
-- 3. BÁO CÁO DOANH THU
-- ==================================================================================

-- Doanh thu theo tháng
SELECT 
    YEAR(NgayDat) AS Nam,
    MONTH(NgayDat) AS Thang,
    COUNT(*) AS SoDonHang,
    SUM(TongTien) AS DoanhThu
FROM DonHang
WHERE TrangThaiThanhToan = N'Ð? thanh toán'
GROUP BY YEAR(NgayDat), MONTH(NgayDat)
ORDER BY Nam DESC, Thang DESC;
GO

-- Doanh thu hôm nay
SELECT 
    COUNT(*) AS SoDonHang,
    SUM(TongTien) AS DoanhThu
FROM DonHang
WHERE CAST(NgayDat AS DATE) = CAST(GETDATE() AS DATE)
    AND TrangThaiThanhToan = N'Ð? thanh toán';
GO

-- Doanh thu tháng này
SELECT 
    COUNT(*) AS SoDonHang,
    SUM(TongTien) AS DoanhThu
FROM DonHang
WHERE MONTH(NgayDat) = MONTH(GETDATE())
    AND YEAR(NgayDat) = YEAR(GETDATE())
    AND TrangThaiThanhToan = N'Ð? thanh toán';
GO

-- ==================================================================================
-- 4. QU?N L? T?N KHO
-- ==================================================================================

-- S?n ph?m s?p h?t hàng (< 10)
SELECT 
    TenSP,
    SoLuongTon,
    TenLoai = (SELECT TenLoai FROM LoaiSP WHERE MaLoai = sp.MaLoai),
    TenTH = (SELECT TenTH FROM ThuongHieu WHERE MaTH = sp.MaTH)
FROM SanPham sp
WHERE SoLuongTon < 10
ORDER BY SoLuongTon;
GO

-- S?n ph?m s?p h?t h?n (trong 3 tháng)
SELECT 
    TenSP,
    HanSuDung,
    DATEDIFF(DAY, GETDATE(), HanSuDung) AS SoNgayConLai,
    SoLuongTon
FROM SanPham
WHERE HanSuDung IS NOT NULL
    AND HanSuDung > GETDATE()
    AND HanSuDung <= DATEADD(MONTH, 3, GETDATE())
ORDER BY HanSuDung;
GO

-- S?n ph?m ð? h?t h?n
SELECT 
    TenSP,
    HanSuDung,
    DATEDIFF(DAY, HanSuDung, GETDATE()) AS SoNgayQuaHan,
    SoLuongTon
FROM SanPham
WHERE HanSuDung IS NOT NULL
    AND HanSuDung <= GETDATE()
ORDER BY HanSuDung;
GO

-- ==================================================================================
-- 5. QU?N L? ÐÁNH GIÁ
-- ==================================================================================

-- Ðánh giá chýa duy?t
SELECT 
    dg.MaDG,
    sp.TenSP,
    nd.HoTen,
    dg.NoiDung,
    dg.Diem,
    dg.NgayDanhGia
FROM DanhGia dg
INNER JOIN SanPham sp ON dg.MaSP = sp.MaSP
INNER JOIN NguoiDung nd ON dg.MaND = nd.MaND
WHERE dg.DuocApprove = 0
ORDER BY dg.NgayDanhGia DESC;
GO

-- Ði?m ðánh giá trung b?nh c?a các s?n ph?m
SELECT 
    sp.TenSP,
    COUNT(dg.MaDG) AS SoLuotDanhGia,
    AVG(CAST(dg.Diem AS FLOAT)) AS DiemTrungBinh
FROM SanPham sp
LEFT JOIN DanhGia dg ON sp.MaSP = dg.MaSP AND dg.DuocApprove = 1
GROUP BY sp.TenSP
HAVING COUNT(dg.MaDG) > 0
ORDER BY DiemTrungBinh DESC;
GO

-- ==================================================================================
-- 6. X? L? D? LI?U
-- ==================================================================================

-- C?p nh?t t?t c? ðõn hàng c? chýa có tr?ng thái
UPDATE DonHang 
SET TrangThaiThanhToan = N'Ð? thanh toán',
    NgayThanhToan = NgayDat
WHERE TrangThaiThanhToan IS NULL OR TrangThaiThanhToan = '';
GO

-- Xóa các liên h? c? hõn 1 nãm
-- DELETE FROM LienHe 
-- WHERE NgayGui < DATEADD(YEAR, -1, GETDATE());

-- ==================================================================================
-- 7. BACKUP VÀ B?O TR?
-- ==================================================================================

-- Backup database
-- BACKUP DATABASE DB_SkinFood1 
-- TO DISK = 'D:\Backup\DB_SkinFood1_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak'
-- WITH INIT, FORMAT;
-- GO

-- Ki?m tra kích thý?c database
EXEC sp_spaceused;
GO

-- Ki?m tra kích thý?c các b?ng
SELECT 
    t.NAME AS TableName,
    p.rows AS RowCounts,
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0
GROUP BY t.Name, p.Rows
ORDER BY TotalSpaceMB DESC;
GO

-- ==================================================================================
-- 8. TEST STORED PROCEDURES
-- ==================================================================================

-- Test procedure thanh toán
-- EXEC sp_ThanhToanDonHang @MaDH = 1, @PhuongThuc = N'COD';
-- GO

-- Test procedure duy?t ðánh giá
-- EXEC sp_DuyetDanhGia @MaDG = 1, @TraLoi = N'C?m õn b?n ð? ðánh giá!';
-- GO

-- Test procedure c?p nh?t t?n kho
-- EXEC sp_CapNhatTonKho @MaSP = 1, @SoLuongNhap = 50;
-- GO

-- ==================================================================================
-- 9. QUERY T?M KI?M VÀ L?C
-- ==================================================================================

-- T?m s?n ph?m theo tên
DECLARE @TimKiem NVARCHAR(100) = N'%s?a%';

SELECT * FROM SanPham
WHERE TenSP LIKE @TimKiem
    OR MoTa LIKE @TimKiem;
GO

-- L?c ðõn hàng theo kho?ng th?i gian
DECLARE @TuNgay DATE = '2025-01-01';
DECLARE @DenNgay DATE = '2025-12-31';

SELECT * FROM DonHang
WHERE NgayDat BETWEEN @TuNgay AND @DenNgay
ORDER BY NgayDat DESC;
GO

-- L?c s?n ph?m theo giá
DECLARE @GiaMin DECIMAL(18,2) = 100000;
DECLARE @GiaMax DECIMAL(18,2) = 500000;

SELECT * FROM SanPham
WHERE GiaBan BETWEEN @GiaMin AND @GiaMax
ORDER BY GiaBan;
GO

PRINT N'? T?t c? các query ð? s?n sàng ð? s? d?ng!';
