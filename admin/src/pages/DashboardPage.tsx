import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { analyticsApi } from '../services/analyticsApi';
import { Users, BookOpen, Compass, Sparkles, Activity, Award } from 'lucide-react';

export const DashboardPage: React.FC = () => {
  const { data: metrics, isLoading, isError } = useQuery({
    queryKey: ['analytics-dashboard'],
    queryFn: analyticsApi.getDashboardMetrics,
  });

  if (isLoading) {
    return <div style={{ padding: '24px', color: 'var(--text-muted)' }}>Loading dashboard metrics...</div>;
  }

  if (isError || !metrics) {
    return (
      <div className="card" style={{ padding: '32px', textAlign: 'center' }}>
        <p style={{ color: '#C53030' }}>Unable to load analytics metrics from backend service.</p>
      </div>
    );
  }

  const statCards = [
    { label: 'Total Players', value: metrics.totalPlayers, icon: Users, color: 'var(--terracotta)' },
    { label: 'Active Players (30d)', value: metrics.activePlayers, icon: Activity, color: 'var(--forest-green)' },
    { label: 'Published Chapters', value: metrics.publishedChapters, icon: BookOpen, color: 'var(--warm-gold)' },
    { label: 'Published Quests', value: metrics.publishedQuests, icon: Compass, color: 'var(--deep-earth)' },
    { label: 'Active NPCs', value: metrics.activeNPCs, icon: Users, color: '#4B5563' },
    { label: 'Cultural Collectibles', value: metrics.publishedCollectibles, icon: Sparkles, color: '#9333EA' },
  ];

  return (
    <div>
      <div style={{ marginBottom: '28px' }}>
        <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Dashboard Overview</h1>
        <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
          Real-time metrics and content status for Mekatilili wa Menza game
        </p>
      </div>

      {/* KPI Cards Grid */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
        gap: '20px',
        marginBottom: '32px',
      }}>
        {statCards.map((stat, idx) => {
          const Icon = stat.icon;
          return (
            <div key={idx} className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
              <div style={{
                width: '48px',
                height: '48px',
                borderRadius: '10px',
                backgroundColor: 'var(--bg-panel)',
                color: stat.color,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}>
                <Icon size={24} />
              </div>
              <div>
                <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{stat.label}</span>
                <div style={{ fontSize: '22px', fontWeight: 'bold', color: 'var(--deep-earth)', marginTop: '2px' }}>
                  {stat.value}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Analytics Breakdown & Recent Activity */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', gap: '24px' }}>
        {/* Event Distribution */}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '18px' }}>
            <Award size={20} color="var(--terracotta)" />
            <h3 style={{ fontSize: '16px', color: 'var(--deep-earth)' }}>Gameplay Event Distribution</h3>
          </div>
          {metrics.eventDistribution.length === 0 ? (
            <p style={{ color: 'var(--text-muted)', fontSize: '14px' }}>No gameplay events recorded yet.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {metrics.eventDistribution.map((item, idx) => (
                <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '8px 12px', backgroundColor: 'var(--bg-primary)', borderRadius: '6px' }}>
                  <span style={{ fontSize: '14px', fontWeight: '500', color: 'var(--deep-earth)' }}>
                    {item.event_type}
                  </span>
                  <span style={{ fontSize: '14px', fontWeight: 'bold', color: 'var(--terracotta)' }}>
                    {item.count}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Recent Events Log */}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '18px' }}>
            <Activity size={20} color="var(--forest-green)" />
            <h3 style={{ fontSize: '16px', color: 'var(--deep-earth)' }}>Recent Gameplay Ingestion</h3>
          </div>
          {metrics.recentEvents.length === 0 ? (
            <p style={{ color: 'var(--text-muted)', fontSize: '14px' }}>No recent events found.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {metrics.recentEvents.map((evt) => (
                <div key={evt.id} style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', paddingBottom: '8px', borderBottom: '1px solid var(--border-color)' }}>
                  <span style={{ fontWeight: '600', color: 'var(--deep-earth)' }}>{evt.event_type}</span>
                  <span style={{ color: 'var(--text-muted)' }}>{new Date(evt.created_at).toLocaleTimeString()}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
