import initialData from '@/mock/inventory.json';
import { InventoryItem, InventoryMovement, InventorySummary, Supplier } from '@/types';
import { simulateDelay } from '@/api/client';
import { storage } from '@/services/storage';

const STORAGE_KEY = 'petani_tech_inventory';

interface StoredData {
  suppliers: Supplier[];
  inventory: InventoryItem[];
  movements: InventoryMovement[];
}

class InventoryService {
  private async getData(): Promise<StoredData> {
    const raw = await storage.getItem(STORAGE_KEY);
    if (!raw) {
      await storage.setItem(STORAGE_KEY, JSON.stringify(initialData));
      return initialData as unknown as StoredData;
    }
    try {
      return JSON.parse(raw) as StoredData;
    } catch {
      return initialData as unknown as StoredData;
    }
  }

  private async saveData(data: StoredData): Promise<void> {
    await storage.setItem(STORAGE_KEY, JSON.stringify(data));
  }

  // ── Inventory Items ──────────────────────────────────────────────────────
  async getInventory(params?: { search?: string; status?: string; category?: string }): Promise<InventoryItem[]> {
    await simulateDelay(250);
    const data = await this.getData();
    let items = data.inventory;

    if (params?.search) {
      const q = params.search.toLowerCase();
      items = items.filter(
        (i) =>
          i.productName.toLowerCase().includes(q) ||
          i.sku.toLowerCase().includes(q) ||
          i.supplierName.toLowerCase().includes(q)
      );
    }
    if (params?.status && params.status !== 'all') {
      if (params.status === 'Aman') items = items.filter((i) => i.currentStock > i.minimumStock);
      else if (params.status === 'Menipis') items = items.filter((i) => i.currentStock > 0 && i.currentStock <= i.minimumStock);
      else if (params.status === 'Habis') items = items.filter((i) => i.currentStock === 0);
    }
    if (params?.category && params.category !== 'Semua') {
      items = items.filter((i) => i.category === params.category);
    }
    return items;
  }

  async getSummary(): Promise<InventorySummary> {
    await simulateDelay(150);
    const data = await this.getData();
    const items = data.inventory;
    const totalStockValue = items.reduce(
      (acc, i) => acc + i.currentStock * i.purchasePrice,
      0
    );
    return {
      totalItems: items.length,
      safeItems: items.filter((i) => i.currentStock > i.minimumStock).length,
      lowItems: items.filter((i) => i.currentStock > 0 && i.currentStock <= i.minimumStock).length,
      emptyItems: items.filter((i) => i.currentStock === 0).length,
      totalStockValue,
    };
  }

  async addStock(
    inventoryId: string,
    quantity: number,
    reason: string
  ): Promise<InventoryItem> {
    await simulateDelay(300);
    const data = await this.getData();
    const idx = data.inventory.findIndex((i) => i.id === inventoryId);
    if (idx === -1) throw new Error('Produk inventori tidak ditemukan');

    const before = data.inventory[idx].currentStock;
    const after = before + quantity;
    data.inventory[idx].currentStock = after;
    data.inventory[idx].lastRestockDate = new Date().toISOString().split('T')[0];
    data.inventory[idx].lastRestockQty = quantity;

    // Update status
    const item = data.inventory[idx];
    if (item.currentStock === 0) item.status = 'Habis';
    else if (item.currentStock <= item.minimumStock) item.status = 'Menipis';
    else item.status = 'Aman';

    // Record movement
    const movement: InventoryMovement = {
      id: `mov-${Date.now()}`,
      inventoryId,
      productName: item.productName,
      type: 'masuk',
      quantity,
      reason,
      date: new Date().toLocaleString('id-ID'),
      performedBy: 'Pak Budi',
      balanceBefore: before,
      balanceAfter: after,
    };
    data.movements.unshift(movement);

    await this.saveData(data);
    return data.inventory[idx];
  }

  async removeStock(
    inventoryId: string,
    quantity: number,
    reason: string
  ): Promise<InventoryItem> {
    await simulateDelay(300);
    const data = await this.getData();
    const idx = data.inventory.findIndex((i) => i.id === inventoryId);
    if (idx === -1) throw new Error('Produk inventori tidak ditemukan');

    const before = data.inventory[idx].currentStock;
    if (quantity > before) throw new Error('Jumlah pengurangan melebihi stok yang tersedia');

    const after = before - quantity;
    data.inventory[idx].currentStock = after;

    const item = data.inventory[idx];
    if (item.currentStock === 0) item.status = 'Habis';
    else if (item.currentStock <= item.minimumStock) item.status = 'Menipis';
    else item.status = 'Aman';

    const movement: InventoryMovement = {
      id: `mov-${Date.now()}`,
      inventoryId,
      productName: item.productName,
      type: 'keluar',
      quantity,
      reason,
      date: new Date().toLocaleString('id-ID'),
      performedBy: 'Pak Budi',
      balanceBefore: before,
      balanceAfter: after,
    };
    data.movements.unshift(movement);

    await this.saveData(data);
    return data.inventory[idx];
  }

  async updateMinimumStock(inventoryId: string, minStock: number): Promise<InventoryItem> {
    await simulateDelay(200);
    const data = await this.getData();
    const idx = data.inventory.findIndex((i) => i.id === inventoryId);
    if (idx === -1) throw new Error('Tidak ditemukan');
    data.inventory[idx].minimumStock = minStock;
    await this.saveData(data);
    return data.inventory[idx];
  }

  // ── Movements ────────────────────────────────────────────────────────────
  async getMovements(inventoryId?: string): Promise<InventoryMovement[]> {
    await simulateDelay(200);
    const data = await this.getData();
    const movements = data.movements;
    if (inventoryId) return movements.filter((m) => m.inventoryId === inventoryId);
    return movements;
  }

  // ── Suppliers ────────────────────────────────────────────────────────────
  async getSuppliers(): Promise<Supplier[]> {
    await simulateDelay(200);
    const data = await this.getData();
    return data.suppliers;
  }
}

export const inventoryService = new InventoryService();
export default inventoryService;
