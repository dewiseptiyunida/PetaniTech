// ---------------------------------------------------------------------------
// Product Domain – Full Agricultural Category Taxonomy
// ---------------------------------------------------------------------------

// ── Level 1: Main Category ──────────────────────────────────────────────────
export type ProductCategory = 'Pupuk' | 'Pestisida' | 'Benih' | 'Alat Pertanian';

// ── Level 2: Sub-categories ─────────────────────────────────────────────────
export type FertilizerSubcategory = 'NPK' | 'Urea' | 'Pupuk Organik' | 'Kompos';
export type PesticideSubcategory  = 'Insektisida' | 'Fungisida' | 'Herbisida';
export type SeedSubcategory       = 'Benih Padi' | 'Benih Jagung' | 'Benih Sayuran';
export type ToolSubcategory       = 'Sprayer' | 'Pompa Air' | 'Mini Traktor' | 'Peralatan Pertanian';

export type ProductSubcategory =
  | FertilizerSubcategory
  | PesticideSubcategory
  | SeedSubcategory
  | ToolSubcategory;

// Map of category → available subcategories
export const SUBCATEGORY_MAP: Record<ProductCategory, ProductSubcategory[]> = {
  Pupuk: ['NPK', 'Urea', 'Pupuk Organik', 'Kompos'],
  Pestisida: ['Insektisida', 'Fungisida', 'Herbisida'],
  Benih: ['Benih Padi', 'Benih Jagung', 'Benih Sayuran'],
  'Alat Pertanian': ['Sprayer', 'Pompa Air', 'Mini Traktor', 'Peralatan Pertanian'],
};

// ── Product Status ──────────────────────────────────────────────────────────
export type ProductStatus =
  | 'Aktif'
  | 'Stok Menipis'
  | 'Habis'
  | 'Sedang Diperiksa';

// ── Core Product Interface ──────────────────────────────────────────────────
export interface Product {
  id: string;
  name: string;
  category: ProductCategory;
  subcategory?: ProductSubcategory;
  price: number;
  purchasePrice?: number;   // Cost of goods – for margin calculation
  originalPrice?: number;
  stock: number;
  minStockAlert: number;
  status: ProductStatus;
  image: string;
  description: string;
  unit: string;
  soldCount: number;
  rating: number;
  createdAt: string;
  sku: string;
  supplierId?: string;
  warehouseLocation?: string;
  weight?: number;           // kg – for shipping calculation
  tags?: string[];
  sellerName?: string;
  storeName?: string;
  sellerContact?: string;
  location?: string;
}

// ── CRUD Input Types ────────────────────────────────────────────────────────
export type ProductFilterTab = 'all' | 'active' | 'low_stock' | 'out_of_stock' | 'review';

export interface CreateProductInput {
  name: string;
  category: ProductCategory;
  subcategory?: ProductSubcategory;
  price: number;
  purchasePrice?: number;
  stock: number;
  description: string;
  image?: string;
  unit?: string;
  minStockAlert?: number;
  supplierId?: string;
  warehouseLocation?: string;
  weight?: number;
  sellerName?: string;
  storeName?: string;
  sellerContact?: string;
  location?: string;
}
