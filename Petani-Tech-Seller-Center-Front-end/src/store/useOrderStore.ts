import { create } from 'zustand';
import { Order, OrderFilterTab } from '@/types';
import { orderService } from '@/services/orderService';

interface OrderState {
  orders: Order[];
  isLoading: boolean;
  activeTab: OrderFilterTab;
  searchQuery: string;
  error: string | null;

  fetchOrders: () => Promise<void>;
  setActiveTab: (tab: OrderFilterTab) => void;
  setSearchQuery: (query: string) => void;
  shipOrder: (id: string, trackingNumber: string) => Promise<void>;
  completeOrder: (id: string) => Promise<void>;
  cancelOrder: (id: string, reason?: string) => Promise<void>;
  syncPaymentStatus: (orderNumber: string) => Promise<any>;
}

export const useOrderStore = create<OrderState>((set, get) => ({
  orders: [],
  isLoading: false,
  activeTab: 'all',
  searchQuery: '',
  error: null,

  fetchOrders: async () => {
    set({ isLoading: true, error: null });
    try {
      const { activeTab, searchQuery } = get();
      const data = await orderService.getOrders({
        status: activeTab,
        search: searchQuery,
      });
      set({ orders: data, isLoading: false });
    } catch (err: unknown) {
      set({ isLoading: false, error: err instanceof Error ? err.message : 'Gagal memuat pesanan' });
    }
  },

  setActiveTab: (tab) => {
    set({ activeTab: tab });
    get().fetchOrders();
  },

  setSearchQuery: (query) => {
    set({ searchQuery: query });
    get().fetchOrders();
  },

  shipOrder: async (id, trackingNumber) => {
    await orderService.shipOrder(id, trackingNumber);
    await get().fetchOrders();
  },

  completeOrder: async (id) => {
    await orderService.completeOrder(id);
    await get().fetchOrders();
  },

  cancelOrder: async (id, reason) => {
    await orderService.cancelOrder(id, reason);
    await get().fetchOrders();
  },

  syncPaymentStatus: async (orderNumber) => {
    const res = await orderService.syncMidtransStatus(orderNumber);
    await get().fetchOrders();
    return res;
  },
}));
