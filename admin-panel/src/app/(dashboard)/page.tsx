'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import api from '@/lib/api';

export default function DashboardPage() {
  const [stats, setStats] = useState({ users: 0, farms: 0, posts: 0, seller_products: 0 });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchStats = async () => {
      setIsLoading(true);
      setError('');
      try {
        // Mengambil statistik real-time dari database
        const statsRes = await api.get('/stats');
        if (statsRes.data && typeof statsRes.data.users === 'number') {
          setStats({
            users: statsRes.data.users,
            farms: statsRes.data.farms,
            posts: statsRes.data.posts,
            seller_products: statsRes.data.seller_products || 0,
          });
          setIsLoading(false);
          return;
        }
      } catch (err) {
        console.warn('Endpoint /stats fallback ke endpoint individual:', err);
      }

      try {
        // Fallback toleran jika endpoint /stats belum siap
        const results = await Promise.allSettled([
          api.get('/users/'),
          api.get('/farms/'),
          api.get('/posts/'),
          api.get('/seller/products'),
        ]);

        const getCount = (result: PromiseSettledResult<any>) => {
          if (result.status !== 'fulfilled') return 0;
          const res = result.value;
          if (Array.isArray(res?.data)) return res.data.length;
          if (Array.isArray(res?.data?.data)) return res.data.data.length;
          if (Array.isArray(res?.data?.value)) return res.data.value.length;
          return 0;
        };

        setStats({
          users: getCount(results[0]),
          farms: getCount(results[1]),
          posts: getCount(results[2]),
          seller_products: getCount(results[3]),
        });
      } catch (err: any) {
        console.error('Error fetching stats:', err);
        setError('Gagal memuat statistik. Pastikan backend aktif.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchStats();
  }, []);

  return (
    <div className="space-y-8">
      {/* Welcome Banner with PetaniTech Brand Gradient */}
      <div className="relative overflow-hidden rounded-[24px] bg-gradient-to-r from-[#355226] via-[#467E28] to-[#51932E] text-white p-7 sm:p-9 shadow-lg shadow-[#51932E]/15 border border-[#64A341]/40">
        <div className="relative z-10 max-w-2xl">
          <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight">
            Selamat Datang di Admin PetaniTech
          </h1>
          <p className="text-sm text-[#D7ECD0] mt-2 font-normal leading-relaxed">
            Pusat kendali ekosistem aplikasi mobile PetaniTech dan Petani-Tech Seller Center. Pantau data pengguna, validasi lahan pertanian terdaftar, kelola artikel edukasi, dan monitor katalog produk penjual.
          </p>
          <div className="mt-5 flex flex-wrap gap-3">
            <Link
              href="/seller"
              className="px-4 py-2.5 rounded-xl bg-white text-[#355226] font-semibold text-xs hover:bg-[#F2F8ED] transition-all shadow-sm flex items-center gap-1.5"
            >
              <span>+ Kelola Seller</span>
            </Link>
            <Link
              href="/farms"
              className="px-4 py-2.5 rounded-xl bg-white/20 text-white font-semibold text-xs hover:bg-white/30 backdrop-blur-sm transition-all border border-white/30 flex items-center gap-1.5"
            >
              <span>+ Kelola Lahan</span>
            </Link>
            <Link
              href="/posts"
              className="px-4 py-2.5 rounded-xl bg-white/20 text-white font-semibold text-xs hover:bg-white/30 backdrop-blur-sm transition-all border border-white/30 flex items-center gap-1.5"
            >
              <span>+ Publikasi Artikel</span>
            </Link>
          </div>
        </div>
        {/* Soft decorative leaf circles in background */}
        <div className="absolute right-0 top-0 -mr-10 -mt-10 w-64 h-64 rounded-full bg-white/10 blur-2xl pointer-events-none" />
        <div className="absolute right-12 bottom-0 w-32 h-32 rounded-full bg-[#7DB360]/20 blur-xl pointer-events-none" />
      </div>

      {error && (
        <div className="p-4 bg-red-50 text-red-700 rounded-2xl border border-red-200 text-sm font-medium flex items-center gap-3">
          <svg className="w-5 h-5 text-red-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{error}</span>
        </div>
      )}

      {/* Main Metrics Section */}
      <div>
        <h2 className="text-base font-bold text-[#1C2B18] mb-4 flex items-center gap-2">
          <span>Statistik Ekosistem</span>
          <span className="text-xs font-normal text-[#6B8560]">Real-time dari Database PostgreSQL</span>
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Card: Total Pengguna */}
          <Link
            href="/users"
            className="bg-white p-6 rounded-[20px] shadow-sm border border-[#E2EDD9] relative overflow-hidden group hover:shadow-md hover:border-[#51932E]/50 transition-all duration-200"
          >
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-bold uppercase tracking-wider text-[#3C642D]">
                Total Pengguna
              </span>
              <div className="w-10 h-10 rounded-xl bg-[#EDF6EB] text-[#51932E] flex items-center justify-center group-hover:scale-110 group-hover:bg-[#51932E] group-hover:text-white transition-all">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
              </div>
            </div>
            {isLoading ? (
              <div className="animate-pulse h-10 w-20 bg-[#E8F2E3] rounded-lg my-1"></div>
            ) : (
              <p className="text-4xl font-extrabold text-[#1C2B18] tracking-tight">{stats.users}</p>
            )}
            <p className="text-[#6B8560] text-xs mt-3 flex items-center gap-1 font-medium">
              <span>Akun terdaftar di Mobile App</span>
              <span className="text-[#51932E] group-hover:translate-x-1 transition-transform">→</span>
            </p>
          </Link>

          {/* Card: Seller Center & Produk */}
          <Link
            href="/seller"
            className="bg-white p-6 rounded-[20px] shadow-sm border border-[#E2EDD9] relative overflow-hidden group hover:shadow-md hover:border-[#51932E]/50 transition-all duration-200"
          >
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-bold uppercase tracking-wider text-[#2D6A4F]">
                Seller & Produk
              </span>
              <div className="w-10 h-10 rounded-xl bg-[#E8F5EE] text-[#2D6A4F] flex items-center justify-center group-hover:scale-110 group-hover:bg-[#2D6A4F] group-hover:text-white transition-all">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
                </svg>
              </div>
            </div>
            {isLoading ? (
              <div className="animate-pulse h-10 w-20 bg-[#E8F5EE] rounded-lg my-1"></div>
            ) : (
              <p className="text-4xl font-extrabold text-[#1C2B18] tracking-tight">{stats.seller_products}</p>
            )}
            <p className="text-[#6B8560] text-xs mt-3 flex items-center gap-1 font-medium">
              <span>Produk mitra seller aktif</span>
              <span className="text-[#2D6A4F] group-hover:translate-x-1 transition-transform">→</span>
            </p>
          </Link>

          {/* Card: Total Lahan */}
          <Link
            href="/farms"
            className="bg-white p-6 rounded-[20px] shadow-sm border border-[#E2EDD9] relative overflow-hidden group hover:shadow-md hover:border-[#51932E]/50 transition-all duration-200"
          >
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-bold uppercase tracking-wider text-[#355226]">
                Lahan Pertanian
              </span>
              <div className="w-10 h-10 rounded-xl bg-[#E8F4E2] text-[#355226] flex items-center justify-center group-hover:scale-110 group-hover:bg-[#355226] group-hover:text-white transition-all">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                </svg>
              </div>
            </div>
            {isLoading ? (
              <div className="animate-pulse h-10 w-20 bg-[#E8F2E3] rounded-lg my-1"></div>
            ) : (
              <p className="text-4xl font-extrabold text-[#1C2B18] tracking-tight">{stats.farms}</p>
            )}
            <p className="text-[#6B8560] text-xs mt-3 flex items-center gap-1 font-medium">
              <span>Lahan aktif dipantau</span>
              <span className="text-[#355226] group-hover:translate-x-1 transition-transform">→</span>
            </p>
          </Link>

          {/* Card: Total Artikel */}
          <Link
            href="/posts"
            className="bg-white p-6 rounded-[20px] shadow-sm border border-[#E2EDD9] relative overflow-hidden group hover:shadow-md hover:border-[#51932E]/50 transition-all duration-200"
          >
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-bold uppercase tracking-wider text-[#A06C17]">
                Komunitas & Post
              </span>
              <div className="w-10 h-10 rounded-xl bg-[#FFF8EB] text-[#D88914] flex items-center justify-center group-hover:scale-110 group-hover:bg-[#D88914] group-hover:text-white transition-all">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
                </svg>
              </div>
            </div>
            {isLoading ? (
              <div className="animate-pulse h-10 w-20 bg-[#FFF3DC] rounded-lg my-1"></div>
            ) : (
              <p className="text-4xl font-extrabold text-[#1C2B18] tracking-tight">{stats.posts}</p>
            )}
            <p className="text-[#6B8560] text-xs mt-3 flex items-center gap-1 font-medium">
              <span>Artikel & tips budidaya</span>
              <span className="text-[#D88914] group-hover:translate-x-1 transition-transform">→</span>
            </p>
          </Link>
        </div>
      </div>
    </div>
  );
}
