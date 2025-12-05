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
            GiaBan = double.Parse(sp.GiaBan.ToString());
            SoLuong = 1;
        }
    }
}