'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import api from '@/lib/api';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMsg('');
    setIsLoading(true);

    try {
      const response = await api.post('/auth/login', {
        email,
        password,
      });

      const token = response.data.token;
      if (token) {
        localStorage.setItem('token', token);
        router.push('/');
      } else {
        setErrorMsg('Autentikasi gagal: Token tidak ditemukan.');
      }
    } catch (error: any) {
      if (error.response && error.response.data && error.response.data.error) {
        setErrorMsg(error.response.data.error);
      } else {
        setErrorMsg('Terjadi kesalahan pada server. Pastikan backend aktif.');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="relative min-h-screen w-full flex items-center justify-center p-4 overflow-hidden bg-[#1E3618]">
      {/* Background Image mimicking mobile-app's bg_login.png */}
      <div className="absolute inset-0 z-0">
        <Image
          src="/bg_login.png"
          alt="PetaniTech Background"
          fill
          priority
          className="object-cover object-center"
        />
        {/* Backdrop blur & gradient overlay as in mobile-app AuthScreen */}
        <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-black/25 to-[#172B13]/85 backdrop-blur-[8px]" />
      </div>

      {/* Main Container */}
      <div className="relative z-10 w-full max-w-md">
        {/* Brand Logo & Title on top (just like mobile-app header) */}
        <div className="text-center mb-6 flex flex-col items-center">
          <div className="w-20 h-20 rounded-2xl bg-white/90 backdrop-blur-md p-3.5 shadow-xl border border-white/40 mb-3 flex items-center justify-center">
            <Image
              src="/logo.png"
              alt="PetaniTech Logo"
              width={64}
              height={64}
              className="object-contain"
              priority
            />
          </div>
          <h1 className="text-2xl font-bold text-white tracking-tight drop-shadow-md">
            PetaniTech
          </h1>
          <p className="text-xs text-[#E1EED9] mt-1 font-medium bg-[#1F3A19]/60 px-3 py-1 rounded-full border border-white/10 backdrop-blur-sm">
            Portal Administrasi Pertanian Digital
          </p>
        </div>

        {/* Elevated Form Card */}
        <div className="bg-white/95 backdrop-blur-xl rounded-[24px] shadow-2xl border border-white/50 p-8 sm:p-9 transition-all">
          <div className="mb-6">
            <h2 className="text-xl font-bold text-[#1C2B18]">Masuk Administrator</h2>
            <p className="text-xs text-[#6A8160] mt-1">
              Silakan masukkan kredensial akun admin Anda untuk melanjutkan.
            </p>
          </div>

          {errorMsg && (
            <div className="mb-5 p-3.5 bg-red-50/90 border border-red-200 text-red-700 rounded-xl text-xs font-medium flex items-start gap-2.5">
              <svg className="w-4 h-4 text-red-500 mt-0.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span>{errorMsg}</span>
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                Email Akun
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-[#7DB360]">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                  </svg>
                </div>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full pl-10 pr-4 py-3 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] text-sm text-[#1C2B18] placeholder-[#9CB194] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] transition-all"
                  placeholder="admin@petanitech.com"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                Kata Sandi
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-[#7DB360]">
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full pl-10 pr-10 py-3 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] text-sm text-[#1C2B18] placeholder-[#9CB194] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] transition-all"
                  placeholder="••••••••"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3.5 flex items-center text-[#7A986F] hover:text-[#51932E]"
                >
                  {showPassword ? (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" />
                    </svg>
                  ) : (
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  )}
                </button>
              </div>
            </div>

            <div className="pt-2">
              <button
                type="submit"
                disabled={isLoading}
                className={`w-full py-3.5 px-4 rounded-xl font-semibold text-sm transition-all duration-200 shadow-md ${
                  isLoading
                    ? 'bg-[#89BF6E] text-white cursor-not-allowed'
                    : 'bg-[#51932E] hover:bg-[#437D26] text-white shadow-[#51932E]/30 hover:shadow-lg hover:shadow-[#51932E]/40 active:scale-[0.98]'
                }`}
              >
                {isLoading ? (
                  <div className="flex items-center justify-center gap-2">
                    <svg className="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span>Memverifikasi Akun...</span>
                  </div>
                ) : (
                  'Masuk ke Sistem'
                )}
              </button>
            </div>
          </form>

          {/* Footer note inside card */}
          <div className="mt-6 pt-5 border-t border-[#E8F0E4] text-center space-y-1.5">
            <p className="text-[11px] text-[#78916F]">
              Kredensial dikelola oleh sistem autentikasi PetaniTech Backend
            </p>
            <div className="text-[11px] text-[#2F571D] bg-[#EEF7EB] py-1.5 px-3 rounded-lg border border-[#D5E8CE] inline-block font-mono">
              Akun: <b>admin@petanitech.com</b> | Sandi: <b>admin123</b>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

