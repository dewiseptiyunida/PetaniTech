export const APP_NAME = 'Petani Tech Seller Center';

export const PRODUCT_CATEGORIES = [
  'Semua',
  'Pupuk',
  'Pestisida',
  'Benih',
  'Alat Pertanian',
] as const;

export const formatRupiah = (val: number): string => {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0,
  }).format(val);
};

export const formatNumber = (val: number): string => {
  return new Intl.NumberFormat('id-ID').format(val);
};
