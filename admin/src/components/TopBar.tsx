import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, LogOut, ShieldCheck } from 'lucide-react';
import { authApi } from '../services/authApi';
import { Admin } from '../types';

interface TopBarProps {
  admin: Admin | null;
}

export const TopBar: React.FC<TopBarProps> = ({ admin }) => {
  const navigate = useNavigate();

  const handleLogout = () => {
    authApi.logout();
    navigate('/login');
  };

  return (
    <header style={{
      height: '64px',
      backgroundColor: 'var(--bg-surface)',
      borderBottom: '1px solid var(--border-color)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 24px',
      position: 'sticky',
      top: 0,
      zIndex: 50,
    }}>
      {/* Search Input */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', width: '320px' }}>
        <div style={{ position: 'relative', width: '100%' }}>
          <Search size={16} style={{ position: 'absolute', left: '12px', top: '12px', color: 'var(--text-muted)' }} />
          <input
            type="text"
            placeholder="Search chapters, quests, NPCs..."
            className="input-field"
            style={{ paddingLeft: '36px', height: '38px' }}
          />
        </div>
      </div>

      {/* Admin Profile & Logout */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        {admin && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <div style={{
              width: '36px',
              height: '36px',
              borderRadius: '50%',
              backgroundColor: 'var(--sand)',
              color: 'var(--deep-earth)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: '600',
              fontSize: '14px',
              border: '1px solid var(--warm-gold)',
            }}>
              {admin.name.charAt(0)}
            </div>
            <div style={{ textAlign: 'left' }}>
              <div style={{ fontSize: '14px', fontWeight: '600', color: 'var(--deep-earth)' }}>
                {admin.name}
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', color: 'var(--forest-green)', fontWeight: '600' }}>
                <ShieldCheck size={12} />
                <span>{admin.role}</span>
              </div>
            </div>
          </div>
        )}

        <button
          onClick={handleLogout}
          className="btn-secondary"
          style={{ padding: '6px 12px', fontSize: '13px' }}
          title="Sign out of Admin Portal"
        >
          <LogOut size={15} />
          <span>Logout</span>
        </button>
      </div>
    </header>
  );
};
