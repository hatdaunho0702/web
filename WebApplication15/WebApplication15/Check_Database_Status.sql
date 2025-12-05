-- ==================================================================================
-- SCRIPT KI?M TRA NHANH T?NH TR?NG DATABASE
-- ==================================================================================

USE DB_SkinFood1;
GO

PRINT N'';
PRINT N'========================================';
PRINT N'?? KI?M TRA T?NH TR?NG DATABASE';
PRINT N'========================================';
PRINT N'';

-- ==================================================================================
-- 1. KI?M TRA CÁC B?NG CHÍNH
-- ==================================================================================

PRINT N'?? 1. KI?M TRA CÁC B?NG CHÍNH:';
PRINT N'-----------------------------------';

-- DanhMuc
IF OBJECT_ID('DanhMuc', 'U') IS NOT NULL
BEGIN
    DECLARE @CountDM INT = (SELECT COUNT(*) FROM DanhMuc);
    PRINT N'? DanhMuc: T?n t?i (' + CAST(@CountDM AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? DanhMuc: KHÔNG T?N T?I!';

-- LoaiSP
IF OBJECT_ID('LoaiSP', 'U') IS NOT NULL
BEGIN
    DECLARE @CountLoai INT = (SELECT COUNT(*) FROM LoaiSP);
    PRINT N'? LoaiSP: T?n t?i (' + CAST(@CountLoai AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? LoaiSP: KHÔNG T?N T?I!';

-- ThuongHieu
IF OBJECT_ID('ThuongHieu', 'U') IS NOT NULL
BEGIN
    DECLARE @CountTH INT = (SELECT COUNT(*) FROM ThuongHieu);
    PRINT N'? ThuongHieu: T?n t?i (' + CAST(@CountTH AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? ThuongHieu: KHÔNG T?N T?I!';

-- SanPham
IF OBJECT_ID('SanPham', 'U') IS NOT NULL
BEGIN
    DECLARE @CountSP INT = (SELECT COUNT(*) FROM SanPham);
    PRINT N'? SanPham: T?n t?i (' + CAST(@CountSP AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? SanPham: KHÔNG T?N T?I!';

-- NguoiDung
IF OBJECT_ID('NguoiDung', 'U') IS NOT NULL
BEGIN
    DECLARE @CountND INT = (SELECT COUNT(*) FROM NguoiDung);
    PRINT N'? NguoiDung: T?n t?i (' + CAST(@CountND AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? NguoiDung: KHÔNG T?N T?I!';

-- TaiKhoan
IF OBJECT_ID('TaiKhoan', 'U') IS NOT NULL
BEGIN
    DECLARE @CountTK INT = (SELECT COUNT(*) FROM TaiKhoan);
    PRINT N'? TaiKhoan: T?n t?i (' + CAST(@CountTK AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? TaiKhoan: KHÔNG T?N T?I!';

-- DonHang
IF OBJECT_ID('DonHang', 'U') IS NOT NULL
BEGIN
    DECLARE @CountDH INT = (SELECT COUNT(*) FROM DonHang);
    PRINT N'? DonHang: T?n t?i (' + CAST(@CountDH AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? DonHang: KHÔNG T?N T?I!';

-- ChiTietDonHangs
IF OBJECT_ID('ChiTietDonHangs', 'U') IS NOT NULL
BEGIN
    DECLARE @CountCT INT = (SELECT COUNT(*) FROM ChiTietDonHangs);
    PRINT N'? ChiTietDonHangs: T?n t?i (' + CAST(@CountCT AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE IF OBJECT_ID('ChiTietDonHang', 'U') IS NOT NULL
BEGIN
    PRINT N'?? ChiTietDonHang: T?n t?i (C?N Ð?I TÊN ? ChiTietDonHangs)';
END
ELSE
    PRINT N'? ChiTietDonHangs: KHÔNG T?N T?I!';

-- LienHe
IF OBJECT_ID('LienHe', 'U') IS NOT NULL
BEGIN
    DECLARE @CountLH INT = (SELECT COUNT(*) FROM LienHe);
    PRINT N'? LienHe: T?n t?i (' + CAST(@CountLH AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'?? LienHe: KHÔNG T?N T?I (C?n t?o)';

-- DanhGia
IF OBJECT_ID('DanhGia', 'U') IS NOT NULL
BEGIN
    DECLARE @CountDG INT = (SELECT COUNT(*) FROM DanhGia);
    PRINT N'? DanhGia: T?n t?i (' + CAST(@CountDG AS NVARCHAR(10)) + N' b?n ghi)';
END
ELSE
    PRINT N'? DanhGia: KHÔNG T?N T?I!';

PRINT N'';

-- ==================================================================================
-- 2. KI?M TRA C?U TRÚC B?NG DonHang
-- ==================================================================================

PRINT N'?? 2. KI?M TRA C?U TRÚC B?NG DonHang:';
PRINT N'-----------------------------------';

IF COL_LENGTH('DonHang', 'TrangThaiThanhToan') IS NOT NULL
    PRINT N'? C?t TrangThaiThanhToan: T?n t?i';
ELSE
    PRINT N'? C?t TrangThaiThanhToan: THI?U!';

IF COL_LENGTH('DonHang', 'NgayThanhToan') IS NOT NULL
    PRINT N'? C?t NgayThanhToan: T?n t?i';
ELSE
    PRINT N'? C?t NgayThanhToan: THI?U!';

IF COL_LENGTH('DonHang', 'PhuongThucThanhToan') IS NOT NULL
    PRINT N'? C?t PhuongThucThanhToan: T?n t?i';
ELSE
    PRINT N'? C?t PhuongThucThanhToan: THI?U!';

PRINT N'';

-- ==================================================================================
-- 3. KI?M TRA D? LI?U DANH M?C
-- ==================================================================================

PRINT N'?? 3. DANH SÁCH DANH M?C:';
PRINT N'-----------------------------------';

IF OBJECT_ID('DanhMuc', 'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM DanhMuc)
    BEGIN
        SELECT MaDM, TenDM FROM DanhMuc ORDER BY MaDM;
    END
    ELSE
    BEGIN
        PRINT N'?? B?ng DanhMuc TR?NG!';
    END
END

PRINT N'';

-- ==================================================================================
-- 4. KI?M TRA S?N PH?M KHÔNG CÓ DANH M?C
-- ==================================================================================

PRINT N'?? 4. KI?M TRA S?N PH?M B?T THÝ?NG:';
PRINT N'-----------------------------------';

IF OBJECT_ID('SanPham', 'U') IS NOT NULL AND OBJECT_ID('DanhMuc', 'U') IS NOT NULL
BEGIN
    DECLARE @SPKhongDM INT;
    SELECT @SPKhongDM = COUNT(*) 
    FROM SanPham 
    WHERE MaDM IS NULL OR MaDM NOT IN (SELECT MaDM FROM DanhMuc);
    
    IF @SPKhongDM > 0
        PRINT N'?? Có ' + CAST(@SPKhongDM AS NVARCHAR(10)) + N' s?n ph?m KHÔNG CÓ danh m?c h?p l?!';
    ELSE
        PRINT N'? T?t c? s?n ph?m ð?u có danh m?c h?p l?';
END

IF OBJECT_ID('LoaiSP', 'U') IS NOT NULL AND OBJECT_ID('DanhMuc', 'U') IS NOT NULL
BEGIN
    DECLARE @LoaiKhongDM INT;
    SELECT @LoaiKhongDM = COUNT(*) 
    FROM LoaiSP 
    WHERE MaDM IS NULL OR MaDM NOT IN (SELECT MaDM FROM DanhMuc);
    
    IF @LoaiKhongDM > 0
        PRINT N'?? Có ' + CAST(@LoaiKhongDM AS NVARCHAR(10)) + N' lo?i s?n ph?m KHÔNG CÓ danh m?c h?p l?!';
    ELSE
        PRINT N'? T?t c? lo?i s?n ph?m ð?u có danh m?c h?p l?';
END

PRINT N'';

-- ==================================================================================
-- 5. KI?M TRA STORED PROCEDURES
-- ==================================================================================

PRINT N'?? 5. KI?M TRA STORED PROCEDURES:';
PRINT N'-----------------------------------';

IF OBJECT_ID('sp_ThemDonHang', 'P') IS NOT NULL
    PRINT N'? sp_ThemDonHang: T?n t?i';
ELSE
    PRINT N'? sp_ThemDonHang: THI?U!';

IF OBJECT_ID('sp_CapNhatTonKho', 'P') IS NOT NULL
    PRINT N'? sp_CapNhatTonKho: T?n t?i';
ELSE
    PRINT N'? sp_CapNhatTonKho: THI?U!';

IF OBJECT_ID('sp_ThanhToanDonHang', 'P') IS NOT NULL
    PRINT N'? sp_ThanhToanDonHang: T?n t?i';
ELSE
    PRINT N'? sp_ThanhToanDonHang: THI?U!';

IF OBJECT_ID('sp_DuyetDanhGia', 'P') IS NOT NULL
    PRINT N'? sp_DuyetDanhGia: T?n t?i';
ELSE
    PRINT N'? sp_DuyetDanhGia: THI?U!';

PRINT N'';
PRINT N'========================================';
PRINT N'? HOÀN T?T KI?M TRA!';
PRINT N'========================================';
PRINT N'';

-- ==================================================================================
-- 6. KHUY?N NGH?
-- ==================================================================================

PRINT N'?? KHUY?N NGH?:';
PRINT N'-----------------------------------';

-- Ki?m tra xem có c?n ch?y script khôi ph?c không
IF OBJECT_ID('DanhMuc', 'U') IS NULL 
    OR NOT EXISTS (SELECT 1 FROM DanhMuc)
    OR OBJECT_ID('ChiTietDonHangs', 'U') IS NULL
    OR COL_LENGTH('DonHang', 'TrangThaiThanhToan') IS NULL
BEGIN
    PRINT N'?? C?N CH?Y CÁC SCRIPT SAU:';
    PRINT N'';
    
    IF OBJECT_ID('DanhMuc', 'U') IS NULL OR NOT EXISTS (SELECT 1 FROM DanhMuc)
        PRINT N'   ? Restore_DanhMuc.sql (Khôi ph?c danh m?c)';
    
    IF OBJECT_ID('ChiTietDonHangs', 'U') IS NULL 
        OR COL_LENGTH('DonHang', 'TrangThaiThanhToan') IS NULL
        PRINT N'   ? Update_DB_SkinFood1.sql (C?p nh?t c?u trúc)';
    
    PRINT N'';
END
ELSE
BEGIN
    PRINT N'? Database ðang ho?t ð?ng t?t!';
    PRINT N'';
END
