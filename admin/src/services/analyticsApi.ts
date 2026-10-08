import { apiClient } from './api';
import { AnalyticsMetrics, ApiResponse } from '../types';

export const analyticsApi = {
  getDashboardMetrics: async (): Promise<AnalyticsMetrics> => {
    const res = await apiClient.get<ApiResponse<AnalyticsMetrics>>('/analytics/dashboard');
    return res.data.data;
  },
};
