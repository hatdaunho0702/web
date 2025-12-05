-- ==================================================================================
-- SCRIPT KHÔI PH?C B?NG DANHMUC VÀ D? LI?U
-- ==================================================================================

USE DB_SkinFood1;
GO

PRINT N'?? B?T Ð?U KI?M TRA VÀ KHÔI PH?C B?NG DANHMUC...';
PRINT N'';

-- ==================================================================================
-- 1. KI?M TRA B?NG DanhMuc
-- ==================================================================================

IF OBJECT_ID('DanhMuc', 'U') IS NULL
BEGIN
    PRINT N'?? B?ng DanhMuc không t?n t?i! Ðang t?o l?i...';
    
    -- T?O B?NG DanhMuc
    CREATE TABLE DanhMuc (
        MaDM INT PRIMARY KEY IDENTITY(1,1),
        TenDM NVARCHAR(100) NOT NULL
    );
    
    PRINT N'? Ð? t?o l?i b?ng DanhMuc';
END
ELSE
BEGIN
    PRINT N'? B?ng DanhMuc ð? t?n t?i';
END
GO

-- ==================================================================================
-- 2. KI?M TRA D? LI?U
-- ==================================================================================

DECLARE @SoLuongDanhMuc INT;
SELECT @SoLuongDanhMuc = COUNT(*) FROM DanhMuc;

PRINT N'?? S? lý?ng danh m?c hi?n t?i: ' + CAST(@SoLuongDanhMuc AS NVARCHAR(10));
PRINT N'';

-- ==================================================================================
-- 3. KHÔI PH?C D? LI?U DANH M?C (N?U B? M?T)
-- ==================================================================================

-- Xóa d? li?u c? n?u có (ð? insert l?i t? ð?u)
-- TRUNCATE TABLE DanhMuc; -- B? comment n?u mu?n xóa và insert l?i

-- T?t IDENTITY_INSERT ð? có th? insert v?i ID c? th?
SET IDENTITY_INSERT DanhMuc ON;
GO

-- Insert ho?c Update d? li?u danh m?c
IF NOT EXISTS (SELECT 1 FROM DanhMuc WHERE MaDM = 1)
BEGIN
    INSERT INTO DanhMuc (MaDM, TenDM) VALUES (1, N'M? ph?m chãm sóc da m?t');
    PRINT N'? Ð? thêm: M? ph?m chãm sóc da m?t';
END
ELSE
BEGIN
    UPDATE DanhMuc SET TenDM = N'M? ph?m chãm sóc da m?t' WHERE MaDM = 1;
    PRINT N'?? Ð? c?p nh?t: M? ph?m chãm sóc da m?t';
END

IF NOT EXISTS (SELECT 1 FROM DanhMuc WHERE MaDM = 2)
BEGIN
    INSERT INTO DanhMuc (MaDM, TenDM) VALUES (2, N'M? ph?m trang ði?m');
    PRINT N'? Ð? thêm: M? ph?m trang ði?m';
END
ELSE
BEGIN
    UPDATE DanhMuc SET TenDM = N'M? ph?m trang ði?m' WHERE MaDM = 2;
    PRINT N'?? Ð? c?p nh?t: M? ph?m trang ði?m';
END

IF NOT EXISTS (SELECT 1 FROM DanhMuc WHERE MaDM = 3)
BEGIN
    INSERT INTO DanhMuc (MaDM, TenDM) VALUES (3, N'M? ph?m tóc');
    PRINT N'? Ð? thêm: M? ph?m tóc';
END
ELSE
BEGIN
    UPDATE DanhMuc SET TenDM = N'M? ph?m tóc' WHERE MaDM = 3;
    PRINT N'?? Ð? c?p nh?t: M? ph?m tóc';
END

IF NOT EXISTS (SELECT 1 FROM DanhMuc WHERE MaDM = 4)
BEGIN
    INSERT INTO DanhMuc (MaDM, TenDM) VALUES (4, N'Dý?c ph?m');
    PRINT N'? Ð? thêm: Dý?c ph?m';
END
ELSE
BEGIN
    UPDATE DanhMuc SET TenDM = N'Dý?c ph?m' WHERE MaDM = 4;
    PRINT N'?? Ð? c?p nh?t: Dý?c ph?m';
END

IF NOT EXISTS (SELECT 1 FROM DanhMuc WHERE MaDM = 5)
BEGIN
    INSERT INTO DanhMuc (MaDM, TenDM) VALUES (5, N'M? ph?m chãm sóc cõ th?');
    PRINT N'? Ð? thêm: M? ph?m chãm sóc cõ th?';
END
ELSE
BEGIN
    UPDATE DanhMuc SET TenDM = N'M? ph?m chãm sóc cõ th?' WHERE MaDM = 5;
    PRINT N'?? Ð? c?p nh?t: M? ph?m chãm sóc cõ th?';
END

IF NOT EXISTS (SELECT 1 FROM DanhMuc WHERE MaDM = 6)
BEGIN
    INSERT INTO DanhMuc (MaDM, TenDM) VALUES (6, N'Ný?c hoa và ph? ki?n');
    PRINT N'? Ð? thêm: Ný?c hoa và ph? ki?n';
END
ELSE
BEGIN
    UPDATE DanhMuc SET TenDM = N'Ný?c hoa và ph? ki?n' WHERE MaDM = 6;
    PRINT N'?? Ð? c?p nh?t: Ný?c hoa và ph? ki?n';
END

-- B?t l?i IDENTITY_INSERT
SET IDENTITY_INSERT DanhMuc OFF;
GO

-- ==================================================================================
-- 4. KI?M TRA FOREIGN KEY RELATIONSHIPS
-- ==================================================================================

PRINT N'';
PRINT N'?? Ki?m tra m?i quan h? v?i các b?ng khác...';

-- Ki?m tra b?ng LoaiSP
IF OBJECT_ID('LoaiSP', 'U') IS NOT NULL
BEGIN
    -- Ki?m tra Foreign Key t? LoaiSP ð?n DanhMuc
    IF NOT EXISTS (
        SELECT 1 FROM sys.foreign_keys 
        WHERE name = 'FK_LoaiSP_DanhMuc' 
        OR (parent_object_id = OBJECT_ID('LoaiSP') 
            AND referenced_object_id = OBJECT_ID('DanhMuc'))
    )
    BEGIN
        PRINT N'?? Thi?u Foreign Key t? LoaiSP ? DanhMuc';
        
        -- T?o l?i Foreign Key n?u c?n
        ALTER TABLE LoaiSP
        ADD CONSTRAINT FK_LoaiSP_DanhMuc 
        FOREIGN KEY (MaDM) REFERENCES DanhMuc(MaDM);
        
        PRINT N'? Ð? t?o l?i Foreign Key: LoaiSP ? DanhMuc';
    END
    ELSE
    BEGIN
        PRINT N'? Foreign Key LoaiSP ? DanhMuc OK';
    END
END

-- Ki?m tra b?ng SanPham
IF OBJECT_ID('SanPham', 'U') IS NOT NULL
BEGIN
    -- Ki?m tra Foreign Key t? SanPham ð?n DanhMuc
    IF NOT EXISTS (
        SELECT 1 FROM sys.foreign_keys 
        WHERE name = 'FK_SanPham_DanhMuc'
        OR (parent_object_id = OBJECT_ID('SanPham') 
            AND referenced_object_id = OBJECT_ID('DanhMuc'))
    )
    BEGIN
        PRINT N'?? Thi?u Foreign Key t? SanPham ? DanhMuc';
        
        -- T?o l?i Foreign Key n?u c?n
        ALTER TABLE SanPham
        ADD CONSTRAINT FK_SanPham_DanhMuc 
        FOREIGN KEY (MaDM) REFERENCES DanhMuc(MaDM);
        
        PRINT N'? Ð? t?o l?i Foreign Key: SanPham ? DanhMuc';
    END
    ELSE
    BEGIN
        PRINT N'? Foreign Key SanPham ? DanhMuc OK';
    END
END

-- ==================================================================================
-- 5. KI?M TRA S?N PH?M B? M?T DANH M?C
-- ==================================================================================

PRINT N'';
PRINT N'?? Ki?m tra s?n ph?m không có danh m?c...';

DECLARE @SanPhamKhongCoDanhMuc INT;
SELECT @SanPhamKhongCoDanhMuc = COUNT(*) 
FROM SanPham 
WHERE MaDM IS NULL OR MaDM NOT IN (SELECT MaDM FROM DanhMuc);

IF @SanPhamKhongCoDanhMuc > 0
BEGIN
    PRINT N'?? Có ' + CAST(@SanPhamKhongCoDanhMuc AS NVARCHAR(10)) + N' s?n ph?m không có danh m?c h?p l?!';
    
    -- Gán danh m?c m?c ð?nh cho các s?n ph?m b? m?t danh m?c
    UPDATE SanPham 
    SET MaDM = 1 -- Gán vào danh m?c "M? ph?m chãm sóc da m?t"
    WHERE MaDM IS NULL OR MaDM NOT IN (SELECT MaDM FROM DanhMuc);
    
    PRINT N'? Ð? gán danh m?c m?c ð?nh cho các s?n ph?m';
END
ELSE
BEGIN
    PRINT N'? T?t c? s?n ph?m ð?u có danh m?c h?p l?';
END

-- ==================================================================================
-- 6. KI?M TRA LO?I S?N PH?M B? M?T DANH M?C
-- ==================================================================================

PRINT N'';
PRINT N'?? Ki?m tra lo?i s?n ph?m không có danh m?c...';

DECLARE @LoaiSPKhongCoDanhMuc INT;
SELECT @LoaiSPKhongCoDanhMuc = COUNT(*) 
FROM LoaiSP 
WHERE MaDM IS NULL OR MaDM NOT IN (SELECT MaDM FROM DanhMuc);

IF @LoaiSPKhongCoDanhMuc > 0
BEGIN
    PRINT N'?? Có ' + CAST(@LoaiSPKhongCoDanhMuc AS NVARCHAR(10)) + N' lo?i s?n ph?m không có danh m?c h?p l?!';
    
    -- Gán danh m?c m?c ð?nh cho các lo?i s?n ph?m b? m?t danh m?c
    UPDATE LoaiSP 
    SET MaDM = 1 -- Gán vào danh m?c "M? ph?m chãm sóc da m?t"
    WHERE MaDM IS NULL OR MaDM NOT IN (SELECT MaDM FROM DanhMuc);
    
    PRINT N'? Ð? gán danh m?c m?c ð?nh cho các lo?i s?n ph?m';
END
ELSE
BEGIN
    PRINT N'? T?t c? lo?i s?n ph?m ð?u có danh m?c h?p l?';
END

-- ==================================================================================
-- 7. K?T QU? CU?I CÙNG
-- ==================================================================================

PRINT N'';
PRINT N'========================================';
PRINT N'? HOÀN T?T KHÔI PH?C DANH M?C!';
PRINT N'========================================';
PRINT N'';

-- Hi?n th? danh sách danh m?c
PRINT N'?? Danh sách danh m?c hi?n t?i:';
SELECT MaDM, TenDM FROM DanhMuc ORDER BY MaDM;

-- Th?ng kê
SELECT 
    dm.MaDM,
    dm.TenDM,
    SoLuongLoaiSP = (SELECT COUNT(*) FROM LoaiSP WHERE MaDM = dm.MaDM),
    SoLuongSanPham = (SELECT COUNT(*) FROM SanPham WHERE MaDM = dm.MaDM)
FROM DanhMuc dm
ORDER BY dm.MaDM;

PRINT N'';
PRINT N'?? Ð? khôi ph?c xong danh m?c s?n ph?m!';
PRINT N'';
