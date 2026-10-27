import initialProducts from '@/mock/products.json';
import { Product, CreateProductInput, ProductStatus } from '@/types';
import { axiosInstance, USE_MOCK, simulateDelay } from '@/services/api/client';
import { storage } from '@/services/storage';

const STORAGE_KEY_PRODUCTS = 'petani_tech_products';

function normalizeProduct(raw: any): Product {
  const defaultImg =
    raw.image ||
    (raw.category === 'Pupuk'
      ? 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=500&auto=format&fit=crop&q=80'
      : raw.category === 'Pestisida'
      ? 'https://images.unsplash.com/photo-1592417817098-8f3d6910985c?w=500&auto=format&fit=crop&q=80'
      : raw.category === 'Benih'
      ? 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=500&auto=format&fit=crop&q=80'
      : 'https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?w=500&auto=format&fit=crop&q=80');

  return {
    id: String(raw.id || ''),
    name: raw.name || '',
    category: raw.category || 'Pupuk',
    subcategory: raw.subcategory,
    price: Number(raw.price || 0),
    originalPrice: Number(raw.originalPrice ?? raw.original_price ?? raw.price ?? 0),
    purchasePrice: Number(raw.purchasePrice ?? raw.purchase_price ?? raw.price ?? 0),
    stock: Number(raw.stock ?? 0),
    minStockAlert: Number(raw.minStockAlert ?? raw.min_stock_alert ?? 10),
    status: (raw.status || 'Aktif') as ProductStatus,
    image: defaultImg,
    description: raw.description || '',
    unit: raw.unit || 'Pcs',
    soldCount: Number(raw.soldCount ?? raw.sold_count ?? 0),
    rating: Number(raw.rating ?? 5.0),
    createdAt: (raw.createdAt || raw.date_created || new Date().toISOString()).split('T')[0],
    sku: raw.sku || '',
    sellerName: raw.sellerName || raw.seller_name || 'Fahda Febriya',
    storeName: raw.storeName || raw.store_name || 'Toko Tani Makmur Fahda',
    sellerContact: raw.sellerContact || raw.seller_contact || '0812-3456-7890',
    location: raw.location || 'Indramayu, Jawa Barat',
  };
}

class ProductService {
  private async getLocalProducts(): Promise<Product[]> {
    const raw = await storage.getItem(STORAGE_KEY_PRODUCTS);
    if (!raw) {
      const seeded = (initialProducts as any[]).map(normalizeProduct);
      await storage.setItem(STORAGE_KEY_PRODUCTS, JSON.stringify(seeded));
      return seeded;
    }
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed.map(normalizeProduct) : [];
    } catch {
      return (initialProducts as any[]).map(normalizeProduct);
    }
  }

  private async saveLocalProducts(products: Product[]): Promise<void> {
    await storage.setItem(STORAGE_KEY_PRODUCTS, JSON.stringify(products));
  }

  async getProducts(params?: {
    category?: string;
    status?: string;
    search?: string;
  }): Promise<Product[]> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get('/seller/products', { params });
        const raw = response.data;
        const list = Array.isArray(raw)
          ? raw
          : Array.isArray(raw?.data)
          ? raw.data
          : [];

        if (list.length > 0) {
          const mapped = list.map(normalizeProduct);
          await this.saveLocalProducts(mapped);
          return mapped;
        }
      } catch (err) {
        console.warn('API getProducts error, falling back to local storage:', err);
      }
    }

    // Local / Offline fallback
    await simulateDelay(200);
    let items = await this.getLocalProducts();

    if (params?.search) {
      const q = params.search.toLowerCase();
      items = items.filter(
        (p) =>
          p.name.toLowerCase().includes(q) ||
          p.category.toLowerCase().includes(q) ||
          p.sku.toLowerCase().includes(q) ||
          (p.sellerName || '').toLowerCase().includes(q)
      );
    }

    if (params?.category && params.category !== 'Semua') {
      items = items.filter((p) => p.category === params.category);
    }

    if (params?.status) {
      if (params.status === 'low_stock') {
        items = items.filter((p) => p.stock > 0 && p.stock <= p.minStockAlert);
      } else if (params.status === 'out_of_stock') {
        items = items.filter((p) => p.stock === 0);
      } else if (params.status === 'active') {
        items = items.filter((p) => p.status === 'Aktif');
      } else if (params.status === 'review') {
        items = items.filter((p) => p.status === 'Sedang Diperiksa');
      }
    }

    return items;
  }

  async getProductById(id: string): Promise<Product | undefined> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get(`/seller/products/${id}`);
        const data = response.data?.data || response.data;
        if (data) return normalizeProduct(data);
      } catch (err) {
        console.warn(`API getProductById(${id}) error:`, err);
      }
    }

    await simulateDelay(100);
    const items = await this.getLocalProducts();
    return items.find((p) => p.id === id);
  }

  async createProduct(input: CreateProductInput): Promise<Product> {
    if (!USE_MOCK) {
      try {
        const payload = {
          name: input.name,
          category: input.category,
          subcategory: input.subcategory,
          price: Number(input.price),
          original_price: Number(input.price),
          stock: Number(input.stock),
          min_stock_alert: input.minStockAlert || 10,
          description: input.description,
          image: input.image,
          unit: input.unit || 'Pcs',
          seller_name: input.sellerName || 'Fahda Febriya',
          store_name: input.storeName || 'Toko Tani Makmur Fahda',
          seller_contact: input.sellerContact || '0812-3456-7890',
          location: input.location || 'Indramayu, Jawa Barat',
        };

        const response = await axiosInstance.post('/seller/products', payload);
        const created = normalizeProduct(response.data?.data || response.data);
        const items = await this.getLocalProducts();
        items.unshift(created);
        await this.saveLocalProducts(items);
        return created;
      } catch (err) {
        console.warn('API createProduct error, using local fallback:', err);
      }
    }

    await simulateDelay(300);
    const items = await this.getLocalProducts();

    let status: ProductStatus = 'Aktif';
    if (input.stock === 0) status = 'Habis';
    else if (input.stock <= (input.minStockAlert || 10)) status = 'Stok Menipis';

    const defaultImg =
      input.image ||
      (input.category === 'Pupuk'
        ? 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=500&auto=format&fit=crop&q=80'
        : input.category === 'Pestisida'
        ? 'https://images.unsplash.com/photo-1592417817098-8f3d6910985c?w=500&auto=format&fit=crop&q=80'
        : input.category === 'Benih'
        ? 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=500&auto=format&fit=crop&q=80'
        : 'https://images.unsplash.com/photo-1530595467537-0b5996c41f2d?w=500&auto=format&fit=crop&q=80');

    const newProduct: Product = {
      id: `prod-${Date.now().toString().slice(-4)}`,
      name: input.name,
      category: input.category,
      subcategory: input.subcategory,
      price: Number(input.price),
      originalPrice: Number(input.price),
      stock: Number(input.stock),
      minStockAlert: input.minStockAlert || 15,
      status,
      image: defaultImg,
      description: input.description,
      unit: input.unit || 'Pcs',
      soldCount: 0,
      rating: 5.0,
      createdAt: new Date().toISOString().split('T')[0],
      sku: `AGR-${input.category.substring(0, 3).toUpperCase()}-${Math.floor(100 + Math.random() * 900)}`,
      sellerName: input.sellerName || 'Fahda Febriya',
      storeName: input.storeName || 'Toko Tani Makmur Fahda',
      sellerContact: input.sellerContact || '0812-3456-7890',
      location: input.location || 'Indramayu, Jawa Barat',
    };

    items.unshift(newProduct);
    await this.saveLocalProducts(items);
    return newProduct;
  }

  async updateProduct(id: string, updates: Partial<Product>): Promise<Product> {
    if (!USE_MOCK) {
      try {
        const payload: Record<string, any> = { ...updates };
        if (updates.minStockAlert !== undefined) payload.min_stock_alert = updates.minStockAlert;
        if (updates.originalPrice !== undefined) payload.original_price = updates.originalPrice;
        if (updates.sellerName !== undefined) payload.seller_name = updates.sellerName;
        if (updates.storeName !== undefined) payload.store_name = updates.storeName;
        if (updates.sellerContact !== undefined) payload.seller_contact = updates.sellerContact;

        const response = await axiosInstance.put(`/seller/products/${id}`, payload);
        const updated = normalizeProduct(response.data?.data || response.data);
        const items = await this.getLocalProducts();
        const idx = items.findIndex((p) => p.id === id);
        if (idx !== -1) {
          items[idx] = updated;
          await this.saveLocalProducts(items);
        }
        return updated;
      } catch (err) {
        console.warn('API updateProduct error, using local fallback:', err);
      }
    }

    await simulateDelay(250);
    const items = await this.getLocalProducts();
    const idx = items.findIndex((p) => p.id === id);
    if (idx === -1) throw new Error('Produk tidak ditemukan');

    const updated = { ...items[idx], ...updates };

    if (typeof updated.stock === 'number') {
      if (updated.stock === 0) updated.status = 'Habis';
      else if (updated.stock <= updated.minStockAlert) updated.status = 'Stok Menipis';
      else if (updated.status === 'Habis' || updated.status === 'Stok Menipis') updated.status = 'Aktif';
    }

    items[idx] = updated;
    await this.saveLocalProducts(items);
    return updated;
  }

  async updateStock(id: string, newStock: number): Promise<Product> {
    return this.updateProduct(id, { stock: newStock });
  }

  async deleteProduct(id: string): Promise<boolean> {
    if (!USE_MOCK) {
      try {
        await axiosInstance.delete(`/seller/products/${id}`);
      } catch (err) {
        console.warn('API deleteProduct error:', err);
      }
    }

    await simulateDelay(200);
    const items = await this.getLocalProducts();
    const filtered = items.filter((p) => p.id !== id);
    await this.saveLocalProducts(filtered);
    return true;
  }
}

export const productService = new ProductService();
export default productService;
