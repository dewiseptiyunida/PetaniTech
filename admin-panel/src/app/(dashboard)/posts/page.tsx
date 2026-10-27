'use client';
import { useEffect, useState } from 'react';
import api from '@/lib/api';

interface User {
  id?: string;
  first_name?: string;
  last_name?: string;
  email?: string;
  avatar?: string;
}

interface ImageModel {
  id: string;
  storage: string;
  title: string;
  type: string;
}

interface Post {
  id: string;
  title: string;
  content: string;
  status: string;
  sort: number;
  image_url?: string;
  image?: ImageModel;
  date_created: string;
  date_updated?: string;
  user_created?: User;
  user_updated?: User;
}

// Preset gambar bertema pertanian untuk kemudahan admin
const IMAGE_PRESETS = [
  {
    label: '🌾 Padi & Sawah',
    url: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80',
  },
  {
    label: '🥬 Sayuran Segar',
    url: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80',
  },
  {
    label: '🌽 Kebun Jagung',
    url: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&w=800&q=80',
  },
  {
    label: '🚜 Modern Farming',
    url: 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=800&q=80',
  },
];

export default function PostsPage() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'published' | 'draft'>('all');

  // Modal & Form states
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [editingId, setEditingId] = useState<string | null>(null);

  const defaultForm = {
    title: '',
    content: '',
    status: 'published',
    sort: 0,
    image_url: '',
  };
  const [formData, setFormData] = useState(defaultForm);

  const fetchPosts = async () => {
    setIsLoading(true);
    try {
      const response = await api.get('/posts/');
      // Mendukung respons dalam format { data: [...] } maupun array langsung [...]
      const data = Array.isArray(response.data)
        ? response.data
        : response.data?.data || [];
      setPosts(data);
    } catch (err: any) {
      setError(
        err.response?.data?.error ||
          'Gagal mengambil data artikel. Pastikan Anda sudah login dan backend aktif.'
      );
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchPosts();
  }, []);

  const handleOpenAdd = () => {
    setEditingId(null);
    setFormData(defaultForm);
    setSubmitError('');
    setIsModalOpen(true);
  };

  const handleOpenEdit = (post: Post) => {
    setEditingId(post.id);
    const existingImage = post.image_url || post.image?.id || '';
    setFormData({
      title: post.title || '',
      content: post.content || '',
      status: post.status || 'published',
      sort: post.sort ?? 0,
      image_url: existingImage,
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
        title: formData.title.trim(),
        content: formData.content.trim(),
        status: formData.status,
        sort: Number(formData.sort) || 0,
        image_url: formData.image_url.trim(),
      };

      if (editingId) {
        await api.put(`/posts/${editingId}`, payload);
      } else {
        await api.post('/posts/', payload);
      }

      setIsModalOpen(false);
      setFormData(defaultForm);
      setEditingId(null);
      fetchPosts();
    } catch (err: any) {
      setSubmitError(
        err.response?.data?.error ||
          err.response?.data?.message ||
          'Gagal menyimpan artikel. Silakan cek data kembali.'
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string, title: string) => {
    if (window.confirm(`Yakin ingin menghapus artikel "${title}"?`)) {
      try {
        await api.delete(`/posts/${id}`);
        fetchPosts();
      } catch (err: any) {
        alert(
          'Gagal menghapus artikel: ' +
            (err.response?.data?.error || 'Terjadi kesalahan sistem')
        );
      }
    }
  };

  // Helper untuk mendapatkan link gambar tampilan
  const getThumbnailSrc = (post: Post) => {
    const raw = post.image_url || post.image?.id;
    if (!raw) return 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=150&q=80';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return `http://localhost:8080/api/v1/assets/${raw}`;
  };

  // Filter hasil pencarian dan tab status
  const filteredPosts = posts.filter((p) => {
    const matchSearch =
      p.title?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.content?.toLowerCase().includes(searchQuery.toLowerCase());
    const matchStatus =
      statusFilter === 'all' || p.status?.toLowerCase() === statusFilter;
    return matchSearch && matchStatus;
  });

  return (
    <div className="space-y-6">
      {/* HEADER & ACTION BUTTON */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-[#1C2B18] tracking-tight">
            Komunitas & Post Artikel
          </h1>
          <p className="text-xs text-[#6B8560] mt-1">
            Kelola konten artikel dan tips budidaya pertanian yang tampil di aplikasi mobile PetaniTech.
          </p>
        </div>
        <button
          onClick={handleOpenAdd}
          className="inline-flex items-center justify-center gap-2 bg-[#51932E] hover:bg-[#437D26] text-white px-5 py-2.5 rounded-xl font-semibold text-xs transition-all shadow-sm hover:shadow-md hover:shadow-[#51932E]/20 active:scale-95"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
          </svg>
          Tambah Artikel Baru
        </button>
      </div>

      {error && (
        <div className="p-4 bg-red-50 text-red-700 rounded-2xl border border-red-200 text-sm font-medium flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <svg className="w-5 h-5 text-red-500 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{error}</span>
          </div>
          <button onClick={() => setError('')} className="text-red-400 hover:text-red-600 text-lg">&times;</button>
        </div>
      )}

      {/* FILTER & SEARCH BAR */}
      <div className="bg-white p-4 rounded-2xl border border-[#E2EDD9] shadow-sm flex flex-col md:flex-row gap-4 items-center justify-between">
        {/* Search Input */}
        <div className="relative w-full md:w-96">
          <svg
            className="w-4 h-4 text-[#7DB360] absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input
            type="text"
            placeholder="Cari artikel berdasarkan judul atau konten..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] focus:bg-white focus:border-[#51932E] focus:ring-2 focus:ring-[#51932E]/20 outline-none text-xs text-[#1C2B18] placeholder-[#9CB194] transition"
          />
        </div>

        {/* Status Filter Tabs */}
        <div className="flex gap-2 w-full md:w-auto">
          {(['all', 'published', 'draft'] as const).map((tab) => {
            const isActive = statusFilter === tab;
            return (
              <button
                key={tab}
                onClick={() => setStatusFilter(tab)}
                className={`px-3.5 py-2 rounded-xl text-xs font-semibold uppercase tracking-wider transition-all duration-200 ${
                  isActive
                    ? 'bg-[#51932E] text-white shadow-sm shadow-[#51932E]/30'
                    : 'bg-[#F2F7EF] text-[#536E4C] hover:bg-[#E5EFE1]'
                }`}
              >
                {tab === 'all' ? 'Semua' : tab === 'published' ? 'Published' : 'Draft'}
              </button>
            );
          })}
        </div>
      </div>

      {/* MODAL FORM TAMBAH / EDIT */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-[#162711]/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 overflow-y-auto">
          <div className="bg-white rounded-[24px] shadow-2xl w-full max-w-2xl overflow-hidden border border-[#E2EDD9] my-8 animate-in fade-in zoom-in duration-200">
            <div className="px-6 py-5 bg-gradient-to-r from-[#1B3216] to-[#2E5224] text-white flex justify-between items-center">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-sm">
                  📝
                </div>
                <div>
                  <h2 className="text-base font-bold text-white">
                    {editingId ? 'Edit Artikel Pertanian' : 'Tambah Artikel Baru'}
                  </h2>
                  <p className="text-[11px] text-[#C2DEC0]">
                    Konten disinkronkan langsung ke aplikasi mobile PetaniTech
                  </p>
                </div>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center text-lg leading-none transition-colors"
              >
                &times;
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 sm:p-7 space-y-5">
              {submitError && (
                <div className="p-3 bg-red-50 text-red-700 text-xs rounded-xl border border-red-200 font-medium">
                  {submitError}
                </div>
              )}

              {/* Judul Artikel */}
              <div>
                <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                  Judul Artikel <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  className="w-full px-4 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] focus:bg-white focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] outline-none text-[#1C2B18] text-sm placeholder-[#9CB194] transition"
                  placeholder="Contoh: Tips Menghadapi Hama Wereng pada Musim Hujan"
                />
              </div>

              {/* URL Gambar Artikel + Preset & Live Preview */}
              <div>
                <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                  URL Gambar Banner Artikel
                </label>
                <input
                  type="url"
                  value={formData.image_url}
                  onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                  className="w-full px-4 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] focus:bg-white focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] outline-none text-[#1C2B18] text-sm placeholder-[#9CB194] transition"
                  placeholder="https://images.unsplash.com/... (atau pilih preset di bawah)"
                />

                {/* Preset Cepat */}
                <div className="mt-2.5 flex flex-wrap gap-2 items-center">
                  <span className="text-[11px] text-[#6B8560] font-semibold">Preset Cepat:</span>
                  {IMAGE_PRESETS.map((preset) => (
                    <button
                      type="button"
                      key={preset.label}
                      onClick={() => setFormData({ ...formData, image_url: preset.url })}
                      className="px-2.5 py-1 text-[11px] font-medium bg-[#F2F7EF] hover:bg-[#E5EFE1] text-[#355226] rounded-lg border border-[#D5E8CE] transition"
                    >
                      {preset.label}
                    </button>
                  ))}
                </div>

                {/* Live Preview Gambar */}
                {formData.image_url && (
                  <div className="mt-3 p-3 bg-[#F4F9F0] rounded-xl border border-[#DEECDA] flex items-center gap-3">
                    <img
                      src={formData.image_url}
                      alt="Preview"
                      className="w-20 h-14 object-cover rounded-lg border border-[#D5E4CE] shadow-xs"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src =
                          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=150&q=80';
                      }}
                    />
                    <div className="text-xs text-[#4A6D3F]">
                      <span className="font-semibold text-[#2D661B] block">Preview Banner Aktif</span>
                      Gambar ini akan tampil sebagai banner artikel di Mobile App PetaniTech.
                    </div>
                  </div>
                )}
              </div>

              {/* Baris Status & Urutan */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                    Status Publikasi
                  </label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                    className="w-full px-4 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] focus:bg-white focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] outline-none text-[#1C2B18] text-sm transition"
                  >
                    <option value="published">Published (Tampil di Mobile App)</option>
                    <option value="draft">Draft (Simpan Sementara)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                    Urutan Prioritas (Sort)
                  </label>
                  <input
                    type="number"
                    value={formData.sort}
                    onChange={(e) => setFormData({ ...formData, sort: parseInt(e.target.value) || 0 })}
                    className="w-full px-4 py-2.5 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] focus:bg-white focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] outline-none text-[#1C2B18] text-sm transition"
                    placeholder="0"
                  />
                  <span className="text-[11px] text-[#7A986F] mt-1 block">
                    Nilai lebih kecil tampil lebih awal (default: 0).
                  </span>
                </div>
              </div>

              {/* Konten Artikel */}
              <div>
                <label className="block text-xs font-semibold text-[#2D4524] mb-1.5 uppercase tracking-wide">
                  Isi Konten Artikel <span className="text-red-500">*</span>
                </label>
                <textarea
                  required
                  rows={6}
                  value={formData.content}
                  onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                  className="w-full px-4 py-3 rounded-xl border border-[#D5E4CE] bg-[#F9FCF7] focus:bg-white focus:ring-2 focus:ring-[#51932E] focus:border-[#51932E] outline-none text-[#1C2B18] text-sm resize-y leading-relaxed transition"
                  placeholder="Tuliskan isi artikel dan tips pertanian secara lengkap di sini..."
                />
              </div>

              {/* Action Buttons */}
              <div className="pt-4 border-t border-[#EDF4E9] flex gap-3 justify-end items-center">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-5 py-2.5 text-xs font-semibold text-[#536E4C] bg-[#F2F7EF] hover:bg-[#E5EFE1] rounded-xl transition"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className={`px-6 py-2.5 text-xs text-white rounded-xl font-semibold transition-all shadow-sm flex items-center justify-center min-w-[150px] ${
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
                  ) : editingId ? (
                    'Simpan Perubahan'
                  ) : (
                    'Posting Artikel'
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* TABEL DATA ARTIKEL */}
      <div className="bg-white rounded-2xl shadow-sm border border-[#E2EDD9] overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-[#F4F9F0] border-b border-[#E2EDD9] text-[#2C4A22] text-xs uppercase tracking-wider font-semibold">
                <th className="p-4 w-16 text-center">Banner</th>
                <th className="p-4">Judul & Konten</th>
                <th className="p-4">Penulis</th>
                <th className="p-4 text-center">Status</th>
                <th className="p-4 text-center">Sort</th>
                <th className="p-4">Tanggal</th>
                <th className="p-4 text-center w-36">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#EDF5E8] text-sm">
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="p-12 text-center text-[#6B8560]">
                    <div className="flex flex-col items-center justify-center gap-3">
                      <div className="w-7 h-7 border-3 border-[#51932E] border-t-transparent rounded-full animate-spin"></div>
                      <span className="text-xs font-medium">Memuat data artikel PetaniTech...</span>
                    </div>
                  </td>
                </tr>
              ) : filteredPosts.length === 0 ? (
                <tr>
                  <td colSpan={7} className="p-12 text-center text-[#6B8560]">
                    <div className="flex flex-col items-center justify-center gap-2">
                      <p className="font-medium text-sm">Belum ada artikel yang cocok.</p>
                      <p className="text-xs text-[#8FAF7D]">Klik "Tambah Artikel Baru" untuk membuat postingan.</p>
                    </div>
                  </td>
                </tr>
              ) : (
                filteredPosts.map((post) => {
                  const isPublished = post.status === 'published' || post.status === 'aktif';

                  return (
                    <tr key={post.id} className="hover:bg-[#F9FCF7] transition-colors">
                      {/* Thumbnail */}
                      <td className="p-4 text-center">
                        <img
                          src={getThumbnailSrc(post)}
                          alt={post.title}
                          className="w-12 h-12 rounded-xl object-cover border border-[#D5E4CE] mx-auto shadow-2xs"
                          onError={(e) => {
                            (e.target as HTMLImageElement).src =
                              'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=150&q=80';
                          }}
                        />
                      </td>

                      {/* Judul & Cuplikan Konten */}
                      <td className="p-4 max-w-xs md:max-w-md">
                        <div className="font-semibold text-[#1C2B18] line-clamp-1">{post.title}</div>
                        <div className="text-xs text-[#6B8560] line-clamp-1 mt-0.5">{post.content}</div>
                      </td>

                      {/* Penulis */}
                      <td className="p-4 text-[#4B6B42] whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          <div className="w-7 h-7 rounded-lg bg-[#EBF5E5] text-[#355226] border border-[#D5E8CE] flex items-center justify-center font-bold text-xs uppercase">
                            {(post.user_created?.first_name || post.user_created?.email || 'A')[0]}
                          </div>
                          <span className="text-xs font-medium">
                            {post.user_created?.first_name
                              ? `${post.user_created.first_name} ${post.user_created.last_name || ''}`.trim()
                              : post.user_created?.email || 'Admin'}
                          </span>
                        </div>
                      </td>

                      {/* Status */}
                      <td className="p-4 text-center whitespace-nowrap">
                        <span
                          className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold ${
                            isPublished
                              ? 'bg-[#E5F5DC] text-[#246316] border border-[#C5E8B7]'
                              : 'bg-[#FFF6E5] text-[#9E6515] border border-[#FDE2B5]'
                          }`}
                        >
                          <span
                            className={`w-1.5 h-1.5 rounded-full ${
                              isPublished ? 'bg-[#51932E]' : 'bg-[#D88914]'
                            }`}
                          ></span>
                          {post.status === 'published' ? 'Published' : 'Draft'}
                        </span>
                      </td>

                      {/* Urutan (Sort) */}
                      <td className="p-4 text-center">
                        <span className="px-2.5 py-0.5 bg-[#F4F9F0] text-[#355226] border border-[#DEECDA] rounded-md text-xs font-mono font-medium">
                          {post.sort ?? 0}
                        </span>
                      </td>

                      {/* Tanggal */}
                      <td className="p-4 text-[#6B8560] text-xs whitespace-nowrap">
                        {post.date_created
                          ? new Date(post.date_created).toLocaleDateString('id-ID', {
                              day: 'numeric',
                              month: 'short',
                              year: 'numeric',
                            })
                          : '-'}
                      </td>

                      {/* Tombol Aksi */}
                      <td className="p-4 text-center whitespace-nowrap">
                        <div className="flex items-center justify-center gap-2">
                          <button
                            onClick={() => handleOpenEdit(post)}
                            className="px-3 py-1.5 bg-[#EBF5E5] text-[#355226] hover:bg-[#DCEDD3] rounded-lg text-xs font-semibold transition border border-[#CCE2C2]"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => handleDelete(post.id, post.title)}
                            className="px-3 py-1.5 bg-[#FFF2F2] text-[#B92B27] hover:bg-[#FFE3E3] rounded-lg text-xs font-semibold transition border border-[#FCD5D5]"
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

