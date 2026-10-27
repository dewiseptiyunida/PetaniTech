import { create } from 'zustand';
import { InventoryItem, InventoryMovement, InventorySummary, Supplier } from '@/types';
import { inventoryService } from '@/services/inventoryService';

interface InventoryState {
  items: InventoryItem[];
  movements: InventoryMovement[];
  suppliers: Supplier[];
  summary: InventorySummary | null;
  isLoading: boolean;
  error: string | null;
  filterStatus: string;
  filterCategory: string;
  searchQuery: string;

  fetchInventory: () => Promise<void>;
  fetchMovements: (inventoryId?: string) => Promise<void>;
  fetchSuppliers: () => Promise<void>;
  addStock: (inventoryId: string, qty: number, reason: string) => Promise<void>;
  removeStock: (inventoryId: string, qty: number, reason: string) => Promise<void>;
  updateMinimumStock: (inventoryId: string, minStock: number) => Promise<void>;
  setFilterStatus: (status: string) => void;
  setFilterCategory: (category: string) => void;
  setSearchQuery: (query: string) => void;
}

export const useInventoryStore = create<InventoryState>((set, get) => ({
  items: [],
  movements: [],
  suppliers: [],
  summary: null,
  isLoading: false,
  error: null,
  filterStatus: 'all',
  filterCategory: 'Semua',
  searchQuery: '',

  fetchInventory: async () => {
    set({ isLoading: true, error: null });
    try {
      const { filterStatus, filterCategory, searchQuery } = get();
      const [items, summary] = await Promise.all([
        inventoryService.getInventory({
          status: filterStatus !== 'all' ? filterStatus : undefined,
          category: filterCategory !== 'Semua' ? filterCategory : undefined,
          search: searchQuery || undefined,
        }),
        inventoryService.getSummary(),
      ]);
      set({ items, summary, isLoading: false });
    } catch (err: unknown) {
      set({ isLoading: false, error: err instanceof Error ? err.message : 'Gagal memuat inventori' });
    }
  },

  fetchMovements: async (inventoryId) => {
    const movements = await inventoryService.getMovements(inventoryId);
    set({ movements });
  },

  fetchSuppliers: async () => {
    const suppliers = await inventoryService.getSuppliers();
    set({ suppliers });
  },

  addStock: async (inventoryId, qty, reason) => {
    set({ isLoading: true });
    try {
      await inventoryService.addStock(inventoryId, qty, reason);
      await get().fetchInventory();
    } finally {
      set({ isLoading: false });
    }
  },

  removeStock: async (inventoryId, qty, reason) => {
    set({ isLoading: true });
    try {
      await inventoryService.removeStock(inventoryId, qty, reason);
      await get().fetchInventory();
    } finally {
      set({ isLoading: false });
    }
  },

  updateMinimumStock: async (inventoryId, minStock) => {
    await inventoryService.updateMinimumStock(inventoryId, minStock);
    await get().fetchInventory();
  },

  setFilterStatus: (status) => {
    set({ filterStatus: status });
    get().fetchInventory();
  },

  setFilterCategory: (category) => {
    set({ filterCategory: category });
    get().fetchInventory();
  },

  setSearchQuery: (query) => {
    set({ searchQuery: query });
    get().fetchInventory();
  },
}));
