export type AdminRole = 'SUPER_ADMIN' | 'CONTENT_EDITOR' | 'ANALYST';
export type ContentStatus = 'DRAFT' | 'PUBLISHED' | 'ARCHIVED';

export type ObjectiveType = 
  | 'TALK_TO_NPC'
  | 'VISIT_LOCATION'
  | 'COLLECT_ITEM'
  | 'REACH_LOCATION'
  | 'COMPLETE_DIALOGUE'
  | 'TRIGGER_EVENT'
  | 'CUSTOM';

export interface Admin {
  id: string;
  email: string;
  name: string;
  role: AdminRole;
  is_active: boolean;
  created_at?: string;
}

export interface User {
  id: string;
  email: string;
  username: string;
  display_name: string;
  is_active: boolean;
  last_login_at?: string;
  created_at: string;
  current_chapter?: number;
  progress_percentage?: number;
  community_unity?: number;
}

export interface Chapter {
  id: string;
  chapter_number: number;
  title: string;
  subtitle?: string;
  description: string;
  summary?: string;
  historical_note?: string;
  scene_path?: string;
  status: ContentStatus;
  order_index: number;
  created_at?: string;
  updated_at?: string;
}

export interface Objective {
  id: string;
  quest_id?: string;
  title: string;
  description: string;
  objective_type: ObjectiveType;
  required: boolean;
  order_index: number;
  created_at?: string;
}

export interface Quest {
  id: string;
  chapter_id: string;
  title: string;
  description: string;
  status: ContentStatus;
  reward_text?: string;
  order_index: number;
  objectives?: Objective[];
  created_at?: string;
  updated_at?: string;
}

export interface NPC {
  id: string;
  name: string;
  description: string;
  role: string;
  portrait_url?: string;
  chapter_id?: string;
  location_name?: string;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface DialogueChoice {
  text: string;
  next?: string;
  events?: Array<{ action: string; target?: string; value?: string | number | boolean }>;
}

export interface DialogueNode {
  speaker: string;
  portrait?: string;
  text: string;
  next?: string;
  choices?: DialogueChoice[];
  events?: Array<{ action: string; target?: string; value?: string | number | boolean }>;
}

export interface Dialogue {
  id: string;
  npc_id: string;
  chapter_id?: string;
  title: string;
  start_node_id: string;
  raw_nodes: Record<string, DialogueNode>;
  status: ContentStatus;
  npc_name?: string;
  npc_portrait?: string;
  created_at?: string;
  updated_at?: string;
}

export interface Collectible {
  id: string;
  name: string;
  description: string;
  category: string;
  image_url?: string;
  historical_context?: string;
  chapter_id?: string;
  status: ContentStatus;
  created_at?: string;
  updated_at?: string;
}

export interface JournalEntry {
  id: string;
  title: string;
  content: string;
  category: 'STORY' | 'HISTORY' | 'CULTURAL' | 'CHARACTER';
  chapter_id?: string;
  image_url?: string;
  reference_source?: string;
  status: ContentStatus;
  created_at?: string;
  updated_at?: string;
}

export interface HistoricalReference {
  id: string;
  title: string;
  description: string;
  source: string;
  source_url?: string;
  author?: string;
  publication_date?: string;
  notes?: string;
  related_chapter_id?: string;
  is_verified: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface PlayerProgress {
  user_id: string;
  current_chapter: number;
  current_scene: string;
  progress_percentage: number;
  community_unity: number;
  player_position: { x: number; y: number };
  raw_save_data?: Record<string, unknown>;
  updated_at?: string;
}

export interface AnalyticsMetrics {
  totalPlayers: number;
  activePlayers: number;
  publishedChapters: number;
  publishedQuests: number;
  activeNPCs: number;
  publishedCollectibles: number;
  eventDistribution: Array<{ event_type: string; count: string | number }>;
  recentEvents: Array<{
    id: string;
    event_type: string;
    chapter_id?: string;
    quest_id?: string;
    metadata: Record<string, unknown>;
    created_at: string;
  }>;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: {
    code: string;
    message: string;
    details?: Array<{ field: string; message: string }>;
  };
}
