using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication15.Models
{
    public class GioHang
    {
        DB_SkinFoodEntities DB = new DB_SkinFoodEntities();
        public int MaSP { get; set; }
        public string TenSP { get; set; }
        public string AnhBia { get; set; }
        public double GiaBan { get; set; }
        public int SoLuong { get; set; }
        public double ThanhTien => SoLuong * GiaBan;

        public GioHang(int maSP)
        {
            MaSP = maSP;
            var sp = DB.SanPhams.Single(s => s.MaSP == maSP);
            TenSP = sp.TenSP;
            AnhBia = sp.HinhAnh;
            
            // Sửa lỗi: Phải tính giá sau giảm giá
            decimal giaGoc = sp.GiaBan ?? 0;
            
            if (sp.GiamGia != null && sp.GiamGia > 0)
            {
                // Áp dụng giảm giá
                decimal giaSauGiam = giaGoc * (1 - (sp.GiamGia.Value / 100));
                GiaBan = double.Parse(giaSauGiam.ToString());
            }
            else
            {
                // Không có giảm giá
                GiaBan = double.Parse(giaGoc.ToString());
            }
            
            SoLuong = 1;
        }
    }
}