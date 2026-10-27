import { create } from 'zustand';
import { Product, CreateProductInput, ProductFilterTab } from '@/types';
import { productService } from '@/services/productService';

interface ProductState {
  products: Product[];
  isLoading: boolean;
  activeTab: ProductFilterTab;
  searchQuery: string;
  selectedCategory: string;
  error: string | null;

  fetchProducts: () => Promise<void>;
  setActiveTab: (tab: ProductFilterTab) => void;
  setSearchQuery: (query: string) => void;
  setSelectedCategory: (category: string) => void;
  addProduct: (input: CreateProductInput) => Promise<Product>;
  updateProduct: (id: string, updates: Partial<Product>) => Promise<Product>;
  deleteProduct: (id: string) => Promise<void>;
  updateStock: (id: string, newStock: number) => Promise<void>;
}

export const useProductStore = create<ProductState>((set, get) => ({
  products: [],
  isLoading: false,
  activeTab: 'all',
  searchQuery: '',
  selectedCategory: 'Semua',
  error: null,

  fetchProducts: async () => {
    set({ isLoading: true, error: null });
    try {
      const { activeTab, searchQuery, selectedCategory } = get();
      const statusParam =
        activeTab === 'all'
          ? undefined
          : activeTab === 'active'
          ? 'active'
          : activeTab === 'low_stock'
          ? 'low_stock'
          : activeTab === 'out_of_stock'
          ? 'out_of_stock'
          : 'review';

      const data = await productService.getProducts({
        category: selectedCategory,
        status: statusParam,
        search: searchQuery,
      });
      set({ products: data, isLoading: false });
    } catch (err: unknown) {
      set({ isLoading: false, error: err instanceof Error ? err.message : 'Gagal memuat produk' });
    }
  },

  setActiveTab: (tab) => {
    set({ activeTab: tab });
    get().fetchProducts();
  },

  setSearchQuery: (query) => {
    set({ searchQuery: query });
    get().fetchProducts();
  },

  setSelectedCategory: (category) => {
    set({ selectedCategory: category });
    get().fetchProducts();
  },

  addProduct: async (input) => {
    set({ isLoading: true });
    try {
      const created = await productService.createProduct(input);
      await get().fetchProducts();
      return created;
    } finally {
      set({ isLoading: false });
    }
  },

  updateProduct: async (id, updates) => {
    const updated = await productService.updateProduct(id, updates);
    await get().fetchProducts();
    return updated;
  },

  deleteProduct: async (id) => {
    await productService.deleteProduct(id);
    await get().fetchProducts();
  },

  updateStock: async (id, newStock) => {
    await productService.updateStock(id, newStock);
    await get().fetchProducts();
  },
}));
