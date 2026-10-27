'use client';
import Link from 'next/link';
import Image from 'next/image';
import { usePathname } from 'next/navigation';

export default function Sidebar() {
  const pathname = usePathname();

  const navItems = [
    {
      name: 'Beranda',
      href: '/',
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
      ),
    },
    {
      name: 'Pengguna',
      href: '/users',
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
        </svg>
      ),
    },
    {
      name: 'Lahan Pertanian',
      href: '/farms',
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
        </svg>
      ),
    },
    {
      name: 'Komunitas & Post',
      href: '/posts',
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z" />
        </svg>
      ),
    },
    {
      name: 'Seller Center',
      href: '/seller',
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
        </svg>
      ),
    },
  ];

  return (
    <aside className="w-64 bg-[#1B3216] text-white h-screen flex flex-col fixed left-0 top-0 border-r border-[#2C4A24] z-20 shadow-xl">
      {/* Brand Header */}
      <div className="h-20 flex items-center px-5 border-b border-[#2C4A24]/70 bg-[#172B13]">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 rounded-xl bg-white/10 backdrop-blur-sm p-1.5 flex items-center justify-center border border-white/20 shadow-inner">
            <Image
              src="/logo.png"
              alt="PetaniTech Logo"
              width={34}
              height={34}
              className="object-contain"
              priority
            />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <span className="font-bold text-lg tracking-tight text-white">PetaniTech</span>
            </div>
          </div>
        </div>
      </div>

      {/* Navigation Section */}
      <div className="px-4 pt-6 pb-2">
        <p className="text-[11px] font-semibold text-[#8FAF7D] uppercase tracking-wider px-3 mb-2">
          Menu Utama
        </p>
      </div>
      <nav className="flex-1 px-3 space-y-1.5 overflow-y-auto">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3.5 py-3 rounded-xl font-medium text-sm transition-all duration-200 group ${isActive
                  ? 'bg-[#51932E] text-white shadow-lg shadow-[#51932E]/30 font-semibold translate-x-1'
                  : 'text-[#D0E2C8] hover:text-white hover:bg-[#284820]'
                }`}
            >
              <span
                className={`transition-colors ${isActive ? 'text-white' : 'text-[#7DB360] group-hover:text-white'
                  }`}
              >
                {item.icon}
              </span>
              <span>{item.name}</span>
              {isActive && (
                <span className="ml-auto w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
              )}
            </Link>
          );
        })}
      </nav>

      {/* Footer System Status */}
      <div className="p-4 border-t border-[#2C4A24]/70 bg-[#162A12]">
        <div className="p-3 rounded-xl bg-[#213C1B] border border-[#2F5326] flex items-center justify-between">
          <div className="flex items-center space-x-2.5">
            <span className="relative flex h-2.5 w-2.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#7DB360] opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-[#51932E]"></span>
            </span>
            <div>
              <p className="text-xs font-semibold text-white">Sistem Aktif</p>
              <p className="text-[10px] text-[#8FAF7D]">Sinkron Mobile App</p>
            </div>
          </div>
          <span className="text-[10px] font-mono text-[#7DB360] bg-[#172B13] px-2 py-0.5 rounded border border-[#2C4A24]">
            v1.0
          </span>
        </div>
      </div>
    </aside>
  );
}

