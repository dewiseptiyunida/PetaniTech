'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Sidebar from '@/components/Sidebar';
import Navbar from '@/components/Navbar';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [checked, setChecked] = useState(false);

  useEffect(() => {
    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
    if (!token) {
      router.push('/login');
    } else {
      setChecked(true);
    }
  }, [router]);

  if (!checked) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-[#F8FAF6]">
        <div className="flex flex-col items-center gap-3">
          <div className="w-8 h-8 border-3 border-[#51932E] border-t-transparent rounded-full animate-spin"></div>
          <span className="text-xs text-[#6B8560] font-medium">Memverifikasi sesi administrator...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-[#F8FAF6] text-[#1C2B18]">
      <Sidebar />
      <div className="flex-1 flex flex-col ml-64 min-w-0">
        <Navbar />
        <main className="flex-1 p-8 max-w-7xl w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
