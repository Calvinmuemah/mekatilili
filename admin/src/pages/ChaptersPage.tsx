import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { Chapter, ContentStatus } from '../types';
import { StatusBadge } from '../components/StatusBadge';
import { ConfirmModal } from '../components/ConfirmModal';
import { Plus, Edit, Archive, CheckCircle } from 'lucide-react';

export const ChaptersPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [filter, setFilter] = useState<string>('ALL');
  const [editingChapter, setEditingChapter] = useState<Chapter | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [archiveTarget, setArchiveTarget] = useState<Chapter | null>(null);

  // Form states
  const [formData, setFormData] = useState({
    id: '',
    chapter_number: 1,
    title: '',
    subtitle: '',
    description: '',
    historical_note: '',
    scene_path: 'res://scenes/environments/VillageLevel.tscn',
    status: 'DRAFT' as ContentStatus,
  });

  const { data: chapters = [], isLoading } = useQuery({
    queryKey: ['chapters', filter],
    queryFn: () => contentApi.getChapters(filter === 'ALL' ? undefined : filter),
  });

  const saveMutation = useMutation({
    mutationFn: (data: typeof formData) => {
      if (editingChapter) {
        return contentApi.updateChapter(editingChapter.id, {
          chapter_number: data.chapter_number,
          title: data.title,
          subtitle: data.subtitle,
          description: data.description,
          historical_note: data.historical_note,
          scene_path: data.scene_path,
          status: data.status,
        });
      }
      return contentApi.createChapter({
        id: data.id,
        chapter_number: data.chapter_number,
        title: data.title,
        subtitle: data.subtitle,
        description: data.description,
        historical_note: data.historical_note,
        scene_path: data.scene_path,
        status: data.status,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['chapters'] });
      setIsModalOpen(false);
      setEditingChapter(null);
    },
  });

  const statusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: ContentStatus }) =>
      contentApi.setChapterStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['chapters'] });
      setArchiveTarget(null);
    },
  });

  const openCreateModal = () => {
    setEditingChapter(null);
    setFormData({
      id: `chapter_${chapters.length + 1}`,
      chapter_number: chapters.length + 1,
      title: '',
      subtitle: '',
      description: '',
      historical_note: '',
      scene_path: 'res://scenes/environments/VillageLevel.tscn',
      status: 'DRAFT',
    });
    setIsModalOpen(true);
  };

  const openEditModal = (ch: Chapter) => {
    setEditingChapter(ch);
    setFormData({
      id: ch.id,
      chapter_number: ch.chapter_number,
      title: ch.title,
      subtitle: ch.subtitle || '',
      description: ch.description,
      historical_note: ch.historical_note || '',
      scene_path: ch.scene_path || 'res://scenes/environments/VillageLevel.tscn',
      status: ch.status,
    });
    setIsModalOpen(true);
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Chapter Management</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Author, review, publish, and structure chapters for Mekatilili's journey
          </p>
        </div>
        <button className="btn-primary" onClick={openCreateModal}>
          <Plus size={16} />
          <span>New Chapter</span>
        </button>
      </div>

      {/* Filter Tabs */}
      <div style={{ display: 'flex', gap: '8px', marginBottom: '20px' }}>
        {['ALL', 'PUBLISHED', 'DRAFT', 'ARCHIVED'].map((st) => (
          <button
            key={st}
            onClick={() => setFilter(st)}
            className={filter === st ? 'btn-primary' : 'btn-secondary'}
            style={{ padding: '6px 14px', fontSize: '13px' }}
          >
            {st}
          </button>
        ))}
      </div>

      {/* Chapter Cards Grid */}
      {isLoading ? (
        <div style={{ color: 'var(--text-muted)' }}>Loading chapters...</div>
      ) : chapters.length === 0 ? (
        <div className="card" style={{ padding: '40px', textAlign: 'center' }}>
          <p style={{ color: 'var(--text-muted)' }}>No chapters found matching filter.</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))', gap: '20px' }}>
          {chapters.map((ch) => (
            <div key={ch.id} className="card" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <span style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--terracotta)' }}>
                    CHAPTER {ch.chapter_number}
                  </span>
                  <h3 style={{ fontSize: '18px', color: 'var(--deep-earth)', marginTop: '2px' }}>{ch.title}</h3>
                  {ch.subtitle && (
                    <div style={{ fontSize: '13px', color: 'var(--text-muted)', fontStyle: 'italic' }}>
                      {ch.subtitle}
                    </div>
                  )}
                </div>
                <StatusBadge status={ch.status} />
              </div>

              <p style={{ fontSize: '13px', color: 'var(--text-main)', flex: 1 }}>{ch.description}</p>

              {ch.historical_note && (
                <div style={{
                  padding: '10px',
                  backgroundColor: 'var(--bg-panel)',
                  borderRadius: '6px',
                  fontSize: '12px',
                  color: 'var(--deep-earth)',
                }}>
                  <strong>Historical Context:</strong> {ch.historical_note}
                </div>
              )}

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '12px', borderTop: '1px solid var(--border-color)' }}>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontFamily: 'monospace' }}>
                  {ch.scene_path}
                </span>

                <div style={{ display: 'flex', gap: '8px' }}>
                  {ch.status === 'DRAFT' && (
                    <button
                      className="btn-secondary"
                      style={{ padding: '6px 10px', fontSize: '12px', color: 'var(--forest-green)' }}
                      onClick={() => statusMutation.mutate({ id: ch.id, status: 'PUBLISHED' })}
                      title="Publish Chapter"
                    >
                      <CheckCircle size={14} />
                      <span>Publish</span>
                    </button>
                  )}
                  <button
                    className="btn-secondary"
                    style={{ padding: '6px 10px', fontSize: '12px' }}
                    onClick={() => openEditModal(ch)}
                    title="Edit Chapter"
                  >
                    <Edit size={14} />
                    <span>Edit</span>
                  </button>
                  {ch.status !== 'ARCHIVED' && (
                    <button
                      className="btn-secondary"
                      style={{ padding: '6px 10px', fontSize: '12px', color: 'var(--text-muted)' }}
                      onClick={() => setArchiveTarget(ch)}
                      title="Archive Chapter"
                    >
                      <Archive size={14} />
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Chapter Edit / Create Modal */}
      {isModalOpen && (
        <div style={{
          position: 'fixed',
          top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: 'rgba(33, 28, 24, 0.6)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          zIndex: 1000,
        }}>
          <div className="card" style={{ width: '600px', maxWidth: '95%', maxHeight: '90vh', overflowY: 'auto' }}>
            <h2 style={{ fontSize: '20px', color: 'var(--deep-earth)', marginBottom: '18px' }}>
              {editingChapter ? 'Edit Chapter' : 'Create New Chapter'}
            </h2>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                saveMutation.mutate(formData);
              }}
              style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}
            >
              <div style={{ display: 'flex', gap: '12px' }}>
                <div style={{ width: '120px' }}>
                  <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Number</label>
                  <input
                    type="number"
                    className="input-field"
                    value={formData.chapter_number}
                    onChange={(e) => setFormData({ ...formData, chapter_number: parseInt(e.target.value, 10) || 1 })}
                    required
                  />
                </div>
                <div style={{ flex: 1 }}>
                  <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Identifier ID</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.id}
                    disabled={!!editingChapter}
                    onChange={(e) => setFormData({ ...formData, id: e.target.value })}
                    required
                  />
                </div>
              </div>

              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Title</label>
                <input
                  type="text"
                  className="input-field"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  required
                />
              </div>

              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Subtitle</label>
                <input
                  type="text"
                  className="input-field"
                  value={formData.subtitle}
                  onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
                />
              </div>

              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Description</label>
                <textarea
                  className="input-field"
                  rows={3}
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  required
                />
              </div>

              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Historical Note</label>
                <textarea
                  className="input-field"
                  rows={2}
                  value={formData.historical_note}
                  onChange={(e) => setFormData({ ...formData, historical_note: e.target.value })}
                />
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                <div style={{ flex: 1 }}>
                  <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Godot Scene Path</label>
                  <input
                    type="text"
                    className="input-field"
                    value={formData.scene_path}
                    onChange={(e) => setFormData({ ...formData, scene_path: e.target.value })}
                  />
                </div>
                <div style={{ width: '160px' }}>
                  <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Status</label>
                  <select
                    className="input-field"
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value as ContentStatus })}
                  >
                    <option value="DRAFT">Draft</option>
                    <option value="PUBLISHED">Published</option>
                    <option value="ARCHIVED">Archived</option>
                  </select>
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '16px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={saveMutation.isPending}>
                  {saveMutation.isPending ? 'Saving...' : 'Save Chapter'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Confirmation Modal for Archiving */}
      <ConfirmModal
        isOpen={!!archiveTarget}
        title="Archive Chapter?"
        message={`Are you sure you want to archive "${archiveTarget?.title}"? Players will no longer receive this chapter in public content bundles.`}
        confirmLabel="Archive Chapter"
        isDestructive={true}
        onConfirm={() => archiveTarget && statusMutation.mutate({ id: archiveTarget.id, status: 'ARCHIVED' })}
        onCancel={() => setArchiveTarget(null)}
      />
    </div>
  );
};
