import React, { useState, useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { User } from '../types';
import {
  Users,
  Search,
  Award,
  Compass,
  ShieldCheck,
  RefreshCw,
  Mail,
  Calendar,
  X,
  Eye,
  CheckCircle2,
} from 'lucide-react';

const AVATAR_COLORS = [
  { bg: 'rgba(184, 92, 56, 0.15)', text: '#B85C38', border: '#B85C38' },
  { bg: 'rgba(217, 164, 65, 0.20)', text: '#A8761E', border: '#D9A441' },
  { bg: 'rgba(49, 92, 58, 0.15)', text: '#315C3A', border: '#315C3A' },
  { bg: 'rgba(59, 36, 22, 0.15)', text: '#3B2416', border: '#3B2416' },
];

function getAvatarStyle(str: string) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = str.charCodeAt(i) + ((hash << 5) - hash);
  }
  const idx = Math.abs(hash) % AVATAR_COLORS.length;
  return AVATAR_COLORS[idx];
}

export const PlayersPage: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedChapter, setSelectedChapter] = useState<string>('ALL');
  const [selectedStatus, setSelectedStatus] = useState<string>('ALL');
  const [sortBy, setSortBy] = useState<string>('RECENT');
  const [selectedPlayer, setSelectedPlayer] = useState<User | null>(null);

  const { data, isLoading, refetch, isFetching } = useQuery({
    queryKey: ['players'],
    queryFn: () => contentApi.getPlayers(100, 0),
  });

  const players = data?.users || [];
  const total = data?.total || players.length;

  // Filtered and sorted players
  const filteredPlayers = useMemo(() => {
    return players
      .filter((p) => {
        const matchesSearch =
          p.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
          p.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
          (p.display_name && p.display_name.toLowerCase().includes(searchTerm.toLowerCase()));

        const matchesChapter =
          selectedChapter === 'ALL' || (p.current_chapter ?? 1) === parseInt(selectedChapter, 10);

        const matchesStatus =
          selectedStatus === 'ALL' ||
          (selectedStatus === 'ACTIVE' && p.is_active) ||
          (selectedStatus === 'INACTIVE' && !p.is_active);

        return matchesSearch && matchesChapter && matchesStatus;
      })
      .sort((a, b) => {
        if (sortBy === 'NAME') {
          return (a.display_name || a.username).localeCompare(b.display_name || b.username);
        }
        if (sortBy === 'PROGRESS') {
          return (b.progress_percentage || 0) - (a.progress_percentage || 0);
        }
        if (sortBy === 'UNITY') {
          return (b.community_unity || 0) - (a.community_unity || 0);
        }
        // Default: RECENT
        return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
      });
  }, [players, searchTerm, selectedChapter, selectedStatus, sortBy]);

  const activeCount = players.filter((p) => p.is_active).length;

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

  const isFiltering = searchTerm !== '' || selectedChapter !== 'ALL' || selectedStatus !== 'ALL';

  const resetFilters = () => {
    setSearchTerm('');
    setSelectedChapter('ALL');
    setSelectedStatus('ALL');
    setSortBy('RECENT');
  };

  return (
    <div>
      {/* Page Title & Controls */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '24px',
          flexWrap: 'wrap',
          gap: '12px',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>
              Player Accounts & Progress
            </h1>
            <span
              className="badge badge-published"
              style={{ fontSize: '12px', padding: '4px 10px' }}
            >
              {total} Total Players
            </span>
          </div>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Registered mobile and cloud players, story progress, and community unity metrics
          </p>
        </div>

        <button
          className="btn-secondary"
          onClick={() => refetch()}
          disabled={isFetching}
          style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
        >
          <RefreshCw size={14} className={isFetching ? 'spin' : ''} />
          <span>{isFetching ? 'Refreshing...' : 'Refresh Players'}</span>
        </button>
      </div>

      {/* Summary KPI Cards Grid (4 Balanced Columns) */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
          gap: '16px',
          marginBottom: '24px',
        }}
      >
        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '10px',
              backgroundColor: 'rgba(184, 92, 56, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--terracotta)',
              flexShrink: 0,
            }}
          >
            <Users size={24} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>
              Registered Players
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: 'var(--deep-earth)', marginTop: '2px' }}>
              {total}
            </div>
          </div>
        </div>

        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '10px',
              backgroundColor: 'rgba(49, 92, 58, 0.12)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--forest-green)',
              flexShrink: 0,
            }}
          >
            <ShieldCheck size={24} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>
              Active Cloud Players
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: 'var(--deep-earth)', marginTop: '2px' }}>
              {activeCount}
            </div>
          </div>
        </div>

        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '10px',
              backgroundColor: 'rgba(217, 164, 65, 0.18)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#A8761E',
              flexShrink: 0,
            }}
          >
            <Compass size={24} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>
              Avg. Chapter Progress
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: 'var(--deep-earth)', marginTop: '2px' }}>
              {avgProgress}%
            </div>
          </div>
        </div>

        <div className="card" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '10px',
              backgroundColor: 'rgba(59, 36, 22, 0.10)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'var(--deep-earth)',
              flexShrink: 0,
            }}
          >
            <Award size={24} />
          </div>
          <div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>
              Avg. Community Unity
            </div>
            <div style={{ fontSize: '24px', fontWeight: 'bold', color: 'var(--deep-earth)', marginTop: '2px' }}>
              {avgUnity} <span style={{ fontSize: '13px', fontWeight: '500', color: 'var(--text-muted)' }}>pts</span>
            </div>
          </div>
        </div>
      </div>

      {/* Filter and Search Toolbar */}
      <div
        className="card"
        style={{
          padding: '16px 20px',
          marginBottom: '20px',
          display: 'flex',
          flexWrap: 'wrap',
          gap: '14px',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <div style={{ display: 'flex', flex: 1, minWidth: '280px', maxWidth: '440px', position: 'relative' }}>
          <Search
            size={16}
            style={{
              position: 'absolute',
              left: '14px',
              top: '50%',
              transform: 'translateY(-50%)',
              color: 'var(--text-muted)',
            }}
          />
          <input
            type="text"
            className="input"
            style={{ paddingLeft: '38px', paddingRight: searchTerm ? '36px' : '14px', height: '40px' }}
            placeholder="Search by player, email, @username..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          {searchTerm && (
            <button
              onClick={() => setSearchTerm('')}
              style={{
                position: 'absolute',
                right: '12px',
                top: '50%',
                transform: 'translateY(-50%)',
                color: 'var(--text-muted)',
              }}
              title="Clear search"
            >
              <X size={16} />
            </button>
          )}
        </div>

        {/* Filters and Sort */}
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', alignItems: 'center' }}>
          {/* Chapter Filter */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>Chapter:</span>
            <select
              className="input"
              value={selectedChapter}
              onChange={(e) => setSelectedChapter(e.target.value)}
              style={{ height: '40px', padding: '6px 12px', minWidth: '130px', fontSize: '13px' }}
            >
              <option value="ALL">All Chapters</option>
              <option value="1">Chapter 1</option>
              <option value="2">Chapter 2</option>
              <option value="3">Chapter 3</option>
            </select>
          </div>

          {/* Status Filter */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>Status:</span>
            <select
              className="input"
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              style={{ height: '40px', padding: '6px 12px', minWidth: '120px', fontSize: '13px' }}
            >
              <option value="ALL">All Status</option>
              <option value="ACTIVE">Active</option>
              <option value="INACTIVE">Offline</option>
            </select>
          </div>

          {/* Sort By */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: '600' }}>Sort:</span>
            <select
              className="input"
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              style={{ height: '40px', padding: '6px 12px', minWidth: '140px', fontSize: '13px' }}
            >
              <option value="RECENT">Recently Joined</option>
              <option value="NAME">Name (A-Z)</option>
              <option value="PROGRESS">Highest Progress</option>
              <option value="UNITY">Highest Unity</option>
            </select>
          </div>

          {isFiltering && (
            <button
              className="btn-secondary"
              onClick={resetFilters}
              style={{ height: '40px', padding: '0 12px', fontSize: '12px' }}
            >
              Reset Filters
            </button>
          )}
        </div>
      </div>

      {/* Players Table Container */}
      {isLoading ? (
        <div className="card" style={{ textAlign: 'center', padding: '48px', color: 'var(--text-muted)' }}>
          <RefreshCw size={32} className="spin" style={{ margin: '0 auto 12px auto', color: 'var(--terracotta)' }} />
          <p>Loading player accounts and telemetry progress...</p>
        </div>
      ) : filteredPlayers.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '48px' }}>
          <Users size={44} style={{ color: 'var(--warm-gold)', margin: '0 auto 14px auto' }} />
          <h3 style={{ fontSize: '18px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>
            {isFiltering ? 'No matching players found' : 'No players registered yet'}
          </h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '6px', maxWidth: '440px', margin: '6px auto 16px auto' }}>
            {isFiltering
              ? 'Try adjusting your search criteria or clearing your filters to see more accounts.'
              : 'When players register in the mobile game or sync saves via cloud, their accounts will appear here automatically.'}
          </p>
          {isFiltering && (
            <button className="btn-primary" onClick={resetFilters}>
              Clear Search & Filters
            </button>
          )}
        </div>
      ) : (
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th style={{ minWidth: '220px' }}>Player</th>
                <th style={{ minWidth: '240px' }}>Email Address</th>
                <th style={{ minWidth: '140px' }}>Current Chapter</th>
                <th style={{ minWidth: '180px' }}>Story Progress</th>
                <th style={{ minWidth: '150px' }}>Community Unity</th>
                <th style={{ minWidth: '120px' }}>Status</th>
                <th style={{ minWidth: '130px' }}>Joined</th>
                <th style={{ minWidth: '90px', textAlign: 'center' }}>Details</th>
              </tr>
            </thead>
            <tbody>
              {filteredPlayers.map((player) => {
                const displayName = player.display_name || player.username;
                const avatar = getAvatarStyle(player.username);
                const initial = (displayName.charAt(0) || player.username.charAt(0) || 'P').toUpperCase();
                const progress = Math.min(100, Math.max(0, player.progress_percentage || 0));

                return (
                  <tr key={player.id}>
                    {/* Player Info */}
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div
                          style={{
                            width: '38px',
                            height: '38px',
                            borderRadius: '50%',
                            backgroundColor: avatar.bg,
                            color: avatar.text,
                            border: `1.5px solid ${avatar.border}`,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontWeight: '700',
                            fontSize: '15px',
                            flexShrink: 0,
                          }}
                        >
                          {initial}
                        </div>
                        <div>
                          <div style={{ fontWeight: '700', color: 'var(--deep-earth)', fontSize: '14px' }}>
                            {displayName}
                          </div>
                          <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '1px' }}>
                            @{player.username}
                          </div>
                        </div>
                      </div>
                    </td>

                    {/* Email */}
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <Mail size={14} style={{ color: 'var(--text-muted)', flexShrink: 0 }} />
                        <span style={{ fontSize: '13px', color: 'var(--deep-earth)', wordBreak: 'break-all' }}>
                          {player.email}
                        </span>
                      </div>
                    </td>

                    {/* Chapter */}
                    <td>
                      <span
                        style={{
                          backgroundColor: 'var(--sand-light)',
                          border: '1px solid var(--sand-dark)',
                          padding: '4px 10px',
                          borderRadius: '14px',
                          fontSize: '12px',
                          fontWeight: '700',
                          color: 'var(--deep-earth)',
                          display: 'inline-block',
                          whiteSpace: 'nowrap',
                        }}
                      >
                        Chapter {player.current_chapter ?? 1}
                      </span>
                    </td>

                    {/* Story Progress */}
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <div
                          style={{
                            flex: 1,
                            height: '8px',
                            backgroundColor: 'var(--sand-light)',
                            border: '1px solid var(--sand-dark)',
                            borderRadius: '4px',
                            overflow: 'hidden',
                          }}
                        >
                          <div
                            style={{
                              height: '100%',
                              width: `${progress}%`,
                              backgroundColor: progress === 100 ? 'var(--forest-green)' : 'var(--terracotta)',
                              borderRadius: '4px',
                              transition: 'width 0.3s ease',
                            }}
                          />
                        </div>
                        <span
                          style={{
                            fontSize: '13px',
                            fontWeight: '700',
                            color: 'var(--deep-earth)',
                            minWidth: '38px',
                            textAlign: 'right',
                          }}
                        >
                          {progress}%
                        </span>
                      </div>
                    </td>

                    {/* Community Unity */}
                    <td>
                      <div
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '6px',
                          backgroundColor: 'rgba(217, 164, 65, 0.12)',
                          border: '1px solid rgba(217, 164, 65, 0.3)',
                          padding: '3px 10px',
                          borderRadius: '12px',
                        }}
                      >
                        <Award size={14} style={{ color: '#A8761E' }} />
                        <span style={{ fontWeight: '700', color: 'var(--deep-earth)', fontSize: '13px' }}>
                          {player.community_unity || 0} pts
                        </span>
                      </div>
                    </td>

                    {/* Status */}
                    <td>
                      {player.is_active ? (
                        <span className="badge badge-active">
                          <CheckCircle2 size={12} /> Active
                        </span>
                      ) : (
                        <span className="badge badge-inactive">Offline</span>
                      )}
                    </td>

                    {/* Joined Date */}
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-muted)', fontSize: '12px' }}>
                        <Calendar size={13} />
                        <span>{new Date(player.created_at).toLocaleDateString()}</span>
                      </div>
                    </td>

                    {/* Details Action */}
                    <td style={{ textAlign: 'center' }}>
                      <button
                        className="btn-secondary"
                        onClick={() => setSelectedPlayer(player)}
                        style={{ padding: '6px 10px', fontSize: '12px' }}
                        title="View Player Profile"
                      >
                        <Eye size={14} />
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {/* Player Details Modal */}
      {selectedPlayer && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(33, 28, 24, 0.6)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 100,
            padding: '20px',
          }}
          onClick={() => setSelectedPlayer(null)}
        >
          <div
            className="card"
            style={{
              width: '100%',
              maxWidth: '540px',
              padding: '28px',
              backgroundColor: 'var(--bg-surface)',
              border: '2px solid var(--warm-gold)',
              boxShadow: '0 8px 32px rgba(33, 28, 24, 0.2)',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                <div
                  style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '50%',
                    backgroundColor: getAvatarStyle(selectedPlayer.username).bg,
                    color: getAvatarStyle(selectedPlayer.username).text,
                    border: `2px solid ${getAvatarStyle(selectedPlayer.username).border}`,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontWeight: 'bold',
                    fontSize: '18px',
                  }}
                >
                  {(selectedPlayer.display_name || selectedPlayer.username).charAt(0).toUpperCase()}
                </div>
                <div>
                  <h3 style={{ fontSize: '18px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                    {selectedPlayer.display_name || selectedPlayer.username}
                  </h3>
                  <div style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                    @{selectedPlayer.username}
                  </div>
                </div>
              </div>
              <button
                className="btn-secondary"
                style={{ padding: '6px 10px' }}
                onClick={() => setSelectedPlayer(null)}
              >
                <X size={16} />
              </button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div style={{ padding: '12px', backgroundColor: 'var(--bg-panel)', borderRadius: '8px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 'bold', textTransform: 'uppercase' }}>
                    Email Address
                  </div>
                  <div style={{ fontSize: '13px', fontWeight: '600', color: 'var(--deep-earth)', marginTop: '2px', wordBreak: 'break-all' }}>
                    {selectedPlayer.email}
                  </div>
                </div>

                <div style={{ padding: '12px', backgroundColor: 'var(--bg-panel)', borderRadius: '8px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 'bold', textTransform: 'uppercase' }}>
                    Account Status
                  </div>
                  <div style={{ marginTop: '4px' }}>
                    {selectedPlayer.is_active ? (
                      <span className="badge badge-active">
                        <CheckCircle2 size={12} /> Active Cloud Account
                      </span>
                    ) : (
                      <span className="badge badge-inactive">Offline Account</span>
                    )}
                  </div>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div style={{ padding: '12px', backgroundColor: 'var(--bg-panel)', borderRadius: '8px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 'bold', textTransform: 'uppercase' }}>
                    Current Chapter
                  </div>
                  <div style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--terracotta)', marginTop: '2px' }}>
                    Chapter {selectedPlayer.current_chapter ?? 1}
                  </div>
                </div>

                <div style={{ padding: '12px', backgroundColor: 'var(--bg-panel)', borderRadius: '8px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: 'bold', textTransform: 'uppercase' }}>
                    Community Unity
                  </div>
                  <div style={{ fontSize: '16px', fontWeight: 'bold', color: '#A8761E', marginTop: '2px' }}>
                    {selectedPlayer.community_unity || 0} Points
                  </div>
                </div>
              </div>

              <div style={{ padding: '12px', backgroundColor: 'var(--bg-panel)', borderRadius: '8px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: 'bold', textTransform: 'uppercase' }}>
                    Story Completion
                  </span>
                  <span style={{ fontSize: '13px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                    {selectedPlayer.progress_percentage || 0}%
                  </span>
                </div>
                <div
                  style={{
                    width: '100%',
                    height: '8px',
                    backgroundColor: 'var(--sand)',
                    borderRadius: '4px',
                    overflow: 'hidden',
                  }}
                >
                  <div
                    style={{
                      height: '100%',
                      width: `${Math.min(100, Math.max(0, selectedPlayer.progress_percentage || 0))}%`,
                      backgroundColor: 'var(--terracotta)',
                      borderRadius: '4px',
                    }}
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', fontSize: '12px', color: 'var(--text-muted)' }}>
                <div>Joined: {new Date(selectedPlayer.created_at).toLocaleString()}</div>
                <div>ID: <span style={{ fontFamily: 'monospace' }}>{selectedPlayer.id.substring(0, 12)}...</span></div>
              </div>
            </div>

            <div style={{ marginTop: '24px', display: 'flex', justifyContent: 'flex-end' }}>
              <button className="btn-secondary" onClick={() => setSelectedPlayer(null)}>
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
