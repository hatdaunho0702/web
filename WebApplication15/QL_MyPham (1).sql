-- ==================================================================================
-- ĐỒ ÁN CƠ SỞ DỮ LIỆU: HỆ THỐNG QUẢN LÝ MỸ PHẨM SKINFOOD
-- FILE ĐÃ SỬA LỖI (FIXED VERSION)
-- ==================================================================================

USE master;
GO

--TẠO DATABASE--
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DB_SkinFood')
BEGIN
    ALTER DATABASE DB_SkinFood SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DB_SkinFood;
END
GO

CREATE DATABASE DB_SkinFood;
GO

USE DB_SkinFood;
GO

-- ==================================================================================
-- PHẦN 1: TẠO CẤU TRÚC CÁC BẢNG
-- ==================================================================================

-- 1. BẢNG NGƯỜI DÙNG
CREATE TABLE NguoiDung (
    MaND INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    SoDienThoai NVARCHAR(20),
    DiaChi NVARCHAR(255),
    GioiTinh NVARCHAR(10),
    NgaySinh DATE,
    NgayTao DATETIME DEFAULT CURRENT_TIMESTAMP,
    TaiKhoan NVARCHAR(50) NULL, -- Thêm sẵn cột này cho phần Login form C#
    MatKhau NVARCHAR(50) NULL   -- Thêm sẵn cột này cho phần Login form C#
);
GO

-- 2. BẢNG TÀI KHOẢN (Quản lý phân quyền hệ thống)
CREATE TABLE TaiKhoan (
    MaTK INT PRIMARY KEY IDENTITY(1,1),
    TenDangNhap NVARCHAR(100) UNIQUE NOT NULL,
    MatKhauHash VARCHAR(500) NOT NULL,
    VaiTro NVARCHAR(20) DEFAULT 'KhachHang',
    MaND INT UNIQUE NOT NULL,
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);
GO

-- 3. BẢNG DANH MỤC
CREATE TABLE DanhMuc (
    MaDM INT PRIMARY KEY IDENTITY(1,1),
    TenDM NVARCHAR(100) NOT NULL
);
GO

-- 4. BẢNG LOẠI SẢN PHẨM
CREATE TABLE LoaiSP (
    MaLoai INT PRIMARY KEY IDENTITY(1,1),
    TenLoai NVARCHAR(100) NOT NULL,
    MaDM INT NOT NULL,
    FOREIGN KEY (MaDM) REFERENCES DanhMuc(MaDM)
);
GO

-- 5. BẢNG THƯƠNG HIỆU
CREATE TABLE ThuongHieu (
    MaTH INT PRIMARY KEY IDENTITY(1,1),
    TenTH NVARCHAR(100),
    QuocGia NVARCHAR(100)
);
GO

-- 6. BẢNG SẢN PHẨM
CREATE TABLE SanPham (
    MaSP INT PRIMARY KEY IDENTITY(1,1),
    TenSP NVARCHAR(200),
    GiamGia DECIMAL(18,2),
    GiaBan DECIMAL(18,2),
    MoTa NVARCHAR(MAX),
    HinhAnh NVARCHAR(255),
    SoLuongTon INT DEFAULT 0,
    MaDM INT,
    MaTH INT,
    MaLoai INT,
    NgaySanXuat DATETIME,
    HanSuDung DATETIME,
    LoaiDa NVARCHAR(50),
    VanDeChiRi NVARCHAR(255),
    TonDaMau NVARCHAR(50),
    ThanhPhanChiNhYeu NVARCHAR(MAX),
    SoLanSuDungMoiTuan INT DEFAULT 1,
    DoTinCay DECIMAL(3,1) DEFAULT 0,
    KichCoTieuChuan NVARCHAR(50),
    NgayNhapKho DATETIME DEFAULT GETDATE(),
    TrangThaiSanPham NVARCHAR(50) DEFAULT N'Kinh doanh',
    FOREIGN KEY (MaDM) REFERENCES DanhMuc(MaDM),
    FOREIGN KEY (MaTH) REFERENCES ThuongHieu(MaTH),
    FOREIGN KEY (MaLoai) REFERENCES LoaiSP(MaLoai)
);
GO

-- 7. BẢNG ĐƠN HÀNG
CREATE TABLE DonHang (
    MaDH INT PRIMARY KEY IDENTITY(1,1),
    MaND INT,
    NgayDat DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2),
    DiaChiGiaoHang NVARCHAR(255),
    TrangThaiThanhToan NVARCHAR(50) DEFAULT N'Chưa thanh toán',
    NgayThanhToan DATETIME NULL,
    PhuongThucThanhToan NVARCHAR(100) NULL,
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);
GO

-- 8. BẢNG CHI TIẾT ĐƠN HÀNG
CREATE TABLE ChiTietDonHangs (
    MaDH INT,
    MaSP INT,
    SoLuong INT,
    DonGia DECIMAL(18,2),
    PRIMARY KEY (MaDH, MaSP),
    FOREIGN KEY (MaDH) REFERENCES DonHang(MaDH),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- 9. BẢNG ĐÁNH GIÁ
CREATE TABLE DanhGia (
    MaDG INT PRIMARY KEY IDENTITY(1,1),
    MaSP INT,
    MaND INT,
    NoiDung NVARCHAR(500),
    Diem INT CHECK (Diem BETWEEN 1 AND 5),
    NgayDanhGia DATETIME DEFAULT GETDATE(),
    DuocApprove BIT DEFAULT 0,
    TraLoiAdmin NVARCHAR(500),
    ThoiGianTraLoi DATETIME,
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP),
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);
GO

-- 10. BẢNG THUỘC TÍNH MỸ PHẨM
CREATE TABLE ThuocTinhMyPham (
    MaThuocTinh INT PRIMARY KEY IDENTITY(1,1),
    TenThuocTinh NVARCHAR(100) NOT NULL,
    LoaiThuocTinh NVARCHAR(50) NOT NULL,
    MoTa NVARCHAR(255)
);
GO

-- 11. BẢNG LIÊN KẾT SẢN PHẨM - THUỘC TÍNH
CREATE TABLE SanPham_ThuocTinh (
    MaSP INT,
    MaThuocTinh INT,
    PRIMARY KEY (MaSP, MaThuocTinh),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP) ON DELETE CASCADE,
    FOREIGN KEY (MaThuocTinh) REFERENCES ThuocTinhMyPham(MaThuocTinh)
);
GO

-- 12. BẢNG NHẬP HÀNG
CREATE TABLE NhapHang (
    MaNhap INT PRIMARY KEY IDENTITY(1,1),
    MaSP INT NOT NULL,
    SoLuongNhap INT NOT NULL,
    NgayNhap DATETIME DEFAULT GETDATE(),
    NhaCungCap NVARCHAR(100),
    GiaVon DECIMAL(18,2),
    GhiChu NVARCHAR(255),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- 13. BẢNG XUẤT KHO
CREATE TABLE XuatKho (
    MaXuat INT PRIMARY KEY IDENTITY(1,1),
    MaSP INT NOT NULL,
    SoLuongXuat INT NOT NULL,
    NgayXuat DATETIME DEFAULT GETDATE(),
    LyDoXuat NVARCHAR(50),
    GhiChu NVARCHAR(255),
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
GO

-- ==================================================================================
-- PHẦN 2: CHÈN DỮ LIỆU MẪU
-- ==================================================================================

-- 1. NGƯỜI DÙNG
INSERT INTO NguoiDung (HoTen, SoDienThoai, DiaChi, GioiTinh, NgaySinh) VALUES
(N'Nguyễn Quỳnh Như', '0901234567', N'TP. Hồ Chí Minh', N'Nữ', '2003-05-12'),
(N'Nguyễn Văn An', '0912345678', N'Hà Nội', N'Nam', '1999-08-22'),
(N'Lê Thị Thu', '0987654321', N'Đà Nẵng', N'Nữ', '2000-10-05'),
(N'Trần Minh Tâm', '0933222111', N'Cần Thơ', N'Nam', '1998-12-30'),
(N'Phạm Hồng Hoa', '0977334455', N'Nha Trang', N'Nữ', '2001-06-18'),
(N'Võ Minh Khang', '0903456721', N'TP. Hồ Chí Minh', N'Nam', '2003-11-20'),
(N'Phạm Thùy Dung', '0938876123', N'Hà Nội', N'Nữ', '2002-04-18'),
(N'Lý Hoàng Phúc', '0981123456', N'Đà Nẵng', N'Nam', '2001-01-27'),
(N'Ngô Gia Hân', '0917765432', N'TP. Hồ Chí Minh', N'Nữ', '2004-06-02'),
(N'Hoàng Nhật Minh', '0976654321', N'Cần Thơ', N'Nam', '2000-09-09');
GO

-- 2. TÀI KHOẢN
INSERT INTO TaiKhoan (TenDangNhap, MatKhauHash, VaiTro, MaND) VALUES
('admin@skinfood.vn', 'admin123', N'Admin', 1),
('an@gmail.com', '123456', N'KhachHang', 2),
('thu@gmail.com', '123456', N'KhachHang', 3),
('tam@gmail.com', '123456', N'KhachHang', 4),
('hoa@gmail.com', '123456', N'KhachHang', 5);
GO

-- 3. DANH MỤC
INSERT INTO DanhMuc (TenDM) VALUES 
(N'Mỹ phẩm chăm sóc da mặt'), 
(N'Mỹ phẩm trang điểm'), 
(N'Mỹ phẩm tóc'), 
(N'Dược phẩm'), 
(N'Mỹ phẩm chăm sóc cơ thể'), 
(N'Nước hoa và phụ kiện');
GO

-- 4. LOẠI SẢN PHẨM
INSERT INTO LoaiSP (TenLoai, MaDM) VALUES 
(N'Sữa rửa mặt', 1), (N'Toner', 1), (N'Serum', 1), (N'Kem dưỡng da', 1), (N'Mặt nạ', 1),
(N'Kem nền', 2), (N'Son môi', 2), (N'Phấn phủ', 2),
(N'Dầu gội', 3), (N'Dầu xả', 3),
(N'Kem trị mụn', 4), (N'Kem chống nắng', 4),
(N'Sữa tắm', 5),
(N'Nước hoa', 6);
GO

-- 5. THƯƠNG HIỆU
INSERT INTO ThuongHieu (TenTH, QuocGia) VALUES 
(N'Innisfree', N'Hàn Quốc'), 
(N'The Face Shop', N'Hàn Quốc'), 
(N'Lancome', N'Pháp'), 
(N'L''Oreal', N'Pháp'), 
(N'Nature Republic', N'Hàn Quốc');
GO

-- 6. SẢN PHẨM
INSERT INTO SanPham (TenSP, GiaBan, SoLuongTon, MaDM, MaTH, MaLoai, HinhAnh, NgaySanXuat, HanSuDung, LoaiDa, VanDeChiRi, ThanhPhanChiNhYeu, KichCoTieuChuan) VALUES
(N'Sữa rửa mặt trà xanh', 150000, 150, 1, 1, 1, 'srm_traxanh.jpg', '2025-01-01', '2027-01-01', N'Dầu', N'Mụn|Thâm', N'Trà xanh, BHA', '150ml'),
(N'Kem dưỡng ẩm ban đêm', 350000, 45, 1, 2, 4, 'kemduong_bandem.jpg', '2023-01-20', '2026-01-20', N'Khô', N'Lão hóa', N'Retinol, Collagen', '50ml'),
(N'Mặt nạ đất sét', 180000, 20, 1, 1, 5, 'matna_datshet.jpg', '2024-02-10', '2026-02-10', N'Hỗn hợp', N'Mụn', N'Đất sét, khoáng chất', '100ml'),
(N'Toner hoa hồng', 200000, 80, 1, 3, 2, 'toner_hoahong.jpg', '2025-06-15', '2028-06-15', N'Khô', NULL, N'Hoa hồng, Glycerin', '200ml'),
(N'Serum Vitamin C', 450000, 10, 1, 4, 3, 'serum_vitc.jpg', '2023-10-01', '2025-10-01', N'Dầu', N'Thâm|Lão hóa', N'Vitamin C, Turmeric', '30ml'),
(N'Son môi đỏ tươi', 250000, 0, 2, 2, 7, 'son_do_tuoi.jpg', '2024-11-01', '2027-11-01', NULL, NULL, N'Pigment tự nhiên', '4.5g'),
(N'Dầu gội dưỡng tóc', 120000, 5, 3, 5, 9, 'daugoi_duongtoc.jpg', '2025-01-01', '2028-01-01', NULL, NULL, N'Biotin, Collagen', '200ml'),
(N'Nước hoa Pháp', 1500000, 20, 6, 3, 14, 'nuochoa_phap.jpg', '2025-01-01', '2030-01-01', NULL, NULL, N'Hương hoa cỏ', '50ml');
GO

-- 7. THUỘC TÍNH MỸ PHẨM
INSERT INTO ThuocTinhMyPham (TenThuocTinh, LoaiThuocTinh, MoTa) VALUES
(N'Dành cho da dầu', N'LoaiDa', N'Thích hợp với da dầu'),
(N'Dành cho da khô', N'LoaiDa', N'Thích hợp với da khô'),
(N'Dành cho da hỗn hợp', N'LoaiDa', N'Thích hợp với da hỗn hợp'),
(N'Dành cho da nhạy cảm', N'LoaiDa', N'Dùng cho da nhạy cảm'),
(N'Trị mụn', N'VanDe', N'Giúp giảm mụn hiệu quả'),
(N'Mờ thâm', N'VanDe', N'Giúp mờ thâm mụn'),
(N'Chống lão hóa', N'VanDe', N'Ngăn ngừa lão hóa da'),
(N'Trắng sáng', N'VanDe', N'Giúp da trắng sáng'),
(N'Có SPF', N'CongNghe', N'Chống nắng'),
(N'Retinol', N'CongNghe', N'Chứa retinol'),
(N'Hyaluronic Acid', N'CongNghe', N'Cấp ẩm'),
(N'Vegan', N'ChungChi', N'Không chứa sản phẩm động vật'),
(N'Cruelty-free', N'ChungChi', N'Không thử nghiệm trên động vật'),
(N'Organic', N'ChungChi', N'Sản phẩm hữu cơ');
GO

-- 8. LIÊN KẾT SẢN PHẨM - THUỘC TÍNH
INSERT INTO SanPham_ThuocTinh (MaSP, MaThuocTinh) VALUES
(1, 1), (1, 5), -- Sữa rửa mặt
(2, 2), (2, 7), -- Kem dưỡng
(3, 3), (3, 5), -- Mặt nạ
(4, 2), -- Toner
(5, 1), (5, 6), (5, 10); -- Serum
GO

-- 9. ĐƠN HÀNG
-- Tháng 1
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (2, '2025-01-15', 300000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (1, 1, 2, 150000);

-- Tháng 2
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (3, '2025-02-10', 2000000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (2, 8, 1, 1500000);
INSERT INTO ChiTietDonHangs VALUES (2, 6, 2, 250000);

INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (4, '2025-02-14', 500000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (3, 6, 2, 250000);

-- Tháng 3
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (5, '2025-03-05', 180000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (4, 3, 1, 180000);

-- Tháng 4
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (2, '2025-04-20', 700000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (5, 2, 2, 350000);

-- Tháng 5
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (3, '2025-05-02', 1350000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (6, 5, 3, 450000);

INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (4, '2025-05-15', 400000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (7, 4, 2, 200000);

-- Tháng 6
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (5, '2025-06-10', 120000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (8, 7, 1, 120000);

-- Tháng 10
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (2, '2025-10-05', 450000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (9, 1, 3, 150000);

INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (3, '2025-10-20', 1500000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (10, 8, 1, 1500000);

-- Tháng 11
INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (4, '2025-11-11', 2500000, N'Đã thanh toán');
INSERT INTO ChiTietDonHangs VALUES (11, 5, 2, 450000);
INSERT INTO ChiTietDonHangs VALUES (11, 2, 2, 350000);
INSERT INTO ChiTietDonHangs VALUES (11, 8, 1, 900000);

INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (5, '2025-11-15', 300000, N'Chưa thanh toán');
INSERT INTO ChiTietDonHangs VALUES (12, 1, 2, 150000);

INSERT INTO DonHang (MaND, NgayDat, TongTien, TrangThaiThanhToan) VALUES (2, '2025-11-20', 750000, N'Chưa thanh toán');
INSERT INTO ChiTietDonHangs VALUES (13, 6, 3, 250000);
GO

-- 10. ĐÁNH GIÁ
INSERT INTO DanhGia (MaSP, MaND, NoiDung, Diem, DuocApprove) VALUES
(1, 2, N'Sản phẩm rất tốt, dùng da mịn hơn hẳn! ', 5, 1),
(2, 3, N'Kem dưỡng ẩm nhẹ, không nhờn rít. ', 4, 1),
(3, 4, N'Mặt nạ đất sét hơi khô nhưng sạch da tốt.', 3, 0),
(5, 5, N'Serum giúp da sáng hơn rõ rệt.', 5, 1);
GO

-- 11. NHẬP HÀNG
INSERT INTO NhapHang (MaSP, SoLuongNhap, NgayNhap, NhaCungCap, GiaVon, GhiChu) VALUES
(1, 100, '2024-01-15', N'ABC Corp', 80000, N'Nhập lô A'),
(2, 50, '2024-02-01', N'XYZ Ltd', 150000, N'Nhập lô B'),
(3, 80, '2024-01-20', N'DEF Inc', 90000, N'Nhập lô C'),
(5, 30, '2024-03-01', N'GHI Co', 200000, N'Nhập lô D'),
(6, 120, '2024-02-15', N'JKL Group', 100000, N'Nhập lô E');
GO

-- ==================================================================================
-- PHẦN 3: THIẾT LẬP CÁC RÀNG BUỘC (CHECK, UNIQUE)
-- (Đã xóa các DEFAULT thừa để tránh lỗi Msg 1781)
-- ==================================================================================

-- 1. BẢNG NGƯỜI DÙNG
ALTER TABLE NguoiDung
ADD CONSTRAINT CK_NguoiDung_GioiTinh CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    CONSTRAINT CK_NguoiDung_NgaySinh CHECK (YEAR(NgaySinh) <= YEAR(GETDATE()) - 10),
    CONSTRAINT UQ_NguoiDung_SDT UNIQUE (SoDienThoai);
GO

-- 2. BẢNG TÀI KHOẢN
ALTER TABLE TaiKhoan
ADD CONSTRAINT UQ_TaiKhoan_TenDangNhap UNIQUE (TenDangNhap);
GO

-- 3. BẢNG SẢN PHẨM
ALTER TABLE SanPham
ADD CONSTRAINT CK_SanPham_GiaBan CHECK (GiaBan >= 0),
    CONSTRAINT CK_SanPham_SoLuongTon CHECK (SoLuongTon >= 0),
    CONSTRAINT CK_SanPham_DoTinCay CHECK (DoTinCay BETWEEN 0 AND 5);
GO

-- 4. BẢNG ĐƠN HÀNG
ALTER TABLE DonHang
ADD CONSTRAINT CK_DonHang_TongTien CHECK (TongTien >= 0);
GO

-- 5. BẢNG ĐÁNH GIÁ
ALTER TABLE DanhGia
ADD CONSTRAINT CK_DanhGia_Diem CHECK (Diem BETWEEN 1 AND 5);
GO

-- ==================================================================================
-- CHƯƠNG 2: PROCEDURES, FUNCTIONS, TRIGGERS, CURSORS, TRANSACTIONS
-- ==================================================================================

------------------------------------------
------------ STORED PROCEDURES -----------
------------------------------------------

-- 1️⃣ PROCEDURE: Thêm đơn hàng và tự động cập nhật tồn kho
IF OBJECT_ID('sp_ThemDonHang', 'P') IS NOT NULL DROP PROC sp_ThemDonHang;
GO

CREATE PROCEDURE sp_ThemDonHang
    @MaND INT,
    @MaSP INT,
    @SoLuong INT,
    @DiaChiGiaoHang NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Kiểm tra tồn kho
    IF (SELECT SoLuongTon FROM SanPham WHERE MaSP = @MaSP) < @SoLuong
    BEGIN
        RAISERROR(N'Số lượng tồn kho không đủ!', 16, 1);
        RETURN;
    END
    
    DECLARE @DonGia DECIMAL(18,2) = (SELECT GiaBan FROM SanPham WHERE MaSP = @MaSP);
    DECLARE @TongTien DECIMAL(18,2) = @DonGia * @SoLuong;
    
    -- Thêm đơn hàng
    INSERT INTO DonHang (MaND, TongTien, DiaChiGiaoHang)
    VALUES (@MaND, @TongTien, @DiaChiGiaoHang);
    
    DECLARE @MaDH INT = SCOPE_IDENTITY();
    
    -- Thêm chi tiết đơn hàng
    INSERT INTO ChiTietDonHangs (MaDH, MaSP, SoLuong, DonGia)
    VALUES (@MaDH, @MaSP, @SoLuong, @DonGia);
    
    -- Giảm tồn kho
    UPDATE SanPham SET SoLuongTon = SoLuongTon - @SoLuong WHERE MaSP = @MaSP;
    
    PRINT N'✅ Đã thêm đơn hàng thành công!';
END;
GO

-- 2️⃣ PROCEDURE: Thêm sản phẩm với kiểm tra trùng
IF OBJECT_ID('sp_ThemSanPham', 'P') IS NOT NULL DROP PROC sp_ThemSanPham;
GO

CREATE PROCEDURE sp_ThemSanPham
    @TenSP NVARCHAR(200),
    @GiaBan DECIMAL(18,2),
    @SoLuongTon INT,
    @MaDM INT,
    @MaTH INT,
    @MaLoai INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM SanPham WHERE TenSP = @TenSP AND MaTH = @MaTH)
    BEGIN
        PRINT N'❌ Sản phẩm đã tồn tại!';
        RETURN;
    END
    
    INSERT INTO SanPham (TenSP, GiaBan, SoLuongTon, MaDM, MaTH, MaLoai)
    VALUES (@TenSP, @GiaBan, @SoLuongTon, @MaDM, @MaTH, @MaLoai);
    
    PRINT N'✅ Đã thêm sản phẩm mới thành công!';
END;
GO

-- 3️⃣ PROCEDURE: Cập nhật tồn kho
IF OBJECT_ID('sp_CapNhatTonKho', 'P') IS NOT NULL DROP PROC sp_CapNhatTonKho;
GO

CREATE PROCEDURE sp_CapNhatTonKho
    @MaSP INT,
    @SoLuongNhap INT
AS
BEGIN
    UPDATE SanPham 
    SET SoLuongTon = SoLuongTon + @SoLuongNhap 
    WHERE MaSP = @MaSP;
    
    PRINT N'✅ Đã cập nhật tồn kho! ';
END;
GO

-- 4️⃣ PROCEDURE: Thanh toán đơn hàng
IF OBJECT_ID('sp_ThanhToanDonHang', 'P') IS NOT NULL DROP PROC sp_ThanhToanDonHang;
GO

CREATE PROCEDURE sp_ThanhToanDonHang
    @MaDH INT,
    @PhuongThuc NVARCHAR(100)
AS
BEGIN
    UPDATE DonHang 
    SET TrangThaiThanhToan = N'Đã thanh toán',
        NgayThanhToan = GETDATE(),
        PhuongThucThanhToan = @PhuongThuc
    WHERE MaDH = @MaDH;
    
    PRINT N'✅ Thanh toán thành công!';
END;
GO

-- 5️⃣ PROCEDURE: Duyệt đánh giá
IF OBJECT_ID('sp_DuyetDanhGia', 'P') IS NOT NULL DROP PROC sp_DuyetDanhGia;
GO

CREATE PROCEDURE sp_DuyetDanhGia
    @MaDG INT,
    @TraLoi NVARCHAR(500) = NULL
AS
BEGIN
    UPDATE DanhGia 
    SET DuocApprove = 1,
        TraLoiAdmin = @TraLoi,
        ThoiGianTraLoi = GETDATE()
    WHERE MaDG = @MaDG;
    
    PRINT N'✅ Đã duyệt đánh giá!';
END;
GO

------------------------------------------
---------------- FUNCTIONS ---------------
------------------------------------------

-- 1️⃣ FUNCTION: Tính tổng tiền theo đơn hàng
IF OBJECT_ID('fn_TongTienTheoDonHang', 'FN') IS NOT NULL DROP FUNCTION fn_TongTienTheoDonHang;
GO

CREATE FUNCTION fn_TongTienTheoDonHang(@MaDH INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);
    
    SELECT @Tong = SUM(SoLuong * DonGia)
    FROM ChiTietDonHangs
    WHERE MaDH = @MaDH;
    
    RETURN ISNULL(@Tong, 0);
END;
GO

-- 2️⃣ FUNCTION: Tổng tiền mua của khách hàng
IF OBJECT_ID('fn_TongTienTheoKhachHang', 'FN') IS NOT NULL DROP FUNCTION fn_TongTienTheoKhachHang;
GO

CREATE FUNCTION fn_TongTienTheoKhachHang(@MaND INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Tong DECIMAL(18,2);
    
    SELECT @Tong = SUM(TongTien)
    FROM DonHang
    WHERE MaND = @MaND AND TrangThaiThanhToan = N'Đã thanh toán';
    
    RETURN ISNULL(@Tong, 0);
END;
GO

-- 3️⃣ FUNCTION: Điểm trung bình của sản phẩm
IF OBJECT_ID('fn_DiemTrungBinhSanPham', 'FN') IS NOT NULL DROP FUNCTION fn_DiemTrungBinhSanPham;
GO

CREATE FUNCTION fn_DiemTrungBinhSanPham(@MaSP INT)
RETURNS DECIMAL(3,1)
AS
BEGIN
    DECLARE @DiemTB DECIMAL(3,1);
    
    SELECT @DiemTB = AVG(CAST(Diem AS DECIMAL(3,1)))
    FROM DanhGia
    WHERE MaSP = @MaSP AND DuocApprove = 1;
    
    RETURN ISNULL(@DiemTB, 0);
END;
GO

------------------------------------------
---------------- TRIGGERS ----------------
------------------------------------------

-- 1️⃣ TRIGGER: Tự động giảm tồn kho khi thêm chi tiết đơn hàng
IF OBJECT_ID('trg_GiamSoLuongTon', 'TR') IS NOT NULL DROP TRIGGER trg_GiamSoLuongTon;
GO

CREATE TRIGGER trg_GiamSoLuongTon
ON ChiTietDonHangs
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE sp
    SET sp.SoLuongTon = sp.SoLuongTon - i.SoLuong
    FROM SanPham sp
    INNER JOIN inserted i ON sp.MaSP = i.MaSP;
END;
GO

-- 2️⃣ TRIGGER: Tự động tăng tồn kho khi xóa chi tiết đơn hàng
IF OBJECT_ID('trg_TangSoLuongTon', 'TR') IS NOT NULL DROP TRIGGER trg_TangSoLuongTon;
GO

CREATE TRIGGER trg_TangSoLuongTon
ON ChiTietDonHangs
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE sp
    SET sp.SoLuongTon = sp.SoLuongTon + d.SoLuong
    FROM SanPham sp
    INNER JOIN deleted d ON sp.MaSP = d.MaSP;
END;
GO

-- 3️⃣ TRIGGER: Không cho xóa sản phẩm đã bán
IF OBJECT_ID('trg_KhongXoaSanPhamDaBan', 'TR') IS NOT NULL DROP TRIGGER trg_KhongXoaSanPhamDaBan;
GO

CREATE TRIGGER trg_KhongXoaSanPhamDaBan
ON SanPham
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ChiTietDonHangs c
        JOIN deleted d ON c.MaSP = d.MaSP
    )
    BEGIN
        PRINT N'❌ Không thể xóa sản phẩm đã có trong đơn hàng!';
        RETURN;
    END
    
    DELETE FROM SanPham WHERE MaSP IN (SELECT MaSP FROM deleted);
    PRINT N'✅ Đã xóa sản phẩm thành công!';
END;
GO

-- 4️⃣ TRIGGER: Tự động cập nhật điểm tin cậy khi có đánh giá mới
IF OBJECT_ID('trg_CapNhatDoTinCay', 'TR') IS NOT NULL DROP TRIGGER trg_CapNhatDoTinCay;
GO

CREATE TRIGGER trg_CapNhatDoTinCay
ON DanhGia
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE sp
    SET sp.DoTinCay = dbo.fn_DiemTrungBinhSanPham(sp.MaSP)
    FROM SanPham sp
    INNER JOIN inserted i ON sp.MaSP = i.MaSP;
END;
GO

------------------------------------------
---------------- CURSORS -----------------
------------------------------------------

-- 1️⃣ CURSOR: Duyệt đơn hàng chưa thanh toán
DECLARE cur_DonHangChuaThanhToan CURSOR FOR
SELECT MaDH, MaND, TongTien, NgayDat
FROM DonHang
WHERE TrangThaiThanhToan = N'Chưa thanh toán';

DECLARE @MaDH INT, @MaND INT, @TongTien DECIMAL(18,2), @NgayDat DATETIME;

OPEN cur_DonHangChuaThanhToan;
FETCH NEXT FROM cur_DonHangChuaThanhToan INTO @MaDH, @MaND, @TongTien, @NgayDat;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'Đơn hàng ' + CAST(@MaDH AS NVARCHAR(10)) + N' của khách ' + CAST(@MaND AS NVARCHAR(10)) + 
          N' chưa thanh toán, tổng tiền: ' + CAST(@TongTien AS NVARCHAR(20));
    FETCH NEXT FROM cur_DonHangChuaThanhToan INTO @MaDH, @MaND, @TongTien, @NgayDat;
END;

CLOSE cur_DonHangChuaThanhToan;
DEALLOCATE cur_DonHangChuaThanhToan;
GO

-- 2️⃣ CURSOR: Thống kê doanh thu theo tháng
DECLARE cur_DoanhThuThang CURSOR FOR
SELECT MONTH(NgayDat) AS Thang, SUM(TongTien) AS DoanhThu
FROM DonHang
WHERE TrangThaiThanhToan = N'Đã thanh toán'
GROUP BY MONTH(NgayDat)
ORDER BY Thang;

DECLARE @Thang INT, @DoanhThu DECIMAL(18,2);

OPEN cur_DoanhThuThang;
FETCH NEXT FROM cur_DoanhThuThang INTO @Thang, @DoanhThu;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'Tháng ' + CAST(@Thang AS NVARCHAR(2)) + N': Doanh thu = ' + CAST(@DoanhThu AS NVARCHAR(20)) + N' đồng';
    FETCH NEXT FROM cur_DoanhThuThang INTO @Thang, @DoanhThu;
END;

CLOSE cur_DoanhThuThang;
DEALLOCATE cur_DoanhThuThang;
GO

-- 3️⃣ CURSOR: Duyệt sản phẩm sắp hết hạn
DECLARE cur_SanPhamSapHetHan CURSOR FOR
SELECT MaSP, TenSP, HanSuDung, DATEDIFF(DAY, GETDATE(), HanSuDung) AS SoNgayConLai
FROM SanPham
WHERE HanSuDung <= DATEADD(MONTH, 3, GETDATE()) AND HanSuDung > GETDATE();

DECLARE @MaSP INT, @TenSP NVARCHAR(200), @HanSuDung DATETIME, @SoNgayConLai INT;

OPEN cur_SanPhamSapHetHan;
FETCH NEXT FROM cur_SanPhamSapHetHan INTO @MaSP, @TenSP, @HanSuDung, @SoNgayConLai;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'⚠️ Sản phẩm ' + @TenSP + N' sắp hết hạn sau ' + CAST(@SoNgayConLai AS NVARCHAR(10)) + N' ngày';
    FETCH NEXT FROM cur_SanPhamSapHetHan INTO @MaSP, @TenSP, @HanSuDung, @SoNgayConLai;
END;

CLOSE cur_SanPhamSapHetHan;
DEALLOCATE cur_SanPhamSapHetHan;
GO

------------------------------------------
------------- TRANSACTIONS ---------------
------------------------------------------

-- 1️⃣ TRANSACTION: Xử lý đặt hàng với kiểm tra tồn kho
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @MaND_Test INT = 2;
    DECLARE @MaSP_Test INT = 1;
    DECLARE @SoLuong_Test INT = 2;
    
    -- Kiểm tra tồn kho
    IF (SELECT SoLuongTon FROM SanPham WHERE MaSP = @MaSP_Test) < @SoLuong_Test
    BEGIN
        RAISERROR(N'Sản phẩm không đủ số lượng!', 16, 1);
    END
    
    -- Thêm đơn hàng
    INSERT INTO DonHang (MaND, TongTien, DiaChiGiaoHang)
    VALUES (@MaND_Test, 300000, N'TP. HCM');
    
    DECLARE @MaDH_Test INT = SCOPE_IDENTITY();
    
    -- Thêm chi tiết
    INSERT INTO ChiTietDonHangs VALUES (@MaDH_Test, @MaSP_Test, @SoLuong_Test, 150000);
    
    -- Giảm tồn kho
    UPDATE SanPham SET SoLuongTon = SoLuongTon - @SoLuong_Test WHERE MaSP = @MaSP_Test;
    
    COMMIT TRANSACTION;
    PRINT N'✅ Đặt hàng thành công! ';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ Giao dịch thất bại: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 2️⃣ TRANSACTION: Nhập hàng an toàn
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @MaSP_Nhap INT = 5;
    DECLARE @SoLuongNhap INT = 50;
    DECLARE @GiaVon DECIMAL(18,2) = 200000;
    
    -- Thêm vào bảng nhập hàng
    INSERT INTO NhapHang (MaSP, SoLuongNhap, NhaCungCap, GiaVon)
    VALUES (@MaSP_Nhap, @SoLuongNhap, N'NCC Test', @GiaVon);
    
    -- Cập nhật tồn kho
    UPDATE SanPham 
    SET SoLuongTon = SoLuongTon + @SoLuongNhap 
    WHERE MaSP = @MaSP_Nhap;
    
    COMMIT TRANSACTION;
    PRINT N'✅ Nhập hàng thành công!';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'❌ Nhập hàng thất bại: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==================================================================================
-- CHƯƠNG 3: QUẢN LÝ NGƯỜI DÙNG VÀ PHÂN QUYỀN
-- ==================================================================================

-- 1️⃣ TẠO LOGIN (Có kiểm tra tồn tại để tránh lỗi Msg 15025)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'AdminMyPham')
BEGIN
    CREATE LOGIN AdminMyPham WITH PASSWORD = '123456';
END

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'NVBanHang')
BEGIN
    CREATE LOGIN NVBanHang WITH PASSWORD = '123456';
END

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'KhachHang')
BEGIN
    CREATE LOGIN KhachHang WITH PASSWORD = '123456';
END
GO

-- 2️⃣ TẠO USER TRONG DATABASE
USE DB_SkinFood;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminMyPhamUser')
BEGIN
    CREATE USER AdminMyPhamUser FOR LOGIN AdminMyPham;
END

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'NVBanHangUser')
BEGIN
    CREATE USER NVBanHangUser FOR LOGIN NVBanHang;
END

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'KhachHangUser')
BEGIN
    CREATE USER KhachHangUser FOR LOGIN KhachHang;
END
GO

-- 3️⃣ TẠO ROLE
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_QuanTri')
    CREATE ROLE role_QuanTri;
    
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_NhanVien')
    CREATE ROLE role_NhanVien;
    
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'role_KhachHang')
    CREATE ROLE role_KhachHang;
GO

-- 4️⃣ PHÂN QUYỀN CHO ROLE

-- ROLE QUẢN TRỊ (toàn quyền)
GRANT SELECT, INSERT, UPDATE, DELETE ON SanPham TO role_QuanTri;
GRANT SELECT, INSERT, UPDATE, DELETE ON DonHang TO role_QuanTri;
GRANT SELECT, INSERT, UPDATE, DELETE ON ChiTietDonHangs TO role_QuanTri;
GRANT SELECT, INSERT, UPDATE, DELETE ON DanhGia TO role_QuanTri;
GRANT SELECT, INSERT, UPDATE, DELETE ON NguoiDung TO role_QuanTri;
GO

-- ROLE NHÂN VIÊN (xem và thêm đơn)
GRANT SELECT ON SanPham TO role_NhanVien;
GRANT SELECT, INSERT ON DonHang TO role_NhanVien;
GRANT SELECT, INSERT ON ChiTietDonHangs TO role_NhanVien;
GRANT SELECT ON DanhGia TO role_NhanVien;
GO

-- ROLE KHÁCH HÀNG (chỉ xem)
GRANT SELECT ON SanPham TO role_KhachHang;
GRANT SELECT ON DanhGia TO role_KhachHang;
GO

-- 5️⃣ GÁN USER VÀO ROLE
EXEC sp_addrolemember 'role_QuanTri', 'AdminMyPhamUser';
EXEC sp_addrolemember 'role_NhanVien', 'NVBanHangUser';
EXEC sp_addrolemember 'role_KhachHang', 'KhachHangUser';
GO

-- 6️⃣ SAO LƯU VÀ PHỤC HỒI DATABASE

-- Script sao lưu tự động (SQL Agent Job)
USE msdb;
GO

IF EXISTS (SELECT * FROM sysjobs WHERE name = N'Backup_DB_SkinFood')
BEGIN
    EXEC sp_delete_job @job_name = N'Backup_DB_SkinFood';
END
GO

EXEC sp_add_job @job_name = N'Backup_DB_SkinFood';

EXEC sp_add_jobstep
    @job_name = N'Backup_DB_SkinFood',
    @step_name = N'Full backup DB_SkinFood',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE DB_SkinFood
                 TO DISK = N''D:\Backup\DB_SkinFood_'' + CONVERT(VARCHAR(8), GETDATE(), 112) + ''.bak''
                 WITH INIT, FORMAT;',
    @database_name = N'master';

EXEC sp_add_schedule
    @schedule_name = N'Backup_Daily',
    @freq_type = 4, -- daily
    @freq_interval = 1,
    @active_start_time = 230000; -- 23:00

EXEC sp_attach_schedule @job_name = N'Backup_DB_SkinFood', @schedule_name = N'Backup_Daily';
EXEC sp_add_jobserver @job_name = N'Backup_DB_SkinFood';
GO

USE DB_SkinFood;
GO

-- ==================================================================================
-- CHƯƠNG 4: STORED PROCEDURES CHO FORM C#
-- ==================================================================================

-- 1️⃣ PROCEDURE ĐĂNG NHẬP
IF OBJECT_ID('sp_NguoiDung_Login', 'P') IS NOT NULL DROP PROC sp_NguoiDung_Login;
GO

CREATE PROC sp_NguoiDung_Login
    @TenDangNhap NVARCHAR(100),
    @MatKhau NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT nd.MaND, nd.HoTen, tk.VaiTro
    FROM TaiKhoan tk
    INNER JOIN NguoiDung nd ON tk.MaND = nd.MaND
    WHERE tk.TenDangNhap = @TenDangNhap
      AND tk.MatKhauHash = @MatKhau;
END;
GO

-- 2️⃣ PROCEDURE TẠO TÀI KHOẢN
IF OBJECT_ID('sp_NguoiDung_Create', 'P') IS NOT NULL DROP PROC sp_NguoiDung_Create;
GO

CREATE PROC sp_NguoiDung_Create
    @HoTen NVARCHAR(100),
    @SoDienThoai NVARCHAR(20),
    @TenDangNhap NVARCHAR(100),
    @MatKhau NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (SELECT 1 FROM TaiKhoan WHERE TenDangNhap = @TenDangNhap)
    BEGIN
        RAISERROR(N'Tên đăng nhập đã tồn tại!', 16, 1);
        RETURN;
    END
    
    -- Thêm người dùng
    INSERT INTO NguoiDung (HoTen, SoDienThoai)
    VALUES (@HoTen, @SoDienThoai);
    
    DECLARE @MaND INT = SCOPE_IDENTITY();
    
    -- Thêm tài khoản
    INSERT INTO TaiKhoan (TenDangNhap, MatKhauHash, VaiTro, MaND)
    VALUES (@TenDangNhap, @MatKhau, N'KhachHang', @MaND);
    
    PRINT N'✅ Tạo tài khoản thành công!';
END;
GO

-- 3️⃣ PROCEDURE ĐỔI MẬT KHẨU
IF OBJECT_ID('sp_NguoiDung_ChangePassword', 'P') IS NOT NULL DROP PROC sp_NguoiDung_ChangePassword;
GO

CREATE PROC sp_NguoiDung_ChangePassword
    @TenDangNhap NVARCHAR(100),
    @MatKhauCu NVARCHAR(50),
    @MatKhauMoi NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (
        SELECT 1 FROM TaiKhoan
        WHERE TenDangNhap = @TenDangNhap AND MatKhauHash = @MatKhauCu
    )
    BEGIN
        RAISERROR(N'Mật khẩu cũ không đúng!', 16, 1);
        RETURN;
    END
    
    UPDATE TaiKhoan
    SET MatKhauHash = @MatKhauMoi
    WHERE TenDangNhap = @TenDangNhap;
    
    PRINT N'✅ Đổi mật khẩu thành công!';
END;
GO

-- 4️⃣ PROCEDURES CHO QUẢN LÝ SẢN PHẨM

-- Lấy danh sách sản phẩm
IF OBJECT_ID('sp_SanPham_SelectAll', 'P') IS NOT NULL DROP PROC sp_SanPham_SelectAll;
GO

CREATE PROC sp_SanPham_SelectAll
AS
BEGIN
    SELECT sp.MaSP, sp.TenSP, sp.GiaBan, sp.SoLuongTon, 
           dm.TenDM, lsp.TenLoai, th.TenTH, sp.HinhAnh
    FROM SanPham sp
    LEFT JOIN DanhMuc dm ON sp.MaDM = dm.MaDM
    LEFT JOIN LoaiSP lsp ON sp.MaLoai = lsp.MaLoai
    LEFT JOIN ThuongHieu th ON sp.MaTH = th.MaTH
    ORDER BY sp.MaSP;
END;
GO

-- Thêm sản phẩm
IF OBJECT_ID('sp_SanPham_Insert', 'P') IS NOT NULL DROP PROC sp_SanPham_Insert;
GO

CREATE PROC sp_SanPham_Insert
    @TenSP NVARCHAR(200),
    @GiaBan DECIMAL(18,2),
    @SoLuongTon INT,
    @MaDM INT,
    @MaTH INT,
    @MaLoai INT
AS
BEGIN
    INSERT INTO SanPham (TenSP, GiaBan, SoLuongTon, MaDM, MaTH, MaLoai)
    VALUES (@TenSP, @GiaBan, @SoLuongTon, @MaDM, @MaTH, @MaLoai);
END;
GO

-- Cập nhật sản phẩm
IF OBJECT_ID('sp_SanPham_Update', 'P') IS NOT NULL DROP PROC sp_SanPham_Update;
GO

CREATE PROC sp_SanPham_Update
    @MaSP INT,
    @TenSP NVARCHAR(200),
    @GiaBan DECIMAL(18,2),
    @SoLuongTon INT
AS
BEGIN
    UPDATE SanPham
    SET TenSP = @TenSP, GiaBan = @GiaBan, SoLuongTon = @SoLuongTon
    WHERE MaSP = @MaSP;
END;
GO

-- Xóa sản phẩm
IF OBJECT_ID('sp_SanPham_Delete', 'P') IS NOT NULL DROP PROC sp_SanPham_Delete;
GO

CREATE PROC sp_SanPham_Delete
    @MaSP INT
AS
BEGIN
    DELETE FROM SanPham WHERE MaSP = @MaSP;
END;
GO

-- 5️⃣ PROCEDURES CHO QUẢN LÝ ĐƠN HÀNG

-- Lấy danh sách đơn hàng
IF OBJECT_ID('sp_DonHang_SelectAll', 'P') IS NOT NULL DROP PROC sp_DonHang_SelectAll;
GO

CREATE PROC sp_DonHang_SelectAll
AS
BEGIN
    SELECT dh.MaDH, nd.HoTen, dh.NgayDat, dh.TongTien, dh.TrangThaiThanhToan
    FROM DonHang dh
    INNER JOIN NguoiDung nd ON dh.MaND = nd.MaND
    ORDER BY dh.NgayDat DESC;
END;
GO

-- Thêm đơn hàng
IF OBJECT_ID('sp_DonHang_Insert', 'P') IS NOT NULL DROP PROC sp_DonHang_Insert;
GO

CREATE PROC sp_DonHang_Insert
    @MaND INT,
    @TongTien DECIMAL(18,2),
    @DiaChiGiaoHang NVARCHAR(255)
AS
BEGIN
    INSERT INTO DonHang (MaND, TongTien, DiaChiGiaoHang)
    VALUES (@MaND, @TongTien, @DiaChiGiaoHang);
    
    SELECT SCOPE_IDENTITY() AS MaDH;
END;
GO

-- Cập nhật đơn hàng
IF OBJECT_ID('sp_DonHang_Update', 'P') IS NOT NULL DROP PROC sp_DonHang_Update;
GO

CREATE PROC sp_DonHang_Update
    @MaDH INT,
    @TrangThaiThanhToan NVARCHAR(50)
AS
BEGIN
    UPDATE DonHang
    SET TrangThaiThanhToan = @TrangThaiThanhToan,
        NgayThanhToan = CASE WHEN @TrangThaiThanhToan = N'Đã thanh toán' THEN GETDATE() ELSE NULL END
    WHERE MaDH = @MaDH;
END;
GO