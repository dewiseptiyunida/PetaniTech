// ---------------------------------------------------------------------------
// Inventory Management Domain
// ---------------------------------------------------------------------------

export interface Supplier {
  id: string;
  name: string;
  contact: string;
  address: string;
  category: string[];
}

export interface InventoryItem {
  id: string;
  sku: string;
  productId: string;
  productName: string;
  category: string;
  subcategory?: string;
  unit: string;
  purchasePrice: number;
  sellingPrice: number;
  currentStock: number;
  minimumStock: number;
  supplierId: string;
  supplierName: string;
  warehouseLocation: string;
  lastRestockDate: string;
  lastRestockQty: number;
  status: 'Aman' | 'Menipis' | 'Habis';
}

export interface InventoryMovement {
  id: string;
  inventoryId: string;
  productName: string;
  type: 'masuk' | 'keluar';
  quantity: number;
  reason: string;
  date: string;
  performedBy: string;
  balanceBefore: number;
  balanceAfter: number;
}

export interface InventorySummary {
  totalItems: number;
  safeItems: number;
  lowItems: number;
  emptyItems: number;
  totalStockValue: number;
}
