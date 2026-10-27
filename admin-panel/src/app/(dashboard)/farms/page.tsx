'use client';
import { useEffect, useState } from 'react';
import api from '@/lib/api';

interface Farm {
  id: string;
  name: string;
  area_size: string;
  area_unit: string;
  ownership_type: string;
  date_created: string;
}

export default function FarmsPage() {
  const [farms, setFarms] = useState<Farm[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  // Modal & Form states
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);

  const defaultForm = { name: '', area_size: '', area_unit: 'Hektar', ownership_type: 'pribadi' };
  const [formData, setFormData] = useState(defaultForm);

  const fetchFarms = async () => {
    setIsLoading(true);
    try {
      const response = await api.get('/farms/');
      const raw = response.data;
      const list = Array.isArray(raw)
        ? raw
        : Array.isArray(raw?.data)
        ? raw.data
        : [];
      setFarms(list);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Gagal mengambil data lahan. Pastikan Anda sudah login.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchFarms();
  }, []);

  const handleOpenAdd = () => {
    setEditingId(null);
    setFormData(defaultForm);
    setSubmitError('');
    setIsModalOpen(true);
  };

  const handleOpenEdit = (farm: Farm) => {
    setEditingId(farm.id);
    setFormData({
      name: farm.name,
      area_size: farm.area_size,
      area_unit: farm.area_unit || 'Hektar',
      ownership_type: farm.ownership_type || 'pribadi',
    });
    setSubmitError('');
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitError('');

    try {
      const payload = {
        ...formData,
        soil_type: 1, 
        status: 'published' // Sinkron dengan mobile-app agar langsung tampil
      };

      if (editingId) {
        await api.put(`/farms/${editingId}`, payload);
      } else {
        await api.post('/farms/', payload);
      }
      
      setIsModalOpen(false);
      setFormData(defaultForm);
      setEditingId(null);
      fetchFarms();
    } catch (err: any) {
      setSubmitError(err.response?.data?.error || 'Gagal menyimpan data.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (window.confirm('Yakin ingin menghapus data lahan ini dari sistem PetaniTech?')) {
      try {
        await api.delete(`/farms/${id}`);
        fetchFarms();
      } catch (err: any) {
        alert('Gagal menghapus data: ' + (err.response?.data?.error || 'Unknown error'));
      }
    }
  };

  const filteredFarms = farms.filter((f) =>
    (f.name || '').toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-[#1C2B18] tracking-tight">Lahan Pertanian</h1>
          <p className="text-xs text-[#6B8560] mt-1">
            Data lahan terdaftar yang dipantau melalui aplikasi mobile PetaniTech
          </p>
        </div>
        <button 
          onClick={handleOpenAdd}
          className="inline-flex items-center gap-2 bg-[#51932E] hover:bg-[#437D26] text-white px-5 py-2.5 rounded-xl font-semibold text-xs transition-all shadow-sm hover:shadow-md hover:shadow-[#51932E]/20 active:scale-95"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          <span>Tambah Lahan Baru</span>
        </button>
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
          placeholder="Cari lahan berdasarkan nama..."
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

      {/* MODAL FORM */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-[#162711]/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-[24px] shadow-2xl w-full max-w-md overflow-hidden border border-[#E2EDD9]">
            <div className="px-6 py-5 bg-gradient-to-r from-[#1B3216] to-[#2E5224] text-white flex justify-between items-center">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-sm">
                  🌾
                </div>
                <div>
                  <h2 className="text-base font-bold text-white">
                    {editingId ? 'Edit Data Lahan' : 'Tambah Lahan Pertanian'}
                  </h2>
                  <p className="text-[11px] text-[#C2DEC0]">Ekosistem Pertanian PetaniTech</p>
                </div>
              </div>
              <button 
                onClick={() => setIsModalOpen(false)}
                className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center text-lg leading-none transition-colors"
              >
                &times;
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6">
              {submitError && (
                <div className="mb-4 p-3 bg-red-50 text-red-600 text-xs rounded-xl border border-red-200 font-medium">
                  {submitError}
                </div>
              )}

              <div className="space-y-4">
                <div>
                  <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                    Nama Lahan
                  </label>
                  <input 
                    type="text" 
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] text-sm text-[#1C2B18] placeholder-[#9CB194] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] transition-all"
                    placeholder="Contoh: Kebun Padi Subur Jaya"
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                      Luas Lahan
                    </label>
                    <input 
                      type="number" 
                      step="0.01"
                      required
                      value={formData.area_size}
                      onChange={(e) => setFormData({...formData, area_size: e.target.value})}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] text-sm text-[#1C2B18] placeholder-[#9CB194] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] transition-all"
                      placeholder="Contoh: 1.75"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                      Satuan
                    </label>
                    <select 
                      value={formData.area_unit}
                      onChange={(e) => setFormData({...formData, area_unit: e.target.value})}
                      className="w-full px-3.5 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] text-sm text-[#1C2B18] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] transition-all"
                    >
                      <option value="Hektar">Hektar</option>
                      <option value="m2">m² (Meter Persegi)</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                    Tipe Kepemilikan Lahan
                  </label>
                  <select 
                    required
                    value={formData.ownership_type}
                    onChange={(e) => setFormData({...formData, ownership_type: e.target.value})}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] text-sm text-[#1C2B18] focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] transition-all"
                  >
                    <option value="pribadi">Milik Pribadi</option>
                    <option value="sewa">Sewa Lahan</option>
                    <option value="bagi_hasil">Bagi Hasil (Kerjasama)</option>
                  </select>
                </div>
              </div>

              <div className="mt-7 flex gap-3 justify-end pt-4 border-t border-[#EDF4E9]">
                <button 
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2.5 text-xs font-semibold text-[#536E4C] bg-[#F2F7EF] hover:bg-[#E5EFE1] rounded-xl transition-colors"
                >
                  Batal
                </button>
                <button 
                  type="submit"
                  disabled={isSubmitting}
                  className={`px-5 py-2.5 text-xs text-white rounded-xl font-semibold transition-all shadow-sm flex items-center justify-center min-w-[140px] ${
                    isSubmitting 
                      ? 'bg-[#8BBF72] cursor-not-allowed' 
                      : 'bg-[#51932E] hover:bg-[#437D26] shadow-[#51932E]/30 hover:shadow-md'
                  }`}
                >
                  {isSubmitting ? (
                    <div className="flex items-center gap-2">
                      <div className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      <span>Menyimpan...</span>
                    </div>
                  ) : (
                    editingId ? 'Simpan Perubahan' : 'Tambahkan Lahan'
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* TABLE DATA */}
      <div className="bg-white rounded-2xl shadow-sm border border-[#E2EDD9] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-[#F4F9F0] border-b border-[#E2EDD9] text-[#2C4A22] text-xs font-semibold uppercase tracking-wider">
                <th className="p-4">Nama Lahan</th>
                <th className="p-4">Luas Lahan</th>
                <th className="p-4">Tipe Kepemilikan</th>
                <th className="p-4">Tanggal Dibuat</th>
                <th className="p-4 text-center w-40">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#EDF5E8]">
              {isLoading ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center text-[#6B8560]">
                    <div className="flex flex-col items-center justify-center space-y-3">
                      <div className="w-7 h-7 border-3 border-[#51932E] border-t-transparent rounded-full animate-spin"></div>
                      <span className="text-xs font-medium">Memuat data lahan pertanian...</span>
                    </div>
                  </td>
                </tr>
              ) : filteredFarms.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center text-[#6B8560]">
                    <p className="text-sm font-medium">Belum ada data lahan yang terdaftar.</p>
                    <p className="text-xs text-[#8FAF7D] mt-1">Klik tombol di atas untuk menambahkan data baru.</p>
                  </td>
                </tr>
              ) : (
                filteredFarms.map((farm) => {
                  const ownership = (farm.ownership_type || '').toLowerCase();
                  const isPribadi = ownership === 'pribadi';
                  const isSewa = ownership === 'sewa';

                  return (
                    <tr key={farm.id} className="hover:bg-[#F9FCF7] transition-colors">
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <div className="w-9 h-9 rounded-xl bg-[#EAF4E4] text-[#355226] flex items-center justify-center font-bold text-sm border border-[#D3E8CB]">
                            🌱
                          </div>
                          <div>
                            <p className="text-sm font-semibold text-[#1C2B18]">{farm.name}</p>
                            <p className="text-[11px] text-[#7A986F] font-mono">ID: {farm.id.slice(0, 8)}</p>
                          </div>
                        </div>
                      </td>
                      <td className="p-4 text-xs font-semibold text-[#2D4524]">
                        <span className="px-2.5 py-1 bg-[#F4F9F0] border border-[#DEECDA] rounded-lg">
                          {farm.area_size} {farm.area_unit || 'Hektar'}
                        </span>
                      </td>
                      <td className="p-4">
                        <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold capitalize ${
                          isPribadi
                            ? 'bg-[#E5F5DC] text-[#246316] border border-[#C5E8B7]'
                            : isSewa
                            ? 'bg-[#FFF6E5] text-[#9E6515] border border-[#FDE2B5]'
                            : 'bg-[#E7F3F6] text-[#1E6073] border border-[#CBE5EC]'
                        }`}>
                          <span className={`w-1.5 h-1.5 rounded-full ${
                            isPribadi ? 'bg-[#51932E]' : isSewa ? 'bg-[#D88914]' : 'bg-[#29829B]'
                          }`}></span>
                          {(farm.ownership_type || 'pribadi').replace('_', ' ')}
                        </span>
                      </td>
                      <td className="p-4 text-xs text-[#6B8560]">
                        {farm.date_created ? new Date(farm.date_created).toLocaleDateString('id-ID', {
                          day: 'numeric',
                          month: 'long',
                          year: 'numeric'
                        }) : '-'}
                      </td>
                      <td className="p-4">
                        <div className="flex gap-2 justify-center">
                          <button 
                            onClick={() => handleOpenEdit(farm)}
                            className="px-3 py-1.5 bg-[#EBF5E5] text-[#355226] hover:bg-[#DCEDD3] rounded-lg text-xs font-semibold transition-colors border border-[#CCE2C2]"
                          >
                            Edit
                          </button>
                          <button 
                            onClick={() => handleDelete(farm.id)}
                            className="px-3 py-1.5 bg-[#FFF2F2] text-[#B92B27] hover:bg-[#FFE3E3] rounded-lg text-xs font-semibold transition-colors border border-[#FCD5D5]"
                          >
                            Hapus
                          </button>
                        </div>
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

