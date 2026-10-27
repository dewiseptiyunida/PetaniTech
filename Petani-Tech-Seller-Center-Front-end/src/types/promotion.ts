export type PromotionType = 'Diskon Produk' | 'Voucher' | 'Campaign';

export type PromotionStatus = 'Aktif' | 'Akan Datang' | 'Berakhir';

export interface Promotion {
  id: string;
  name: string;
  type: PromotionType;
  discountType: 'percentage' | 'fixed';
  discountValue: number;
  minPurchase?: number;
  startDate: string;
  endDate: string;
  status: PromotionStatus;
  targetCategory?: string;
  usedCount: number;
  totalQuota: number;
}
