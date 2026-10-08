import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AdminLayout } from './layouts/AdminLayout';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { ChaptersPage } from './pages/ChaptersPage';
import { QuestsPage } from './pages/QuestsPage';
import { NPCsPage } from './pages/NPCsPage';
import { DialogueEditorPage } from './pages/DialogueEditorPage';
import { CollectiblesPage } from './pages/CollectiblesPage';
import { JournalPage } from './pages/JournalPage';
import { HistoryPage } from './pages/HistoryPage';
import { PlayersPage } from './pages/PlayersPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { SettingsPage } from './pages/SettingsPage';

const ProtectedRoute: React.FC<{ children: React.ReactElement }> = ({ children }) => {
  const token = localStorage.getItem('admin_token');
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  return children;
};

export const App: React.FC = () => {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />

      <Route
        path="/"
        element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="chapters" element={<ChaptersPage />} />
        <Route path="quests" element={<QuestsPage />} />
        <Route path="npcs" element={<NPCsPage />} />
        <Route path="dialogues" element={<DialogueEditorPage />} />
        <Route path="collectibles" element={<CollectiblesPage />} />
        <Route path="journal" element={<JournalPage />} />
        <Route path="history" element={<HistoryPage />} />
        <Route path="players" element={<PlayersPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="settings" element={<SettingsPage />} />
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
};
