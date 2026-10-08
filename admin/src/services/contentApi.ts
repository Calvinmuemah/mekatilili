import { apiClient } from './api';
import {
  Chapter,
  Quest,
  NPC,
  Dialogue,
  Collectible,
  JournalEntry,
  HistoricalReference,
  User,
  ApiResponse,
} from '../types';

export const contentApi = {
  // Chapters
  getChapters: async (status?: string): Promise<Chapter[]> => {
    const params = status ? { status } : {};
    const res = await apiClient.get<ApiResponse<Chapter[]>>('/admin/content/chapters', { params });
    return res.data.data;
  },
  createChapter: async (data: Partial<Chapter>): Promise<Chapter> => {
    const res = await apiClient.post<ApiResponse<Chapter>>('/admin/content/chapters', data);
    return res.data.data;
  },
  updateChapter: async (id: string, data: Partial<Chapter>): Promise<Chapter> => {
    const res = await apiClient.put<ApiResponse<Chapter>>(`/admin/content/chapters/${id}`, data);
    return res.data.data;
  },
  setChapterStatus: async (id: string, status: string): Promise<Chapter> => {
    const res = await apiClient.patch<ApiResponse<Chapter>>(`/admin/content/chapters/${id}/status`, { status });
    return res.data.data;
  },
  deleteChapter: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/content/chapters/${id}`);
  },

  // Quests
  getQuests: async (chapterId?: string): Promise<Quest[]> => {
    const params = chapterId ? { chapterId } : {};
    const res = await apiClient.get<ApiResponse<Quest[]>>('/admin/content/quests', { params });
    return res.data.data;
  },
  createQuest: async (data: Partial<Quest>): Promise<Quest> => {
    const res = await apiClient.post<ApiResponse<Quest>>('/admin/content/quests', data);
    return res.data.data;
  },
  updateQuest: async (id: string, data: Partial<Quest>): Promise<Quest> => {
    const res = await apiClient.put<ApiResponse<Quest>>(`/admin/content/quests/${id}`, data);
    return res.data.data;
  },
  deleteQuest: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/content/quests/${id}`);
  },

  // NPCs
  getNPCs: async (chapterId?: string): Promise<NPC[]> => {
    const params = chapterId ? { chapterId } : {};
    const res = await apiClient.get<ApiResponse<NPC[]>>('/admin/content/npcs', { params });
    return res.data.data;
  },
  createNPC: async (data: Partial<NPC>): Promise<NPC> => {
    const res = await apiClient.post<ApiResponse<NPC>>('/admin/content/npcs', data);
    return res.data.data;
  },
  updateNPC: async (id: string, data: Partial<NPC>): Promise<NPC> => {
    const res = await apiClient.put<ApiResponse<NPC>>(`/admin/content/npcs/${id}`, data);
    return res.data.data;
  },
  deleteNPC: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/content/npcs/${id}`);
  },

  // Dialogues
  getDialogues: async (params?: { npcId?: string; chapterId?: string }): Promise<Dialogue[]> => {
    const res = await apiClient.get<ApiResponse<Dialogue[]>>('/admin/content/dialogues', { params });
    return res.data.data;
  },
  getDialogueById: async (id: string): Promise<Dialogue> => {
    const res = await apiClient.get<ApiResponse<Dialogue>>(`/admin/content/dialogues/${id}`);
    return res.data.data;
  },
  createDialogue: async (data: Partial<Dialogue>): Promise<Dialogue> => {
    const res = await apiClient.post<ApiResponse<Dialogue>>('/admin/content/dialogues', data);
    return res.data.data;
  },
  updateDialogue: async (id: string, data: Partial<Dialogue>): Promise<Dialogue> => {
    const res = await apiClient.put<ApiResponse<Dialogue>>(`/admin/content/dialogues/${id}`, data);
    return res.data.data;
  },
  deleteDialogue: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/content/dialogues/${id}`);
  },

  // Collectibles
  getCollectibles: async (): Promise<Collectible[]> => {
    const res = await apiClient.get<ApiResponse<Collectible[]>>('/admin/content/collectibles');
    return res.data.data;
  },
  createCollectible: async (data: Partial<Collectible>): Promise<Collectible> => {
    const res = await apiClient.post<ApiResponse<Collectible>>('/admin/content/collectibles', data);
    return res.data.data;
  },
  updateCollectible: async (id: string, data: Partial<Collectible>): Promise<Collectible> => {
    const res = await apiClient.put<ApiResponse<Collectible>>(`/admin/content/collectibles/${id}`, data);
    return res.data.data;
  },
  deleteCollectible: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/content/collectibles/${id}`);
  },

  // Journal
  getJournal: async (): Promise<JournalEntry[]> => {
    const res = await apiClient.get<ApiResponse<JournalEntry[]>>('/admin/content/journal');
    return res.data.data;
  },
  createJournal: async (data: Partial<JournalEntry>): Promise<JournalEntry> => {
    const res = await apiClient.post<ApiResponse<JournalEntry>>('/admin/content/journal', data);
    return res.data.data;
  },
  updateJournal: async (id: string, data: Partial<JournalEntry>): Promise<JournalEntry> => {
    const res = await apiClient.put<ApiResponse<JournalEntry>>(`/admin/content/journal/${id}`, data);
    return res.data.data;
  },
  deleteJournal: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/content/journal/${id}`);
  },

  // History
  getHistory: async (): Promise<HistoricalReference[]> => {
    const res = await apiClient.get<ApiResponse<HistoricalReference[]>>('/admin/content/history');
    return res.data.data;
  },
  createHistory: async (data: Partial<HistoricalReference>): Promise<HistoricalReference> => {
    const res = await apiClient.post<ApiResponse<HistoricalReference>>('/admin/content/history', data);
    return res.data.data;
  },
  updateHistory: async (id: string, data: Partial<HistoricalReference>): Promise<HistoricalReference> => {
    const res = await apiClient.put<ApiResponse<HistoricalReference>>(`/admin/content/history/${id}`, data);
    return res.data.data;
  },
  deleteHistory: async (id: string): Promise<void> => {
    await apiClient.delete(`/admin/content/history/${id}`);
  },

  // Players
  getPlayers: async (limit = 50, offset = 0): Promise<{ users: User[]; total: number }> => {
    const res = await apiClient.get<ApiResponse<{ users: User[]; total: number }>>('/admin/content/players', {
      params: { limit, offset },
    });
    return res.data.data;
  },
};
