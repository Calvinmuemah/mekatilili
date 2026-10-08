import { apiClient } from './api';
import { Admin, ApiResponse } from '../types';

export const authApi = {
  login: async (email: string, password: string): Promise<{ admin: Admin; token: string }> => {
    const res = await apiClient.post<ApiResponse<{ admin: Admin; token: string }>>('/admin/auth/login', {
      email,
      password,
    });
    return res.data.data;
  },

  getMe: async (): Promise<Admin> => {
    const res = await apiClient.get<ApiResponse<{ admin: Admin }>>('/admin/auth/me');
    return res.data.data.admin;
  },

  logout: () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
  },
};
