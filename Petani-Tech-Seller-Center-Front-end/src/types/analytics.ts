export interface DailySalesData {
  date: string;
  penjualan: number;
  pesanan: number;
  pengunjung: number;
}

export interface WeeklySalesData {
  week: string;
  penjualan: number;
  pesanan: number;
  pengunjung: number;
}

export interface MonthlySalesData {
  month: string;
  penjualan: number;
  pesanan: number;
  pengunjung: number;
}

export interface TopProductMetric {
  id: string;
  name: string;
  category: string;
  soldCount: number;
  revenue: number;
  growth: number;
}

export interface AnalyticsSummary {
  summary: {
    totalVisitors: number;
    conversionRate: number;
    totalOrders: number;
    averageOrderValue: number;
  };
  dailyData: DailySalesData[];
  weeklyData: WeeklySalesData[];
  monthlyData: MonthlySalesData[];
  topProducts: TopProductMetric[];
}
