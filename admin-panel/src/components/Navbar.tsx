'use client';
import { useRouter, usePathname } from 'next/navigation';

export default function Navbar() {
  const router = useRouter();
  const pathname = usePathname();

  const handleLogout = () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token');
      router.push('/login');
    }
  };

  const getPageTitle = () => {
    if (pathname === '/users') return { title: 'Manajemen Pengguna', subtitle: 'Kelola data petani, penyuluh, dan administrator' };
    if (pathname === '/farms') return { title: 'Lahan Pertanian', subtitle: 'Monitoring dan kelola lahan terdaftar' };
    if (pathname === '/posts') return { title: 'Komunitas & Post', subtitle: 'Kelola artikel edukasi dan forum petani' };
    if (pathname === '/seller') return { title: 'Seller Center', subtitle: 'Kelola produk, toko, dan mitra penjual pertanian' };
    return { title: 'Beranda', subtitle: 'Pantau aktivitas ekosistem PetaniTech' };
  };

  const { title, subtitle } = getPageTitle();

  return (
    <header className="h-20 bg-white/95 backdrop-blur-md border-b border-[#E2EDD9] flex items-center justify-between px-8 sticky top-0 z-10 shadow-[0_2px_12px_rgba(81,147,46,0.04)]">
      <div>
        <h2 className="text-lg font-bold text-[#1C2B18] tracking-tight">{title}</h2>
        <p className="text-xs text-[#6B8560] font-normal">{subtitle}</p>
      </div>

      <div className="flex items-center space-x-4">
        {/* Admin profile chip */}
        <div className="hidden sm:flex items-center gap-3 py-1.5 px-3 bg-[#F4F9F0] border border-[#DEECDA] rounded-full">
          <div className="w-8 h-8 rounded-full bg-[#51932E] text-white flex items-center justify-center font-bold text-xs shadow-sm">
            PT
          </div>
          <div className="text-left pr-1">
            <p className="text-xs font-semibold text-[#1F3319] leading-tight">Admin PetaniTech</p>
            <p className="text-[10px] text-[#51932E] font-medium leading-tight">Super Administrator</p>
          </div>
        </div>

        {/* Logout button */}
        <button
          onClick={handleLogout}
          className="flex items-center gap-2 px-3.5 py-2 text-xs font-semibold text-[#B92B27] bg-[#FFF2F2] hover:bg-[#FFE3E3] border border-[#FCD5D5] rounded-xl transition-all duration-200 hover:shadow-sm active:scale-95"
          title="Keluar dari sesi admin"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          <span>Keluar</span>
        </button>
      </div>
    </header>
  );
}

