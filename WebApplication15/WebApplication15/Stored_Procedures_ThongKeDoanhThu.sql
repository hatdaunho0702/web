-- ==================================================================================
-- STORED PROCEDURES CHO TH?NG KÊ DOANH THU
-- File: Stored_Procedures_ThongKeDoanhThu.sql
-- Ngày t?o: ${new Date().toLocaleDateString('vi-VN')}
-- ==================================================================================

USE DB_SkinFood;
GO

-- ==================================================================================
-- 1. STORED PROCEDURE: Th?ng kê doanh thu theo ngày
-- ==================================================================================
IF OBJECT_ID('sp_ThongKeDoanhThuTheoNgay', 'P') IS NOT NULL 
    DROP PROC sp_ThongKeDoanhThuTheoNgay;
GO

CREATE PROCEDURE sp_ThongKeDoanhThuTheoNgay
    @NgayBatDau DATE,
    @NgayKetThuc DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        CAST(NgayDat AS DATE) AS Ngay,
        COUNT(*) AS SoDonHang,
        SUM(TongTien) AS DoanhThu
    FROM DonHang
    WHERE TrangThaiThanhToan = N'Ð? thanh toán'
        AND NgayDat >= @NgayBatDau 
        AND NgayDat <= @NgayKetThuc
    GROUP BY CAST(NgayDat AS DATE)
    ORDER BY Ngay;
END;
GO

-- Test th?
-- EXEC sp_ThongKeDoanhThuTheoNgay '2025-01-01', '2025-12-31';

-- ==================================================================================
-- 2. STORED PROCEDURE: Th?ng kê doanh thu theo tháng
-- ==================================================================================
IF OBJECT_ID('sp_ThongKeDoanhThuTheoThang', 'P') IS NOT NULL 
    DROP PROC sp_ThongKeDoanhThuTheoThang;
GO

CREATE PROCEDURE sp_ThongKeDoanhThuTheoThang
    @Nam INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        MONTH(NgayDat) AS Thang,
        YEAR(NgayDat) AS Nam,
        COUNT(*) AS SoDonHang,
        SUM(TongTien) AS DoanhThu
    FROM DonHang
    WHERE TrangThaiThanhToan = N'Ð? thanh toán'
        AND YEAR(NgayDat) = @Nam
    GROUP BY YEAR(NgayDat), MONTH(NgayDat)
    ORDER BY YEAR(NgayDat), MONTH(NgayDat);
END;
GO

-- Test th?
-- EXEC sp_ThongKeDoanhThuTheoThang 2025;

-- ==================================================================================
-- 3. STORED PROCEDURE: Th?ng kê doanh thu theo nãm
-- ==================================================================================
IF OBJECT_ID('sp_ThongKeDoanhThuTheoNam', 'P') IS NOT NULL 
    DROP PROC sp_ThongKeDoanhThuTheoNam;
GO

CREATE PROCEDURE sp_ThongKeDoanhThuTheoNam
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        YEAR(NgayDat) AS Nam,
        COUNT(*) AS SoDonHang,
        SUM(TongTien) AS DoanhThu
    FROM DonHang
    WHERE TrangThaiThanhToan = N'Ð? thanh toán'
    GROUP BY YEAR(NgayDat)
    ORDER BY YEAR(NgayDat);
END;
GO

-- Test th?
-- EXEC sp_ThongKeDoanhThuTheoNam;

-- ==================================================================================
-- 4. STORED PROCEDURE: Top s?n ph?m bán ch?y
-- ==================================================================================
IF OBJECT_ID('sp_TopSanPhamBanChay', 'P') IS NOT NULL 
    DROP PROC sp_TopSanPhamBanChay;
GO

CREATE PROCEDURE sp_TopSanPhamBanChay
    @Top INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@Top)
        sp.MaSP,
        sp.TenSP,
        SUM(ct.SoLuong) AS SoLuongDaBan,
        SUM(ct.SoLuong * ct.DonGia) AS DoanhThu
    FROM ChiTietDonHangs ct
    INNER JOIN SanPham sp ON ct.MaSP = sp.MaSP
    INNER JOIN DonHang dh ON ct.MaDH = dh.MaDH
    WHERE dh.TrangThaiThanhToan = N'Ð? thanh toán'
    GROUP BY sp.MaSP, sp.TenSP
    ORDER BY SoLuongDaBan DESC;
END;
GO

-- Test th?
-- EXEC sp_TopSanPhamBanChay 5;

-- ==================================================================================
-- 5. STORED PROCEDURE: Th?ng kê t?ng h?p dashboard
-- ==================================================================================
IF OBJECT_ID('sp_ThongKeDashboard', 'P') IS NOT NULL 
    DROP PROC sp_ThongKeDashboard;
GO

CREATE PROCEDURE sp_ThongKeDashboard
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NgayHienTai DATETIME = GETDATE();
    DECLARE @NgayDauThang DATETIME = DATEFROMPARTS(YEAR(@NgayHienTai), MONTH(@NgayHienTai), 1);
    DECLARE @NgayDauNam DATETIME = DATEFROMPARTS(YEAR(@NgayHienTai), 1, 1);
    
    -- Th?ng kê t?ng quan
    SELECT 
        'TongQuan' AS LoaiThongKe,
        (SELECT COUNT(*) FROM SanPham) AS TongSanPham,
        (SELECT COUNT(*) FROM DonHang) AS TongDonHang,
        (SELECT COUNT(*) FROM TaiKhoan) AS TongTaiKhoan,
        (SELECT SUM(SoLuongTon) FROM SanPham) AS TongSoLuongTon;
    
    -- Doanh thu hôm nay
    SELECT 
        'DoanhThuHomNay' AS LoaiThongKe,
        COUNT(*) AS SoDonHang,
        ISNULL(SUM(TongTien), 0) AS DoanhThu
    FROM DonHang
    WHERE TrangThaiThanhToan = N'Ð? thanh toán'
        AND CAST(NgayDat AS DATE) = CAST(@NgayHienTai AS DATE);
    
    -- Doanh thu tháng này
    SELECT 
        'DoanhThuThangNay' AS LoaiThongKe,
        COUNT(*) AS SoDonHang,
        ISNULL(SUM(TongTien), 0) AS DoanhThu
    FROM DonHang
    WHERE TrangThaiThanhToan = N'Ð? thanh toán'
        AND NgayDat >= @NgayDauThang 
        AND NgayDat <= @NgayHienTai;
    
    -- Doanh thu nãm nay
    SELECT 
        'DoanhThuNamNay' AS LoaiThongKe,
        COUNT(*) AS SoDonHang,
        ISNULL(SUM(TongTien), 0) AS DoanhThu
    FROM DonHang
    WHERE TrangThaiThanhToan = N'Ð? thanh toán'
        AND NgayDat >= @NgayDauNam;
    
    -- Th?ng kê thanh toán
    SELECT 
        'ThongKeThanhToan' AS LoaiThongKe,
        COUNT(CASE WHEN TrangThaiThanhToan = N'Ð? thanh toán' THEN 1 END) AS DonHangDaThanhToan,
        COUNT(CASE WHEN TrangThaiThanhToan != N'Ð? thanh toán' OR TrangThaiThanhToan IS NULL THEN 1 END) AS DonHangChuaThanhToan,
        ISNULL(SUM(CASE WHEN TrangThaiThanhToan = N'Ð? thanh toán' THEN TongTien END), 0) AS DoanhThuDaThanhToan,
        ISNULL(SUM(CASE WHEN TrangThaiThanhToan != N'Ðá thanh toán' OR TrangThaiThanhToan IS NULL THEN TongTien END), 0) AS DoanhThuChuaThanhToan
    FROM DonHang;
END;
GO

-- Test th?
-- EXEC sp_ThongKeDashboard;

-- ==================================================================================
-- 6. STORED PROCEDURE: Doanh thu 7 ngày g?n ðây
-- ==================================================================================
IF OBJECT_ID('sp_DoanhThu7NgayGanDay', 'P') IS NOT NULL 
    DROP PROC sp_DoanhThu7NgayGanDay;
GO

CREATE PROCEDURE sp_DoanhThu7NgayGanDay
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NgayHienTai DATE = CAST(GETDATE() AS DATE);
    DECLARE @Ngay7NgayTruoc DATE = DATEADD(DAY, -6, @NgayHienTai);
    
    -- T?o b?ng t?m v?i 7 ngày
    ;WITH DateRange AS (
        SELECT @Ngay7NgayTruoc AS Ngay
        UNION ALL
        SELECT DATEADD(DAY, 1, Ngay)
        FROM DateRange
        WHERE Ngay < @NgayHienTai
    )
    SELECT 
        dr.Ngay,
        ISNULL(COUNT(dh.MaDH), 0) AS SoDonHang,
        ISNULL(SUM(dh.TongTien), 0) AS DoanhThu
    FROM DateRange dr
    LEFT JOIN DonHang dh ON CAST(dh.NgayDat AS DATE) = dr.Ngay 
        AND dh.TrangThaiThanhToan = N'Ð? thanh toán'
    GROUP BY dr.Ngay
    ORDER BY dr.Ngay;
END;
GO

-- Test th?
-- EXEC sp_DoanhThu7NgayGanDay;

-- ==================================================================================
-- 7. STORED PROCEDURE: Doanh thu 12 tháng g?n ðây
-- ==================================================================================
IF OBJECT_ID('sp_DoanhThu12ThangGanDay', 'P') IS NOT NULL 
    DROP PROC sp_DoanhThu12ThangGanDay;
GO

CREATE PROCEDURE sp_DoanhThu12ThangGanDay
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ThangHienTai DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    
    -- T?o b?ng t?m v?i 12 tháng
    ;WITH MonthRange AS (
        SELECT DATEADD(MONTH, -11, @ThangHienTai) AS ThangNam
        UNION ALL
        SELECT DATEADD(MONTH, 1, ThangNam)
        FROM MonthRange
        WHERE ThangNam < @ThangHienTai
    )
    SELECT 
        MONTH(mr.ThangNam) AS Thang,
        YEAR(mr.ThangNam) AS Nam,
        ISNULL(COUNT(dh.MaDH), 0) AS SoDonHang,
        ISNULL(SUM(dh.TongTien), 0) AS DoanhThu
    FROM MonthRange mr
    LEFT JOIN DonHang dh ON YEAR(dh.NgayDat) = YEAR(mr.ThangNam) 
        AND MONTH(dh.NgayDat) = MONTH(mr.ThangNam)
        AND dh.TrangThaiThanhToan = N'Ð? thanh toán'
    GROUP BY YEAR(mr.ThangNam), MONTH(mr.ThangNam)
    ORDER BY YEAR(mr.ThangNam), MONTH(mr.ThangNam);
END;
GO

-- Test th?
-- EXEC sp_DoanhThu12ThangGanDay;

-- ==================================================================================
-- 8. STORED PROCEDURE: Ki?m tra và c?p nh?t t?n kho khi ð?t hàng
-- ==================================================================================
IF OBJECT_ID('sp_KiemTraVaCapNhatTonKho', 'P') IS NOT NULL 
    DROP PROC sp_KiemTraVaCapNhatTonKho;
GO

CREATE PROCEDURE sp_KiemTraVaCapNhatTonKho
    @MaSP INT,
    @SoLuongDat INT,
    @KetQua NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SoLuongTon INT;
    
    -- L?y s? lý?ng t?n hi?n t?i
    SELECT @SoLuongTon = SoLuongTon
    FROM SanPham
    WHERE MaSP = @MaSP;
    
    -- Ki?m tra t?n kho
    IF @SoLuongTon IS NULL
    BEGIN
        SET @KetQua = N'S?n ph?m không t?n t?i!';
        RETURN -1;
    END
    
    IF @SoLuongTon < @SoLuongDat
    BEGIN
        SET @KetQua = N'S? lý?ng t?n kho không ð?! C?n ' + CAST(@SoLuongTon AS NVARCHAR(10)) + N' s?n ph?m.';
        RETURN -2;
    END
    
    -- C?p nh?t t?n kho
    UPDATE SanPham
    SET SoLuongTon = SoLuongTon - @SoLuongDat
    WHERE MaSP = @MaSP;
    
    SET @KetQua = N'C?p nh?t t?n kho thành công!';
    RETURN 0;
END;
GO

-- Test th?
/*
DECLARE @KetQua NVARCHAR(500);
DECLARE @ReturnCode INT;

EXEC @ReturnCode = sp_KiemTraVaCapNhatTonKho 
    @MaSP = 1, 
    @SoLuongDat = 2, 
    @KetQua = @KetQua OUTPUT;

PRINT N'K?t qu?: ' + @KetQua;
PRINT N'Return code: ' + CAST(@ReturnCode AS NVARCHAR(10));
*/

-- ==================================================================================
-- K?T THÚC FILE
-- ==================================================================================

PRINT N'? Ð? t?o xong t?t c? Stored Procedures cho th?ng kê doanh thu!';
GO
