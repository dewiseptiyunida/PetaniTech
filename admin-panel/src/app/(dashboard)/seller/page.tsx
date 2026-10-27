'use client';
import { useEffect, useState, useMemo } from 'react';
import api from '@/lib/api';

// ── Types ───────────────────────────────────────────────────────────────────

interface Seller {
  id: string;
  name: string;
  email: string;
  phone: string;
  role: string;
  storeName: string;
  storeId: string;
  status: string;
  avatar: string;
  storeAddress: string;
  joinedDate: string;
  rating: number;
  totalReview: number;
  balance: number;
  totalProducts?: number;
  totalOrders?: number;
}

interface SellerProduct {
  id: string;
  name: string;
  seller_name?: string;
  store_name?: string;
  seller_contact?: string;
  location?: string;
  category: string;
  subcategory?: string;
  price: number;
  original_price?: number;
  stock: number;
  min_stock_alert: number;
  unit: string;
  status: string;
  image?: string;
  description?: string;
  sku?: string;
  sold_count?: number;
  rating?: number;
  date_created?: string;
}

interface OrderItem {
  productId: string;
  productName: string;
  category: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
  productImage: string;
  unit: string;
}

interface SellerOrder {
  id: string;
  orderNumber: string;
  sellerId?: string;
  storeName?: string;
  buyerName: string;
  buyerPhone: string;
  buyerAddress: string;
  status: string;
  totalAmount: number;
  shippingFee: number;
  courier: string;
  trackingNumber?: string;
  paymentMethod: string;
  paymentStatus?: string;
  note?: string;
  items: OrderItem[];
  createdAt: string;
}

interface SellerStats {
  totalSellers: number;
  totalProducts: number;
  totalOrders: number;
  totalRevenue: number;
}

const PRESET_IMAGES = [
  { label: '🌿 Bionava', url: '/products/bionava.jpg' },
  { label: '⛏️ Cangkul', url: '/products/cangkul.jpg' },
  { label: '🌾 Pupuk NPK', url: '/products/pupukNpk.jpg' },
  { label: '🚜 Sprayer', url: '/products/sprayer.jpg' },
  { label: '🧪 Prosil', url: '/products/prosil.jpg' },
  { label: '🌱 Grao Verde', url: '/products/graoVerde.jpg' },
];

function getProductImageUrl(image?: string, name?: string, category?: string): string {
  const img = (image || '').toLowerCase();
  const n = (name || '').toLowerCase();

  if (img.includes('bionava') || n.includes('bionava')) return '/products/bionava.jpg';
  if (img.includes('cangkul2') || n.includes('cangkul 2') || n.includes('cangkul2')) return '/products/cangkul2.jpg';
  if (img.includes('cangkul') || n.includes('cangkul')) return '/products/cangkul.jpg';
  if (img.includes('grao') || img.includes('verde') || n.includes('grao')) return '/products/graoVerde.jpg';
  if (img.includes('pintinhos') || n.includes('pintinhos')) return '/products/pintinhos.jpg';
  if (img.includes('prosil') || n.includes('prosil')) return '/products/prosil.jpg';
  if (img.includes('npk') || n.includes('pupuk npk') || n.includes('npk')) return '/products/pupukNpk.jpg';
  if (img.includes('skop') || n.includes('skop') || n.includes('sekop')) return '/products/skop.jpg';
  if (img.includes('sprayer') || n.includes('sprayer')) return '/products/sprayer.jpg';

  if (image && (image.startsWith('http://') || image.startsWith('https://') || image.startsWith('data:') || image.startsWith('/'))) {
    return image;
  }

  if (category === 'Pupuk') {
    return 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=500&auto=format&fit=crop&q=80';
  } else if (category === 'Pestisida') {
    return 'https://images.unsplash.com/photo-1592417817098-8f3d6910985c?w=500&auto=format&fit=crop&q=80';
  } else if (category === 'Benih') {
    return 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=500&auto=format&fit=crop&q=80';
  }

  return 'https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?w=500&auto=format&fit=crop&q=80';
}

export default function SellerPage() {
  const [activeTab, setActiveTab] = useState<'stores' | 'products' | 'orders'>('stores');
  const [stats, setStats] = useState<SellerStats>({ totalSellers: 0, totalProducts: 0, totalOrders: 0, totalRevenue: 0 });

  // ── Stores State ──────────────────────────────────────────────────────────
  const [sellers, setSellers] = useState<Seller[]>([]);
  const [isLoadingSellers, setIsLoadingSellers] = useState(true);
  const [searchSeller, setSearchSeller] = useState('');
  const [statusSellerFilter, setStatusSellerFilter] = useState('all');

  // ── Products State ────────────────────────────────────────────────────────
  const [products, setProducts] = useState<SellerProduct[]>([]);
  const [isLoadingProducts, setIsLoadingProducts] = useState(true);
  const [searchProduct, setSearchProduct] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('Semua');
  const [statusProductFilter, setStatusProductFilter] = useState('all');

  // Product Modal State
  const [isProductModalOpen, setIsProductModalOpen] = useState(false);
  const [isProductSubmitting, setIsProductSubmitting] = useState(false);
  const [productSubmitError, setProductSubmitError] = useState('');
  const [editingProductId, setEditingProductId] = useState<string | null>(null);

  const defaultProductForm = {
    name: '',
    seller_name: 'Fahda Febriya',
    store_name: 'Toko Tani Makmur Fahda',
    seller_contact: '0812-3456-7890',
    location: 'Indramayu, Jawa Barat',
    category: 'Pupuk',
    subcategory: 'Pupuk Organik',
    price: '',
    original_price: '',
    stock: '',
    min_stock_alert: '10',
    unit: 'Botol (1 Liter)',
    status: 'Aktif',
    image: '',
    description: '',
  };
  const [productForm, setProductForm] = useState(defaultProductForm);

  // ── Orders State ──────────────────────────────────────────────────────────
  const [orders, setOrders] = useState<SellerOrder[]>([]);
  const [isLoadingOrders, setIsLoadingOrders] = useState(true);
  const [searchOrder, setSearchOrder] = useState('');
  const [statusOrderFilter, setStatusOrderFilter] = useState('all');

  // Order Status Modal
  const [selectedOrder, setSelectedOrder] = useState<SellerOrder | null>(null);
  const [newOrderStatus, setNewOrderStatus] = useState('');
  const [newTrackingNo, setNewTrackingNo] = useState('');
  const [isUpdatingOrder, setIsUpdatingOrder] = useState(false);
  const [syncingOrderId, setSyncingOrderId] = useState<string | null>(null);

  // ── Fetch Functions ───────────────────────────────────────────────────────

  const fetchStats = async () => {
    try {
      const res = await api.get('/admin/seller-stats');
      setStats(res.data);
    } catch {
      // ignore
    }
  };

  const fetchSellers = async () => {
    setIsLoadingSellers(true);
    try {
      const res = await api.get('/admin/sellers');
      const list = res.data?.data || res.data || [];
      setSellers(Array.isArray(list) ? list : []);
    } catch (err) {
      console.warn('Gagal memuat sellers:', err);
    } finally {
      setIsLoadingSellers(false);
    }
  };

  const fetchProducts = async () => {
    setIsLoadingProducts(true);
    try {
      const res = await api.get('/seller/products');
      const raw = res.data;
      const list = Array.isArray(raw) ? raw : Array.isArray(raw?.data) ? raw.data : [];
      setProducts(list);
    } catch (err) {
      console.warn('Gagal memuat products:', err);
    } finally {
      setIsLoadingProducts(false);
    }
  };

  const fetchOrders = async () => {
    setIsLoadingOrders(true);
    try {
      const res = await api.get('/admin/seller-orders');
      const list = Array.isArray(res.data) ? res.data : res.data?.data || [];
      setOrders(list);
    } catch (err) {
      console.warn('Gagal memuat orders:', err);
    } finally {
      setIsLoadingOrders(false);
    }
  };

  useEffect(() => {
    fetchStats();
    fetchSellers();
    fetchProducts();
    fetchOrders();
  }, []);

  // ── Seller Actions ────────────────────────────────────────────────────────

  const handleUpdateSellerStatus = async (sellerId: string, currentStatus: string) => {
    const nextStatus =
      currentStatus === 'Seller Terverifikasi'
        ? 'Akun Ditangguhkan'
        : currentStatus === 'Akun Ditangguhkan'
        ? 'Seller Aktif'
        : 'Seller Terverifikasi';

    if (!confirm(`Ubah status toko seller ini menjadi "${nextStatus}"?`)) return;

    try {
      await api.put(`/admin/sellers/${sellerId}/status`, { status: nextStatus });
      fetchSellers();
      fetchStats();
    } catch (err: any) {
      alert(err.response?.data?.error || 'Gagal mengubah status seller');
    }
  };

  // ── Product Actions ───────────────────────────────────────────────────────

  const handleOpenAddProduct = () => {
    setEditingProductId(null);
    setProductForm(defaultProductForm);
    setProductSubmitError('');
    setIsProductModalOpen(true);
  };

  const handleOpenEditProduct = (p: SellerProduct) => {
    setEditingProductId(p.id);
    setProductForm({
      name: p.name || '',
      seller_name: p.seller_name || 'Fahda Febriya',
      store_name: p.store_name || 'Toko Tani Makmur Fahda',
      seller_contact: p.seller_contact || '',
      location: p.location || '',
      category: p.category || 'Pupuk',
      subcategory: p.subcategory || '',
      price: String(p.price || ''),
      original_price: String(p.original_price || p.price || ''),
      stock: String(p.stock ?? ''),
      min_stock_alert: String(p.min_stock_alert ?? 10),
      unit: p.unit || 'Pcs',
      status: p.status || 'Aktif',
      image: p.image || '',
      description: p.description || '',
    });
    setProductSubmitError('');
    setIsProductModalOpen(true);
  };

  const handleProductSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsProductSubmitting(true);
    setProductSubmitError('');

    try {
      const payload = {
        name: productForm.name.trim(),
        seller_name: productForm.seller_name.trim(),
        store_name: productForm.store_name.trim(),
        seller_contact: productForm.seller_contact.trim(),
        location: productForm.location.trim(),
        category: productForm.category,
        subcategory: productForm.subcategory,
        price: Number(productForm.price) || 0,
        original_price: Number(productForm.original_price) || Number(productForm.price) || 0,
        stock: Number(productForm.stock) || 0,
        min_stock_alert: Number(productForm.min_stock_alert) || 10,
        unit: productForm.unit,
        status: productForm.status,
        image: productForm.image.trim(),
        description: productForm.description.trim(),
      };

      if (editingProductId) {
        await api.put(`/seller/products/${editingProductId}`, payload);
      } else {
        await api.post('/seller/products', payload);
      }

      setIsProductModalOpen(false);
      fetchProducts();
      fetchStats();
    } catch (err: any) {
      setProductSubmitError(err.response?.data?.error || err.message || 'Gagal menyimpan produk');
    } finally {
      setIsProductSubmitting(false);
    }
  };

  const handleDeleteProduct = async (id: string, name: string) => {
    if (!confirm(`Hapus produk "${name}" dari katalog?`)) return;
    try {
      await api.delete(`/seller/products/${id}`);
      fetchProducts();
      fetchStats();
    } catch (err: any) {
      alert(err.response?.data?.error || 'Gagal menghapus produk');
    }
  };

  // ── Order Actions ─────────────────────────────────────────────────────────

  const handleOpenUpdateOrder = (order: SellerOrder) => {
    setSelectedOrder(order);
    setNewOrderStatus(order.status);
    setNewTrackingNo(order.trackingNumber || '');
  };

  const handleSaveOrderStatus = async () => {
    if (!selectedOrder) return;
    setIsUpdatingOrder(true);
    try {
      await api.put(`/seller/orders/${selectedOrder.id}/status`, {
        status: newOrderStatus,
        trackingNumber: newTrackingNo,
      });
      setSelectedOrder(null);
      fetchOrders();
      fetchStats();
    } catch (err: any) {
      alert(err.response?.data?.message || 'Gagal memperbarui status pesanan');
    } finally {
      setIsUpdatingOrder(false);
    }
  };

  const handleSyncMidtransStatus = async (orderNumber: string) => {
    setSyncingOrderId(orderNumber);
    try {
      const res = await api.get(`/payments/midtrans/status/${orderNumber}`);
      const data = res.data?.data || res.data;
      alert(`[Midtrans Sync API]\nNomor Pesanan: ${orderNumber}\nStatus Transaksi: ${data.transaction_status || data.payment_status || 'settlement'}\nStatus Pesanan: ${data.order_status || 'Diproses'}`);
      fetchOrders();
      fetchStats();
    } catch (err: any) {
      alert('Gagal mengecek status Midtrans: ' + (err.response?.data?.message || err.message));
    } finally {
      setSyncingOrderId(null);
    }
  };

  // ── Filters ───────────────────────────────────────────────────────────────

  const filteredSellers = useMemo(() => {
    return sellers.filter((s) => {
      const matchSearch =
        s.name.toLowerCase().includes(searchSeller.toLowerCase()) ||
        s.storeName.toLowerCase().includes(searchSeller.toLowerCase()) ||
        (s.storeId && s.storeId.toLowerCase().includes(searchSeller.toLowerCase())) ||
        (s.email && s.email.toLowerCase().includes(searchSeller.toLowerCase()));
      const matchStatus = statusSellerFilter === 'all' || s.status.toLowerCase() === statusSellerFilter.toLowerCase();
      return matchSearch && matchStatus;
    });
  }, [sellers, searchSeller, statusSellerFilter]);

  const filteredProducts = useMemo(() => {
    return products.filter((p) => {
      const matchSearch =
        p.name.toLowerCase().includes(searchProduct.toLowerCase()) ||
        (p.seller_name || '').toLowerCase().includes(searchProduct.toLowerCase()) ||
        (p.store_name || '').toLowerCase().includes(searchProduct.toLowerCase()) ||
        (p.sku || '').toLowerCase().includes(searchProduct.toLowerCase());
      const matchCategory = categoryFilter === 'Semua' || p.category === categoryFilter;
      let matchStatus = true;
      if (statusProductFilter === 'active') matchStatus = p.status === 'Aktif';
      else if (statusProductFilter === 'low_stock') matchStatus = p.stock > 0 && p.stock <= p.min_stock_alert;
      else if (statusProductFilter === 'out_of_stock') matchStatus = p.stock === 0 || p.status === 'Habis';
      else if (statusProductFilter === 'review') matchStatus = p.status === 'Sedang Diperiksa';
      return matchSearch && matchCategory && matchStatus;
    });
  }, [products, searchProduct, categoryFilter, statusProductFilter]);

  const filteredOrders = useMemo(() => {
    return orders.filter((o) => {
      const matchSearch =
        o.orderNumber.toLowerCase().includes(searchOrder.toLowerCase()) ||
        o.buyerName.toLowerCase().includes(searchOrder.toLowerCase()) ||
        (o.courier && o.courier.toLowerCase().includes(searchOrder.toLowerCase()));
      const matchStatus = statusOrderFilter === 'all' || o.status.toLowerCase() === statusOrderFilter.toLowerCase();
      return matchSearch && matchStatus;
    });
  }, [orders, searchOrder, statusOrderFilter]);

  return (
    <div className="space-y-6">
      {/* Header & Stats */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Manajemen Seller Center</h1>
          <p className="text-sm text-gray-500 mt-1">
            Pantau dan kelola toko mitra tani, katalog produk agrikultur, serta pergerakan pesanan secara real-time.
          </p>
        </div>
      </div>

      {/* KPI Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center font-bold text-xl">
            🏪
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Mitra Toko Seller</p>
            <p className="text-2xl font-black text-gray-900 mt-0.5">{stats.totalSellers || sellers.length}</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-700 flex items-center justify-center font-bold text-xl">
            📦
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Produk Agrikultur</p>
            <p className="text-2xl font-black text-gray-900 mt-0.5">{stats.totalProducts || products.length}</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-amber-50 text-amber-700 flex items-center justify-center font-bold text-xl">
            📑
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Total Pesanan</p>
            <p className="text-2xl font-black text-gray-900 mt-0.5">{stats.totalOrders || orders.length}</p>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-purple-50 text-purple-700 flex items-center justify-center font-bold text-xl">
            💰
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Perputaran Omzet</p>
            <p className="text-xl font-black text-gray-900 mt-0.5">
              Rp {(stats.totalRevenue || 2835000).toLocaleString('id-ID')}
            </p>
          </div>
        </div>
      </div>

      {/* Tabs Navigation */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="flex border-b border-gray-100 bg-gray-50/70 p-2 gap-2">
          <button
            onClick={() => setActiveTab('stores')}
            className={`flex-1 py-3 px-4 rounded-xl font-semibold text-sm transition-all flex items-center justify-center gap-2 ${
              activeTab === 'stores'
                ? 'bg-white text-[#2C5E1A] shadow-sm border border-gray-200/60'
                : 'text-gray-500 hover:text-gray-800 hover:bg-gray-100/60'
            }`}
          >
            <span>🏪</span>
            <span>Daftar Toko & Penjual</span>
            <span className="text-xs px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800">
              {sellers.length}
            </span>
          </button>

          <button
            onClick={() => setActiveTab('products')}
            className={`flex-1 py-3 px-4 rounded-xl font-semibold text-sm transition-all flex items-center justify-center gap-2 ${
              activeTab === 'products'
                ? 'bg-white text-[#2C5E1A] shadow-sm border border-gray-200/60'
                : 'text-gray-500 hover:text-gray-800 hover:bg-gray-100/60'
            }`}
          >
            <span>📦</span>
            <span>Katalog Produk Seller</span>
            <span className="text-xs px-2 py-0.5 rounded-full bg-blue-100 text-blue-800">
              {products.length}
            </span>
          </button>

          <button
            onClick={() => setActiveTab('orders')}
            className={`flex-1 py-3 px-4 rounded-xl font-semibold text-sm transition-all flex items-center justify-center gap-2 ${
              activeTab === 'orders'
                ? 'bg-white text-[#2C5E1A] shadow-sm border border-gray-200/60'
                : 'text-gray-500 hover:text-gray-800 hover:bg-gray-100/60'
            }`}
          >
            <span>🚚</span>
            <span>Pesanan Seller</span>
            <span className="text-xs px-2 py-0.5 rounded-full bg-amber-100 text-amber-800">
              {orders.length}
            </span>
          </button>
        </div>

        {/* ── TAB 1: STORES ─────────────────────────────────────────────────── */}
        {activeTab === 'stores' && (
          <div className="p-6 space-y-4">
            <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
              <input
                type="text"
                placeholder="Cari toko, nama seller, atau ID toko..."
                value={searchSeller}
                onChange={(e) => setSearchSeller(e.target.value)}
                className="w-full sm:w-72 px-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#2C5E1A]/20 focus:border-[#2C5E1A]"
              />

              <div className="flex items-center gap-2 w-full sm:w-auto">
                <span className="text-xs font-medium text-gray-500">Status:</span>
                <select
                  value={statusSellerFilter}
                  onChange={(e) => setStatusSellerFilter(e.target.value)}
                  className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#2C5E1A]"
                >
                  <option value="all">Semua Status</option>
                  <option value="Seller Terverifikasi">Seller Terverifikasi</option>
                  <option value="Seller Aktif">Seller Aktif</option>
                  <option value="Akun Ditangguhkan">Akun Ditangguhkan</option>
                </select>
              </div>
            </div>

            {isLoadingSellers ? (
              <div className="py-12 text-center text-gray-400">Memuat data penjual...</div>
            ) : filteredSellers.length === 0 ? (
              <div className="py-12 text-center text-gray-400">Tidak ada toko seller yang cocok.</div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm text-gray-600">
                  <thead className="bg-gray-50 text-gray-500 uppercase text-xs">
                    <tr>
                      <th className="px-4 py-3">Toko / Penjual</th>
                      <th className="px-4 py-3">ID Toko</th>
                      <th className="px-4 py-3">Kontak & Alamat</th>
                      <th className="px-4 py-3">Rating / Ulasan</th>
                      <th className="px-4 py-3">Saldo Dompet</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3 text-right">Aksi</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {filteredSellers.map((s) => (
                      <tr key={s.id} className="hover:bg-gray-50/80 transition-colors">
                        <td className="px-4 py-4">
                          <div className="flex items-center gap-3">
                            <img
                              src={s.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100'}
                              alt={s.storeName}
                              className="w-10 h-10 rounded-full object-cover border border-gray-200"
                            />
                            <div>
                              <p className="font-bold text-gray-900">{s.storeName}</p>
                              <p className="text-xs text-gray-500">{s.name}</p>
                            </div>
                          </div>
                        </td>
                        <td className="px-4 py-4 font-mono text-xs font-bold text-emerald-800">
                          {s.storeId}
                        </td>
                        <td className="px-4 py-4">
                          <p className="text-xs font-semibold text-gray-800">{s.phone}</p>
                          <p className="text-xs text-gray-400 truncate max-w-xs">{s.storeAddress}</p>
                        </td>
                        <td className="px-4 py-4">
                          <div className="flex items-center gap-1 font-semibold text-amber-600">
                            <span>⭐</span> {s.rating}
                            <span className="text-xs text-gray-400 font-normal">({s.totalReview || 0})</span>
                          </div>
                        </td>
                        <td className="px-4 py-4 font-bold text-gray-900">
                          Rp {(s.balance || 0).toLocaleString('id-ID')}
                        </td>
                        <td className="px-4 py-4">
                          <span
                            className={`inline-block px-2.5 py-1 text-xs font-semibold rounded-full ${
                              s.status === 'Seller Terverifikasi'
                                ? 'bg-emerald-100 text-emerald-800'
                                : s.status === 'Akun Ditangguhkan'
                                ? 'bg-red-100 text-red-800'
                                : 'bg-blue-100 text-blue-800'
                            }`}
                          >
                            {s.status}
                          </span>
                        </td>
                        <td className="px-4 py-4 text-right">
                          <button
                            onClick={() => handleUpdateSellerStatus(s.id, s.status)}
                            className="px-3 py-1.5 text-xs font-semibold border rounded-lg hover:bg-gray-100 transition-colors"
                          >
                            {s.status === 'Seller Terverifikasi' ? 'Tangguhkan' : 'Verifikasi'}
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* ── TAB 2: PRODUCTS ───────────────────────────────────────────────── */}
        {activeTab === 'products' && (
          <div className="p-6 space-y-4">
            <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
              <div className="flex flex-wrap items-center gap-2 w-full sm:w-auto">
                <input
                  type="text"
                  placeholder="Cari produk, SKU, kategori..."
                  value={searchProduct}
                  onChange={(e) => setSearchProduct(e.target.value)}
                  className="px-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#2C5E1A]"
                />

                <select
                  value={categoryFilter}
                  onChange={(e) => setCategoryFilter(e.target.value)}
                  className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#2C5E1A]"
                >
                  <option value="Semua">Semua Kategori</option>
                  <option value="Pupuk">Pupuk</option>
                  <option value="Pestisida">Pestisida</option>
                  <option value="Benih">Benih</option>
                  <option value="Alat Pertanian">Alat Pertanian</option>
                </select>

                <select
                  value={statusProductFilter}
                  onChange={(e) => setStatusProductFilter(e.target.value)}
                  className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#2C5E1A]"
                >
                  <option value="all">Semua Status</option>
                  <option value="active">Aktif</option>
                  <option value="low_stock">Stok Menipis</option>
                  <option value="out_of_stock">Habis</option>
                  <option value="review">Sedang Diperiksa</option>
                </select>
              </div>

              <button
                onClick={handleOpenAddProduct}
                className="w-full sm:w-auto px-4 py-2 bg-[#2C5E1A] hover:bg-[#234A14] text-white rounded-xl text-sm font-semibold shadow-sm transition-all flex items-center justify-center gap-2"
              >
                <span>➕</span> Tambah Produk Baru
              </button>
            </div>

            {isLoadingProducts ? (
              <div className="py-12 text-center text-gray-400">Memuat katalog produk seller...</div>
            ) : filteredProducts.length === 0 ? (
              <div className="py-12 text-center text-gray-400">Tidak ada produk yang sesuai.</div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm text-gray-600">
                  <thead className="bg-gray-50 text-gray-500 uppercase text-xs">
                    <tr>
                      <th className="px-4 py-3">Produk</th>
                      <th className="px-4 py-3">Toko / Seller</th>
                      <th className="px-4 py-3">Kategori</th>
                      <th className="px-4 py-3">Harga</th>
                      <th className="px-4 py-3">Stok</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3 text-right">Aksi</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {filteredProducts.map((p) => (
                      <tr key={p.id} className="hover:bg-gray-50/80 transition-colors">
                        <td className="px-4 py-3">
                          <div className="flex items-center gap-3">
                            <div className="w-12 h-12 rounded-xl bg-gray-100 overflow-hidden flex-shrink-0 border border-gray-200 shadow-xs">
                              <img
                                src={getProductImageUrl(p.image, p.name, p.category)}
                                alt={p.name}
                                className="w-full h-full object-cover"
                                onError={(e) => {
                                  (e.target as HTMLImageElement).src =
                                    'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=500&auto=format&fit=crop&q=80';
                                }}
                              />
                            </div>
                            <div>
                              <p className="font-semibold text-gray-900">{p.name}</p>
                              <p className="text-xs text-gray-400 font-mono">{p.sku || p.id}</p>
                            </div>
                          </div>
                        </td>
                        <td className="px-4 py-3 text-xs">
                          <p className="font-bold text-gray-800">{p.store_name || 'Toko Tani Makmur Fahda'}</p>
                          <p className="text-gray-400">{p.seller_name || 'Fahda Febriya'}</p>
                        </td>
                        <td className="px-4 py-3">
                          <span className="px-2 py-0.5 text-xs bg-gray-100 text-gray-700 rounded-md font-medium">
                            {p.category}
                          </span>
                        </td>
                        <td className="px-4 py-3 font-semibold text-gray-900">
                          Rp {p.price.toLocaleString('id-ID')}
                        </td>
                        <td className="px-4 py-3">
                          <span
                            className={`font-semibold ${
                              p.stock === 0
                                ? 'text-red-600 font-bold'
                                : p.stock <= p.min_stock_alert
                                ? 'text-amber-600 font-bold'
                                : 'text-gray-800'
                            }`}
                          >
                            {p.stock} {p.unit}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <span
                            className={`inline-block px-2.5 py-0.5 text-xs font-semibold rounded-full ${
                              p.status === 'Aktif'
                                ? 'bg-emerald-100 text-emerald-800'
                                : p.status === 'Stok Menipis'
                                ? 'bg-amber-100 text-amber-800'
                                : p.status === 'Habis'
                                ? 'bg-red-100 text-red-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}
                          >
                            {p.status}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-right space-x-2">
                          <button
                            onClick={() => handleOpenEditProduct(p)}
                            className="px-2.5 py-1 text-xs font-semibold text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => handleDeleteProduct(p.id, p.name)}
                            className="px-2.5 py-1 text-xs font-semibold text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                          >
                            Hapus
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* ── TAB 3: ORDERS ─────────────────────────────────────────────────── */}
        {activeTab === 'orders' && (
          <div className="p-6 space-y-4">
            <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
              <input
                type="text"
                placeholder="Cari nomor pesanan, pembeli, kurir..."
                value={searchOrder}
                onChange={(e) => setSearchOrder(e.target.value)}
                className="w-full sm:w-72 px-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#2C5E1A]"
              />

              <div className="flex items-center gap-2 w-full sm:w-auto">
                <span className="text-xs font-medium text-gray-500">Status Pesanan:</span>
                <select
                  value={statusOrderFilter}
                  onChange={(e) => setStatusOrderFilter(e.target.value)}
                  className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#2C5E1A]"
                >
                  <option value="all">Semua Status</option>
                  <option value="Diproses">Diproses</option>
                  <option value="Dikirim">Dikirim</option>
                  <option value="Selesai">Selesai</option>
                  <option value="Menunggu Pembayaran">Menunggu Pembayaran</option>
                  <option value="Dibatalkan">Dibatalkan</option>
                </select>
              </div>
            </div>

            {isLoadingOrders ? (
              <div className="py-12 text-center text-gray-400">Memuat transaksi pesanan seller...</div>
            ) : filteredOrders.length === 0 ? (
              <div className="py-12 text-center text-gray-400">Tidak ada pesanan yang sesuai filter.</div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm text-gray-600">
                  <thead className="bg-gray-50 text-gray-500 uppercase text-xs">
                    <tr>
                      <th className="px-4 py-3">No. Pesanan & Tanggal</th>
                      <th className="px-4 py-3">Toko Penjual</th>
                      <th className="px-4 py-3">Pembeli</th>
                      <th className="px-4 py-3">Item Dipesan</th>
                      <th className="px-4 py-3">Kurir & Resi</th>
                      <th className="px-4 py-3">Total Transaksi</th>
                      <th className="px-4 py-3">Status</th>
                      <th className="px-4 py-3 text-right">Aksi</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {filteredOrders.map((o) => (
                      <tr key={o.id} className="hover:bg-gray-50/80 transition-colors">
                        <td className="px-4 py-4">
                          <p className="font-mono font-bold text-gray-900">{o.orderNumber}</p>
                          <p className="text-xs text-gray-400">{o.createdAt}</p>
                        </td>
                        <td className="px-4 py-4 text-xs font-semibold text-gray-800">
                          {o.storeName || 'Toko Tani Makmur Fahda'}
                        </td>
                        <td className="px-4 py-4">
                          <p className="font-semibold text-gray-900">{o.buyerName}</p>
                          <p className="text-xs text-gray-400 truncate max-w-xs">{o.buyerPhone}</p>
                        </td>
                        <td className="px-4 py-4 text-xs">
                          {o.items?.map((it, idx) => (
                            <p key={idx} className="text-gray-800">
                              • {it.productName} <span className="font-bold">x{it.quantity}</span>
                            </p>
                          ))}
                        </td>
                        <td className="px-4 py-4 text-xs">
                          <p className="font-semibold text-gray-800">{o.courier}</p>
                          {o.trackingNumber ? (
                            <p className="font-mono text-emerald-700 font-bold">{o.trackingNumber}</p>
                          ) : (
                            <span className="text-gray-400 italic">Belum ada resi</span>
                          )}
                        </td>
                        <td className="px-4 py-4 font-bold text-gray-900">
                          Rp {o.totalAmount.toLocaleString('id-ID')}
                        </td>
                        <td className="px-4 py-4">
                          <div className="space-y-1">
                            <span
                              className={`inline-block px-2.5 py-1 text-xs font-semibold rounded-full ${
                                o.status === 'Selesai'
                                  ? 'bg-emerald-100 text-emerald-800'
                                  : o.status === 'Dikirim'
                                  ? 'bg-blue-100 text-blue-800'
                                  : o.status === 'Diproses'
                                  ? 'bg-amber-100 text-amber-800'
                                  : o.status === 'Dibatalkan'
                                  ? 'bg-red-100 text-red-800'
                                  : 'bg-gray-100 text-gray-800'
                              }`}
                            >
                              {o.status}
                            </span>
                            {o.paymentStatus && (
                              <div>
                                <span className={`inline-block px-2 py-0.5 text-[10px] font-mono rounded ${
                                  o.paymentStatus === 'settlement' || o.paymentStatus === 'capture'
                                    ? 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                                    : 'bg-yellow-50 text-yellow-700 border border-yellow-200'
                                }`}>
                                  Midtrans: {o.paymentStatus}
                                </span>
                              </div>
                            )}
                          </div>
                        </td>
                        <td className="px-4 py-4 text-right space-x-1.5 whitespace-nowrap">
                          <button
                            onClick={() => handleSyncMidtransStatus(o.orderNumber)}
                            disabled={syncingOrderId === o.orderNumber}
                            className="px-2.5 py-1.5 text-xs font-semibold bg-emerald-50 text-emerald-800 border border-emerald-200 rounded-lg hover:bg-emerald-100 transition-colors disabled:opacity-50"
                            title="Sinkronkan status transaksi langsung dari Midtrans Core API"
                          >
                            {syncingOrderId === o.orderNumber ? 'Mengecek...' : 'Cek Midtrans'}
                          </button>
                          <button
                            onClick={() => handleOpenUpdateOrder(o)}
                            className="px-3 py-1.5 text-xs font-semibold border rounded-lg hover:bg-gray-100 transition-colors"
                          >
                            Ubah Status
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}
      </div>

      {/* ── MODAL: ADD / EDIT PRODUCT ─────────────────────────────────────── */}
      {isProductModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-xl my-8">
            <div className="flex justify-between items-center pb-4 border-b border-gray-100">
              <h3 className="text-lg font-bold text-gray-900">
                {editingProductId ? 'Edit Produk Seller' : 'Tambah Produk Seller Baru'}
              </h3>
              <button
                onClick={() => setIsProductModalOpen(false)}
                className="text-gray-400 hover:text-gray-600 text-xl font-bold"
              >
                ✕
              </button>
            </div>

            {productSubmitError && (
              <div className="mt-4 p-3 bg-red-50 text-red-700 text-xs rounded-xl border border-red-200">
                {productSubmitError}
              </div>
            )}

            <form onSubmit={handleProductSubmit} className="mt-4 space-y-4 text-sm">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Nama Produk *</label>
                  <input
                    type="text"
                    required
                    value={productForm.name}
                    onChange={(e) => setProductForm({ ...productForm, name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Kategori *</label>
                  <select
                    value={productForm.category}
                    onChange={(e) => setProductForm({ ...productForm, category: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                  >
                    <option value="Pupuk">Pupuk</option>
                    <option value="Pestisida">Pestisida</option>
                    <option value="Benih">Benih</option>
                    <option value="Alat Pertanian">Alat Pertanian</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Harga Jual (Rp) *</label>
                  <input
                    type="number"
                    required
                    value={productForm.price}
                    onChange={(e) => setProductForm({ ...productForm, price: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Stok Tersedia *</label>
                  <input
                    type="number"
                    required
                    value={productForm.stock}
                    onChange={(e) => setProductForm({ ...productForm, stock: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Satuan</label>
                  <input
                    type="text"
                    value={productForm.unit}
                    onChange={(e) => setProductForm({ ...productForm, unit: e.target.value })}
                    placeholder="Pcs, Botol (1L), Sak (50kg)"
                    className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Nama Toko</label>
                  <input
                    type="text"
                    value={productForm.store_name}
                    onChange={(e) => setProductForm({ ...productForm, store_name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Status Produk</label>
                  <select
                    value={productForm.status}
                    onChange={(e) => setProductForm({ ...productForm, status: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                  >
                    <option value="Aktif">Aktif</option>
                    <option value="Stok Menipis">Stok Menipis</option>
                    <option value="Habis">Habis</option>
                    <option value="Sedang Diperiksa">Sedang Diperiksa</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">URL Gambar Produk</label>
                <input
                  type="text"
                  value={productForm.image}
                  onChange={(e) => setProductForm({ ...productForm, image: e.target.value })}
                  placeholder="https://images.unsplash.com/..."
                  className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                />
                <div className="flex flex-wrap gap-2 mt-2">
                  {PRESET_IMAGES.map((img, i) => (
                    <button
                      key={i}
                      type="button"
                      onClick={() => setProductForm({ ...productForm, image: img.url })}
                      className="text-xs px-2.5 py-1 bg-gray-100 hover:bg-gray-200 rounded-lg text-gray-700 font-medium"
                    >
                      {img.label}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Deskripsi Produk</label>
                <textarea
                  rows={3}
                  value={productForm.description}
                  onChange={(e) => setProductForm({ ...productForm, description: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                ></textarea>
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setIsProductModalOpen(false)}
                  className="px-4 py-2 border border-gray-200 rounded-xl font-semibold text-gray-600 hover:bg-gray-50"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={isProductSubmitting}
                  className="px-5 py-2 bg-[#2C5E1A] hover:bg-[#234A14] text-white rounded-xl font-semibold disabled:opacity-50"
                >
                  {isProductSubmitting ? 'Menyimpan...' : 'Simpan Produk'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ── MODAL: UPDATE ORDER STATUS ────────────────────────────────────── */}
      {selectedOrder && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl">
            <h3 className="text-lg font-bold text-gray-900 mb-2">Update Status Pesanan</h3>
            <p className="text-xs text-gray-500 mb-4 font-mono font-bold">
              {selectedOrder.orderNumber} - Pembeli: {selectedOrder.buyerName}
            </p>

            <div className="space-y-4 text-sm">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Pilih Status Baru</label>
                <select
                  value={newOrderStatus}
                  onChange={(e) => setNewOrderStatus(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                >
                  <option value="Menunggu Pembayaran">Menunggu Pembayaran</option>
                  <option value="Diproses">Diproses</option>
                  <option value="Dikirim">Dikirim</option>
                  <option value="Selesai">Selesai</option>
                  <option value="Dibatalkan">Dibatalkan</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Nomor Resi Pengiriman</label>
                <input
                  type="text"
                  placeholder="Contoh: AGC-SBG-99210"
                  value={newTrackingNo}
                  onChange={(e) => setNewTrackingNo(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#2C5E1A]"
                />
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setSelectedOrder(null)}
                  className="px-4 py-2 border border-gray-200 rounded-xl font-semibold text-gray-600 hover:bg-gray-50 text-xs"
                >
                  Batal
                </button>
                <button
                  type="button"
                  onClick={handleSaveOrderStatus}
                  disabled={isUpdatingOrder}
                  className="px-5 py-2 bg-[#2C5E1A] hover:bg-[#234A14] text-white rounded-xl font-semibold text-xs disabled:opacity-50"
                >
                  {isUpdatingOrder ? 'Menyimpan...' : 'Simpan Perubahan'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
