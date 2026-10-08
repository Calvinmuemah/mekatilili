import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { Users, Search, Award, Compass, ShieldCheck } from 'lucide-react';

export const PlayersPage: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');

  const { data, isLoading } = useQuery({
    queryKey: ['players'],
    queryFn: () => contentApi.getPlayers(100, 0),
  });

  const players = data?.users || [];
  const total = data?.total || 0;

  const filteredPlayers = players.filter(
    (p) =>
      p.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.display_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const avgProgress =
    players.length > 0
      ? Math.round(
          players.reduce((sum, p) => sum + (p.progress_percentage || 0), 0) / players.length
        )
      : 0;

  const avgUnity =
    players.length > 0
      ? Math.round(
          players.reduce((sum, p) => sum + (p.community_unity || 0), 0) / players.length
        )
      : 0;

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Player Accounts & Progress</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Registered mobile and cloud players, story progress, and community unity metrics
          </p>
        </div>
      </div>

      {/* Summary Metrics */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px', marginBottom: '24px' }}>
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
            <Users size={22} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Registered Players</div>
            <div style={{ fontSize: '22px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>{total}</div>
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
            <Compass size={22} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Avg. Chapter Progress</div>
            <div style={{ fontSize: '22px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>{avgProgress}%</div>
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
            <Award size={22} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Avg. Community Unity</div>
            <div style={{ fontSize: '22px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>{avgUnity}</div>
          </div>
        </div>
      </div>

      {/* Search Input */}
      <div style={{ marginBottom: '16px', position: 'relative', maxWidth: '380px' }}>
        <Search
          size={16}
          style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }}
        />
        <input
          type="text"
          className="input"
          style={{ paddingLeft: '36px' }}
          placeholder="Search by player, email, username..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      {/* Players Table */}
      {isLoading ? (
        <div style={{ color: 'var(--text-muted)' }}>Loading player data...</div>
      ) : filteredPlayers.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '48px' }}>
          <Users size={40} style={{ color: 'var(--warm-gold)', margin: '0 auto 12px auto' }} />
          <h3 style={{ fontSize: '18px', color: 'var(--deep-earth)' }}>No players found</h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '6px' }}>
            When players register in the mobile app, their profiles and cloud sync progress will show here.
          </p>
        </div>
      ) : (
        <div className="card" style={{ padding: '0', overflowX: 'auto' }}>
          <table className="table">
            <thead>
              <tr>
                <th>Player</th>
                <th>Email</th>
                <th>Current Chapter</th>
                <th>Story Progress</th>
                <th>Community Unity</th>
                <th>Status</th>
                <th>Joined</th>
              </tr>
            </thead>
            <tbody>
              {filteredPlayers.map((player) => (
                <tr key={player.id}>
                  <td>
                    <div style={{ fontWeight: '600', color: 'var(--deep-earth)' }}>
                      {player.display_name || player.username}
                    </div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>@{player.username}</div>
                  </td>
                  <td style={{ fontSize: '13px', color: 'var(--deep-earth)' }}>{player.email}</td>
                  <td>
                    <span
                      style={{
                        backgroundColor: 'var(--sand-dark)',
                        padding: '2px 8px',
                        borderRadius: '4px',
                        fontSize: '12px',
                        fontWeight: '600',
                        color: 'var(--deep-earth)',
                      }}
                    >
                      Chapter {player.current_chapter ?? 1}
                    </span>
                  </td>
                  <td style={{ width: '160px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <div
                        style={{
                          flex: 1,
                          height: '8px',
                          backgroundColor: 'var(--sand-dark)',
                          borderRadius: '4px',
                          overflow: 'hidden',
                        }}
                      >
                        <div
                          style={{
                            height: '100%',
                            width: `${Math.min(100, player.progress_percentage || 0)}%`,
                            backgroundColor: 'var(--terracotta)',
                            borderRadius: '4px',
                          }}
                        />
                      </div>
                      <span style={{ fontSize: '12px', fontWeight: '600', color: 'var(--deep-earth)', width: '32px' }}>
                        {player.progress_percentage || 0}%
                      </span>
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <Award size={14} style={{ color: 'var(--warm-gold)' }} />
                      <span style={{ fontWeight: '600', color: 'var(--deep-earth)', fontSize: '13px' }}>
                        {player.community_unity || 0}
                      </span>
                    </div>
                  </td>
                  <td>
                    {player.is_active ? (
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '4px',
                          color: 'var(--forest-green)',
                          fontSize: '12px',
                          fontWeight: '600',
                        }}
                      >
                        <ShieldCheck size={14} /> Active
                      </span>
                    ) : (
                      <span style={{ color: 'var(--text-muted)', fontSize: '12px' }}>Inactive</span>
                    )}
                  </td>
                  <td style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                    {new Date(player.created_at).toLocaleDateString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};
