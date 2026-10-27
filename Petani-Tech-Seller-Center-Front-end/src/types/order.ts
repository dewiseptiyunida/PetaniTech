export type OrderStatus =
  | 'Menunggu Pembayaran'
  | 'Diproses'
  | 'Dikirim'
  | 'Selesai'
  | 'Dibatalkan';

export interface OrderItem {
  productId: string;
  productName: string;
  category: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
  productImage: string;
  unit: string;
}

export interface Order {
  id: string; // e.g., #PT20261001
  orderNumber: string;
  buyerName: string;
  buyerPhone: string;
  buyerAddress: string;
  status: OrderStatus;
  items: OrderItem[];
  totalAmount: number;
  shippingFee: number;
  courier: string;
  trackingNumber?: string;
  createdAt: string;
  paymentMethod: string;
  paymentStatus?: string;
  note?: string;
}

export type OrderFilterTab = 'all' | 'unpaid' | 'processing' | 'shipped' | 'completed' | 'cancelled';
