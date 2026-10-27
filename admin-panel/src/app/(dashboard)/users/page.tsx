'use client';
import { useEffect, useState } from 'react';
import api from '@/lib/api';

interface User {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  role: string;
  status: string;
  created_at: string;
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await api.get('/users/');
        const raw = response.data;
        const list = Array.isArray(raw)
          ? raw
          : Array.isArray(raw?.data)
          ? raw.data
          : Array.isArray(raw?.value)
          ? raw.value
          : [];
        setUsers(list);
      } catch (err: any) {
        setError(err.response?.data?.error || 'Gagal mengambil data pengguna. Pastikan Anda sudah login.');
      } finally {
        setIsLoading(false);
      }
    };
    fetchUsers();
  }, []);

  const safeUsers = Array.isArray(users) ? users : [];
  const filteredUsers = safeUsers.filter((u) => {
    const fullName = `${u.first_name || ''} ${u.last_name || ''}`.toLowerCase();
    const email = (u.email || '').toLowerCase();
    const query = searchQuery.toLowerCase();
    return fullName.includes(query) || email.includes(query);
  });

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-[#1C2B18] tracking-tight">Daftar Pengguna</h1>
          <p className="text-xs text-[#6B8560] mt-1">
            Data petani dan staf pengelola yang terdaftar dalam ekosistem PetaniTech
          </p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs font-semibold px-3 py-1.5 rounded-full bg-[#EBF5E5] text-[#355226] border border-[#D5E8CE]">
            Total: {users.length} Akun
          </span>
        </div>
      </div>

      {error && (
        <div className="p-4 bg-red-50 text-red-700 rounded-2xl border border-red-200 text-sm font-medium flex items-center gap-3">
          <svg className="w-5 h-5 text-red-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{error}</span>
        </div>
      )}

      {/* Search Bar */}
      <div className="bg-white p-4 rounded-2xl border border-[#E2EDD9] shadow-sm flex items-center gap-3">
        <div className="text-[#7DB360]">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        </div>
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Cari berdasarkan nama pengguna atau email..."
          className="w-full text-sm text-[#1C2B18] bg-transparent outline-none placeholder-[#9CB194]"
        />
        {searchQuery && (
          <button
            onClick={() => setSearchQuery('')}
            className="text-xs text-[#7A986F] hover:text-[#1C2B18] px-2 py-1 rounded bg-[#F4F9F0]"
          >
            Reset
          </button>
        )}
      </div>

      {/* Users Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-[#E2EDD9] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-[#F4F9F0] border-b border-[#E2EDD9] text-[#2C4A22] text-xs font-semibold uppercase tracking-wider">
                <th className="p-4">Pengguna</th>
                <th className="p-4">Email</th>
                <th className="p-4">Role</th>
                <th className="p-4">Status</th>
                <th className="p-4">Tanggal Bergabung</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#EDF5E8]">
              {isLoading ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center text-[#6B8560]">
                    <div className="flex flex-col items-center justify-center space-y-3">
                      <div className="w-7 h-7 border-3 border-[#51932E] border-t-transparent rounded-full animate-spin"></div>
                      <span className="text-xs font-medium">Memuat data pengguna PetaniTech...</span>
                    </div>
                  </td>
                </tr>
              ) : filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center text-[#6B8560]">
                    <p className="text-sm font-medium">Tidak ada data pengguna yang sesuai.</p>
                    <p className="text-xs text-[#8FAF7D] mt-1">Coba kata kunci pencarian lain.</p>
                  </td>
                </tr>
              ) : (
                filteredUsers.map((user) => {
                  const initials = `${(user.first_name || 'U')[0] || ''}${(user.last_name || '')[0] || ''}`.toUpperCase();
                  const isAdmin = user.role?.toLowerCase() === 'admin';
                  const isActive = user.status?.toLowerCase() === 'active';

                  return (
                    <tr key={user.id} className="hover:bg-[#F9FCF7] transition-colors">
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <div className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs shadow-sm ${
                            isAdmin
                              ? 'bg-[#51932E] text-white'
                              : 'bg-[#EBF5E5] text-[#355226] border border-[#D5E8CE]'
                          }`}>
                            {initials || 'PT'}
                          </div>
                          <div>
                            <p className="text-sm font-semibold text-[#1C2B18]">
                              {user.first_name} {user.last_name}
                            </p>
                            <p className="text-[11px] text-[#7A986F] font-mono">ID: {user.id.slice(0, 8)}</p>
                          </div>
                        </div>
                      </td>
                      <td className="p-4 text-xs font-medium text-[#4B6B42]">{user.email}</td>
                      <td className="p-4">
                        <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold ${
                          isAdmin
                            ? 'bg-[#E5F3DD] text-[#2C6219] border border-[#CDE5C2]'
                            : 'bg-[#F2F7EF] text-[#4A6D3F] border border-[#DEECDA]'
                        }`}>
                          <span className={`w-1.5 h-1.5 rounded-full ${isAdmin ? 'bg-[#51932E]' : 'bg-[#7DB360]'}`}></span>
                          {user.role || 'petani'}
                        </span>
                      </td>
                      <td className="p-4">
                        <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold ${
                          isActive
                            ? 'bg-[#E5F5DC] text-[#246316] border border-[#C5E8B7]'
                            : 'bg-red-50 text-red-700 border border-red-200'
                        }`}>
                          <span className={`w-1.5 h-1.5 rounded-full ${isActive ? 'bg-[#51932E]' : 'bg-red-500'}`}></span>
                          {user.status || 'inactive'}
                        </span>
                      </td>
                      <td className="p-4 text-xs text-[#6B8560]">
                        {user.created_at ? new Date(user.created_at).toLocaleDateString('id-ID', {
                          day: 'numeric',
                          month: 'long',
                          year: 'numeric'
                        }) : '-'}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

