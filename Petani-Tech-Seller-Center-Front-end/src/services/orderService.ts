import initialOrders from '@/mock/orders.json';
import { Order, OrderStatus } from '@/types';
import { axiosInstance, USE_MOCK, simulateDelay } from '@/services/api/client';
import { storage } from '@/services/storage';

const STORAGE_KEY_ORDERS = 'petani_tech_orders';

class OrderService {
  private async getLocalOrders(): Promise<Order[]> {
    const raw = await storage.getItem(STORAGE_KEY_ORDERS);
    if (!raw) {
      await storage.setItem(STORAGE_KEY_ORDERS, JSON.stringify(initialOrders));
      return initialOrders as Order[];
    }
    try {
      return JSON.parse(raw) as Order[];
    } catch {
      return initialOrders as Order[];
    }
  }

  private async saveLocalOrders(orders: Order[]): Promise<void> {
    await storage.setItem(STORAGE_KEY_ORDERS, JSON.stringify(orders));
  }

  async getOrders(params?: { status?: string; search?: string }): Promise<Order[]> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get('/seller/orders', { params });
        const raw = response.data;
        const list = Array.isArray(raw)
          ? raw
          : Array.isArray(raw?.data)
          ? raw.data
          : [];
        if (list.length > 0) {
          await this.saveLocalOrders(list);
          return list;
        }
      } catch (err) {
        console.warn('API getOrders error, falling back to local storage:', err);
      }
    }

    await simulateDelay(250);
    let items = await this.getLocalOrders();

    if (params?.search) {
      const q = params.search.toLowerCase();
      items = items.filter(
        (o) =>
          o.orderNumber.toLowerCase().includes(q) ||
          o.buyerName.toLowerCase().includes(q) ||
          o.items.some((i) => i.productName.toLowerCase().includes(q))
      );
    }

    if (params?.status && params.status !== 'all') {
      const statusMap: Record<string, OrderStatus> = {
        unpaid: 'Menunggu Pembayaran',
        processing: 'Diproses',
        shipped: 'Dikirim',
        completed: 'Selesai',
        cancelled: 'Dibatalkan',
      };
      const mapped = statusMap[params.status];
      if (mapped) {
        items = items.filter((o) => o.status === mapped);
      }
    }

    return items;
  }

  async getOrderById(id: string): Promise<Order | undefined> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get(`/seller/orders/${id}`);
        const data = response.data?.data || response.data;
        if (data) return data;
      } catch (err) {
        console.warn(`API getOrderById(${id}) error:`, err);
      }
    }

    await simulateDelay(150);
    const items = await this.getLocalOrders();
    return items.find((o) => o.id === id || o.orderNumber === id);
  }

  async updateOrderStatus(
    id: string,
    status: OrderStatus,
    extra?: { trackingNumber?: string; note?: string }
  ): Promise<Order> {
    if (!USE_MOCK) {
      try {
        const payload = {
          status,
          trackingNumber: extra?.trackingNumber,
          note: extra?.note,
        };
        const response = await axiosInstance.put(`/seller/orders/${id}/status`, payload);
        const updated = response.data?.data || response.data;
        const items = await this.getLocalOrders();
        const idx = items.findIndex((o) => o.id === id || o.orderNumber === id);
        if (idx !== -1) {
          items[idx] = updated;
          await this.saveLocalOrders(items);
        }
        return updated;
      } catch (err) {
        console.warn('API updateOrderStatus error, using local fallback:', err);
      }
    }

    await simulateDelay(300);
    const items = await this.getLocalOrders();
    const idx = items.findIndex((o) => o.id === id || o.orderNumber === id);
    if (idx === -1) throw new Error('Pesanan tidak ditemukan');

    items[idx] = {
      ...items[idx],
      status,
      ...(extra?.trackingNumber ? { trackingNumber: extra.trackingNumber } : {}),
      ...(extra?.note ? { note: extra.note } : {}),
    };

    await this.saveLocalOrders(items);
    return items[idx];
  }

  async shipOrder(id: string, trackingNumber: string): Promise<Order> {
    return this.updateOrderStatus(id, 'Dikirim', { trackingNumber });
  }

  async completeOrder(id: string): Promise<Order> {
    return this.updateOrderStatus(id, 'Selesai');
  }

  async cancelOrder(id: string, reason?: string): Promise<Order> {
    return this.updateOrderStatus(id, 'Dibatalkan', { note: reason });
  }

  async syncMidtransStatus(orderNumber: string): Promise<any> {
    if (!USE_MOCK) {
      try {
        const response = await axiosInstance.get(`/payments/midtrans/status/${orderNumber}`);
        return response.data?.data || response.data;
      } catch (err) {
        console.warn('syncMidtransStatus error:', err);
        throw err;
      }
    }
    return null;
  }
}

export const orderService = new OrderService();
export default orderService;
