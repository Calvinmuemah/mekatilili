import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { authApi } from '../services/authApi';
import { apiClient } from '../services/api';
import { Shield, Server, Database, Gamepad2, Download, LogOut, CheckCircle2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export const SettingsPage: React.FC = () => {
  const navigate = useNavigate();

  const { data: admin } = useQuery({
    queryKey: ['adminMe'],
    queryFn: () => authApi.getMe(),
  });

  const handleLogout = async () => {
    await authApi.logout();
    navigate('/login');
  };

  const downloadContentBundle = async () => {
    try {
      const res = await apiClient.get('/content/bundle');
      const blob = new Blob([JSON.stringify(res.data.data, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `mekatilili-content-bundle-${new Date().toISOString().slice(0, 10)}.json`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch {
      alert('Failed to download content bundle');
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Admin Settings & Environment</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            System configuration, active credentials, Godot offline sync, and database health
          </p>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        {/* Active Administrator Account */}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '8px',
                backgroundColor: 'rgba(184, 92, 56, 0.12)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'var(--terracotta)',
              }}
            >
              <Shield size={20} />
            </div>
            <div>
              <h2 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                Active Session
              </h2>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Role-based Access Control</span>
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '20px' }}>
            <div>
              <label style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600' }}>
                Administrator Name
              </label>
              <div style={{ fontSize: '14px', fontWeight: '600', color: 'var(--deep-earth)' }}>
                {admin?.name || 'Administrator'}
              </div>
            </div>

            <div>
              <label style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600' }}>
                Email Address
              </label>
              <div style={{ fontSize: '14px', color: 'var(--deep-earth)' }}>{admin?.email || 'admin@mekatilili.org'}</div>
            </div>

            <div>
              <label style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: '600' }}>
                Assigned Role
              </label>
              <div>
                <span
                  style={{
                    backgroundColor: 'rgba(217, 164, 65, 0.2)',
                    color: 'var(--deep-earth)',
                    padding: '3px 8px',
                    borderRadius: '4px',
                    fontSize: '12px',
                    fontWeight: '700',
                  }}
                >
                  {admin?.role || 'SUPER_ADMIN'}
                </span>
              </div>
            </div>
          </div>

          <button
            className="btn-secondary"
            onClick={handleLogout}
            style={{ color: 'var(--terracotta)', display: 'flex', alignItems: 'center', gap: '6px' }}
          >
            <LogOut size={16} />
            <span>Sign Out Session</span>
          </button>
        </div>

        {/* Offline Engine Sync & Content Export */}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '8px',
                backgroundColor: 'rgba(49, 92, 58, 0.12)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'var(--forest-green)',
              }}
            >
              <Gamepad2 size={20} />
            </div>
            <div>
              <h2 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                Godot 4 Offline Sync
              </h2>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Offline First Architecture</span>
            </div>
          </div>

          <p style={{ fontSize: '13px', color: 'var(--deep-earth)', lineHeight: '1.5', marginBottom: '16px' }}>
            The Mekatilili wa Menza game client operates 100% offline using bundled GDScript data. You can download the complete published content bundle JSON to update local game assets or test cloud sync.
          </p>

          <button
            className="btn-primary"
            onClick={downloadContentBundle}
            style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}
          >
            <Download size={16} />
            <span>Export Published Content Bundle</span>
          </button>

          <div
            style={{
              backgroundColor: 'rgba(49, 92, 58, 0.08)',
              border: '1px solid rgba(49, 92, 58, 0.2)',
              borderRadius: '6px',
              padding: '10px 12px',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              fontSize: '12px',
              color: 'var(--forest-green)',
            }}
          >
            <CheckCircle2 size={16} />
            <span>Backend is an enhancement; Godot client never blocks without a connection.</span>
          </div>
        </div>
      </div>

      {/* Infrastructure Card */}
      <div className="card" style={{ marginTop: '20px' }}>
        <h2 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)', marginBottom: '16px' }}>
          Platform Infrastructure
        </h2>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <Server size={20} style={{ color: 'var(--terracotta)' }} />
            <div>
              <div style={{ fontSize: '13px', fontWeight: '600', color: 'var(--deep-earth)' }}>Express API Gateway</div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Node.js 18+ • REST v1</div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <Database size={20} style={{ color: 'var(--forest-green)' }} />
            <div>
              <div style={{ fontSize: '13px', fontWeight: '600', color: 'var(--deep-earth)' }}>PostgreSQL 16</div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Parameterized SQL (no ORM) • pg driver</div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <Gamepad2 size={20} style={{ color: 'var(--warm-gold)' }} />
            <div>
              <div style={{ fontSize: '13px', fontWeight: '600', color: 'var(--deep-earth)' }}>Target Platform</div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Godot 4.3 Mobile / Android 2D</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
