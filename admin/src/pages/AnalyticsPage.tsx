import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { analyticsApi } from '../services/analyticsApi';
import { BarChart3, Activity, Users, Award, RefreshCw, Code } from 'lucide-react';

export const AnalyticsPage: React.FC = () => {
  const [selectedEventMetadata, setSelectedEventMetadata] = useState<Record<string, unknown> | null>(null);

  const { data: metrics, isLoading, refetch, isFetching } = useQuery({
    queryKey: ['analyticsDashboard'],
    queryFn: () => analyticsApi.getDashboardMetrics(),
    refetchInterval: 15000, // Poll every 15s for live event monitoring
  });

  const eventDistribution = metrics?.eventDistribution || [];
  const recentEvents = metrics?.recentEvents || [];

  const maxEventCount = Math.max(
    ...eventDistribution.map((e) => (typeof e.count === 'string' ? parseInt(e.count, 10) : e.count)),
    1
  );

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Player Analytics & Telemetry</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Telemetry stream, player drop-off checkpoints, and historical quest engagement
          </p>
        </div>
        <button
          className="btn-secondary"
          onClick={() => refetch()}
          disabled={isFetching}
          style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
        >
          <RefreshCw size={14} className={isFetching ? 'spin' : ''} />
          <span>{isFetching ? 'Refreshing...' : 'Refresh Stream'}</span>
        </button>
      </div>

      {/* Top metrics summary cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' }}>
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '8px',
              backgroundColor: 'rgba(184, 92, 56, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--terracotta)',
            }}
          >
            <Activity size={22} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Total Logged Events</div>
            <div style={{ fontSize: '22px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
              {eventDistribution.reduce((acc, curr) => acc + (typeof curr.count === 'string' ? parseInt(curr.count, 10) : curr.count), 0)}
            </div>
          </div>
        </div>

        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '8px',
              backgroundColor: 'rgba(49, 92, 58, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--forest-green)',
            }}
          >
            <Users size={22} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Active Explorers</div>
            <div style={{ fontSize: '22px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
              {metrics?.activePlayers ?? 0}
            </div>
          </div>
        </div>

        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '44px',
              height: '44px',
              borderRadius: '8px',
              backgroundColor: 'rgba(217, 164, 65, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--warm-gold)',
            }}
          >
            <Award size={22} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Published Quests</div>
            <div style={{ fontSize: '22px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
              {metrics?.publishedQuests ?? 0}
            </div>
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '24px' }}>
        {/* Event Distribution Graph */}
        <div className="card">
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
            <BarChart3 size={18} style={{ color: 'var(--terracotta)' }} />
            <h2 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
              Event Type Frequency
            </h2>
          </div>

          {isLoading ? (
            <div style={{ color: 'var(--text-muted)', fontSize: '13px' }}>Loading distribution...</div>
          ) : eventDistribution.length === 0 ? (
            <p style={{ color: 'var(--text-muted)', fontSize: '13px' }}>No telemetry events recorded yet.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {eventDistribution.map((item) => {
                const countNum = typeof item.count === 'string' ? parseInt(item.count, 10) : item.count;
                const percentage = Math.round((countNum / maxEventCount) * 100);

                return (
                  <div key={item.event_type}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '4px' }}>
                      <span style={{ fontWeight: '600', color: 'var(--deep-earth)' }}>
                        {item.event_type.replace(/_/g, ' ')}
                      </span>
                      <span style={{ color: 'var(--text-muted)' }}>{countNum} occurrences</span>
                    </div>
                    <div
                      style={{
                        height: '10px',
                        backgroundColor: 'var(--sand-dark)',
                        borderRadius: '5px',
                        overflow: 'hidden',
                      }}
                    >
                      <div
                        style={{
                          height: '100%',
                          width: `${percentage}%`,
                          backgroundColor:
                            item.event_type.includes('COMPLETED')
                              ? 'var(--forest-green)'
                              : item.event_type.includes('FIND') || item.event_type.includes('COLLECT')
                              ? 'var(--warm-gold)'
                              : 'var(--terracotta)',
                          borderRadius: '5px',
                        }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Live Telemetry Feed */}
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Activity size={18} style={{ color: 'var(--forest-green)' }} />
              <h2 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                Recent Ingested Events
              </h2>
            </div>
            <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Auto-updating</span>
          </div>

          {isLoading ? (
            <div style={{ color: 'var(--text-muted)', fontSize: '13px' }}>Loading live feed...</div>
          ) : recentEvents.length === 0 ? (
            <p style={{ color: 'var(--text-muted)', fontSize: '13px' }}>No events recorded recently.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', maxHeight: '380px', overflowY: 'auto' }}>
              {recentEvents.map((event) => (
                <div
                  key={event.id}
                  style={{
                    padding: '10px 12px',
                    borderRadius: '6px',
                    backgroundColor: 'var(--sand-light)',
                    border: '1px solid var(--sand-dark)',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    cursor: 'pointer',
                  }}
                  onClick={() => setSelectedEventMetadata(event.metadata)}
                >
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span
                        style={{
                          fontSize: '11px',
                          fontWeight: '700',
                          color: 'var(--terracotta)',
                        }}
                      >
                        {event.event_type}
                      </span>
                      {event.chapter_id && (
                        <span
                          style={{
                            fontSize: '10px',
                            backgroundColor: 'var(--sand-dark)',
                            padding: '1px 6px',
                            borderRadius: '3px',
                            color: 'var(--deep-earth)',
                          }}
                        >
                          {event.chapter_id}
                        </span>
                      )}
                    </div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>
                      {new Date(event.created_at).toLocaleTimeString()} - {new Date(event.created_at).toLocaleDateString()}
                    </div>
                  </div>
                  <button
                    className="btn-secondary"
                    style={{ padding: '4px 8px', fontSize: '11px', display: 'flex', alignItems: 'center', gap: '4px' }}
                    onClick={(e) => {
                      e.stopPropagation();
                      setSelectedEventMetadata(event.metadata);
                    }}
                  >
                    <Code size={12} />
                    <span>Payload</span>
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Event Payload Inspector Modal */}
      {selectedEventMetadata && (
        <div className="modal-backdrop">
          <div className="modal-card" style={{ maxWidth: '500px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                Telemetry Event Payload
              </h3>
              <button
                className="btn-secondary"
                style={{ padding: '4px 8px' }}
                onClick={() => setSelectedEventMetadata(null)}
              >
                ✕
              </button>
            </div>

            <pre
              style={{
                backgroundColor: '#211C18',
                color: '#F7F0DE',
                padding: '16px',
                borderRadius: '8px',
                fontSize: '12px',
                lineHeight: '1.5',
                overflowX: 'auto',
                maxHeight: '300px',
              }}
            >
              {JSON.stringify(selectedEventMetadata, null, 2)}
            </pre>

            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '16px' }}>
              <button className="btn-primary" onClick={() => setSelectedEventMetadata(null)}>
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
