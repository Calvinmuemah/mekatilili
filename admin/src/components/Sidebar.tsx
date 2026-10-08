import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  BookOpen,
  Compass,
  Users,
  MessageSquare,
  Sparkles,
  BookMarked,
  Scroll,
  Gamepad2,
  BarChart3,
  Settings,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';

interface SidebarProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ isCollapsed, onToggle }) => {
  const navItems = [
    { to: '/', label: 'Dashboard', icon: LayoutDashboard },
    { to: '/chapters', label: 'Chapters', icon: BookOpen },
    { to: '/quests', label: 'Quests', icon: Compass },
    { to: '/npcs', label: 'NPCs', icon: Users },
    { to: '/dialogues', label: 'Dialogues', icon: MessageSquare },
    { to: '/collectibles', label: 'Collectibles', icon: Sparkles },
    { to: '/journal', label: 'Journal', icon: BookMarked },
    { to: '/history', label: 'History', icon: Scroll },
    { to: '/players', label: 'Players', icon: Gamepad2 },
    { to: '/analytics', label: 'Analytics', icon: BarChart3 },
    { to: '/settings', label: 'Settings', icon: Settings },
  ];

  return (
    <aside style={{
      width: isCollapsed ? '72px' : '240px',
      backgroundColor: 'var(--bg-surface)',
      borderRight: '1px solid var(--border-color)',
      display: 'flex',
      flexDirection: 'column',
      transition: 'width 0.25s ease',
      height: '100vh',
      position: 'sticky',
      top: 0,
      flexShrink: 0,
    }}>
      {/* Brand Header */}
      <div style={{
        padding: '20px 16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: isCollapsed ? 'center' : 'space-between',
        borderBottom: '1px solid var(--border-color)',
      }}>
        {!isCollapsed && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div style={{
              width: '32px',
              height: '32px',
              borderRadius: '8px',
              backgroundColor: 'var(--terracotta)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FFFFFF',
              fontWeight: 'bold',
            }}>
              M
            </div>
            <div>
              <h2 style={{ fontSize: '15px', color: 'var(--deep-earth)', fontWeight: 'bold', lineHeight: 1.2 }}>
                Mekatilili
              </h2>
              <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Admin Portal</span>
            </div>
          </div>
        )}
        <button
          onClick={onToggle}
          style={{
            padding: '6px',
            borderRadius: '6px',
            color: 'var(--text-muted)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
          title={isCollapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {isCollapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
        </button>
      </div>

      {/* Navigation List */}
      <nav style={{ flex: 1, padding: '16px 8px', overflowY: 'auto' }}>
        <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '4px' }}>
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <li key={item.to}>
                <NavLink
                  to={item.to}
                  style={({ isActive }) => ({
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '10px 12px',
                    borderRadius: '8px',
                    fontSize: '14px',
                    fontWeight: isActive ? '600' : '500',
                    color: isActive ? 'var(--terracotta)' : 'var(--text-muted)',
                    backgroundColor: isActive ? 'var(--bg-panel)' : 'transparent',
                    justifyContent: isCollapsed ? 'center' : 'flex-start',
                    transition: 'all 0.15s ease',
                  })}
                  title={isCollapsed ? item.label : undefined}
                >
                  <Icon size={19} />
                  {!isCollapsed && <span>{item.label}</span>}
                </NavLink>
              </li>
            );
          })}
        </ul>
      </nav>
    </aside>
  );
};
