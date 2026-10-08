import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { JournalEntry, ContentStatus } from '../types';
import { StatusBadge } from '../components/StatusBadge';
import { ConfirmModal } from '../components/ConfirmModal';
import { BookOpen, Plus, Edit, Trash2, Filter } from 'lucide-react';

export const JournalPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [selectedCategory, setSelectedCategory] = useState<string>('ALL');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [editingEntry, setEditingEntry] = useState<JournalEntry | null>(null);

  const [formData, setFormData] = useState({
    id: '',
    title: '',
    content: '',
    category: 'STORY' as 'STORY' | 'HISTORY' | 'CULTURAL' | 'CHARACTER',
    reference_source: '',
    chapter_id: 'chapter_1',
    status: 'PUBLISHED' as ContentStatus,
  });

  const { data: journalEntries = [], isLoading } = useQuery({
    queryKey: ['journal'],
    queryFn: () => contentApi.getJournal(),
  });

  const saveMutation = useMutation({
    mutationFn: (data: typeof formData) => {
      if (editingEntry) {
        return contentApi.updateJournal(editingEntry.id, {
          title: data.title,
          content: data.content,
          category: data.category,
          reference_source: data.reference_source,
          chapter_id: data.chapter_id,
          status: data.status,
        });
      }
      return contentApi.createJournal(data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['journal'] });
      setIsModalOpen(false);
      setEditingEntry(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteJournal(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['journal'] });
      setDeleteId(null);
    },
  });

  const openCreateModal = () => {
    setEditingEntry(null);
    setFormData({
      id: `jnl_${Date.now().toString().slice(-4)}`,
      title: '',
      content: '',
      category: 'STORY',
      reference_source: '',
      chapter_id: 'chapter_1',
      status: 'PUBLISHED',
    });
    setIsModalOpen(true);
  };

  const openEditModal = (entry: JournalEntry) => {
    setEditingEntry(entry);
    setFormData({
      id: entry.id,
      title: entry.title,
      content: entry.content,
      category: entry.category,
      reference_source: entry.reference_source || '',
      chapter_id: entry.chapter_id || 'chapter_1',
      status: entry.status,
    });
    setIsModalOpen(true);
  };

  const filteredEntries = selectedCategory === 'ALL'
    ? journalEntries
    : journalEntries.filter((e) => e.category === selectedCategory);

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Player Journal & Codex</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Story summaries, Giriama cultural codex entries, character dossiers, and historical notes
          </p>
        </div>
        <button className="btn-primary" onClick={openCreateModal}>
          <Plus size={16} />
          <span>New Journal Entry</span>
        </button>
      </div>

      {/* Categories Filter */}
      <div style={{ display: 'flex', gap: '8px', marginBottom: '20px', alignItems: 'center' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-muted)', fontSize: '13px', marginRight: '8px' }}>
          <Filter size={14} /> Category:
        </div>
        {(['ALL', 'STORY', 'HISTORY', 'CULTURAL', 'CHARACTER'] as const).map((cat) => (
          <button
            key={cat}
            className={selectedCategory === cat ? 'btn-primary' : 'btn-secondary'}
            style={{ padding: '6px 12px', fontSize: '12px' }}
            onClick={() => setSelectedCategory(cat)}
          >
            {cat === 'ALL' ? `All (${journalEntries.length})` : cat}
          </button>
        ))}
      </div>

      {isLoading ? (
        <div style={{ color: 'var(--text-muted)' }}>Loading journal entries...</div>
      ) : filteredEntries.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '48px' }}>
          <BookOpen size={40} style={{ color: 'var(--warm-gold)', margin: '0 auto 12px auto' }} />
          <h3 style={{ fontSize: '18px', color: 'var(--deep-earth)' }}>No journal entries found</h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '6px' }}>
            Create entries to enrich the in-game codex and provide lore context.
          </p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))', gap: '16px' }}>
          {filteredEntries.map((entry) => (
            <div key={entry.id} className="card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                  <div>
                    <span
                      style={{
                        fontSize: '11px',
                        color: 'var(--forest-green)',
                        fontWeight: '700',
                        textTransform: 'uppercase',
                        letterSpacing: '0.05em',
                      }}
                    >
                      {entry.category}
                    </span>
                    <h3 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)', marginTop: '2px' }}>
                      {entry.title}
                    </h3>
                  </div>
                  <StatusBadge status={entry.status} />
                </div>

                <p
                  style={{
                    fontSize: '13px',
                    color: 'var(--deep-earth)',
                    lineHeight: '1.6',
                    marginBottom: '14px',
                    whiteSpace: 'pre-line',
                  }}
                >
                  {entry.content}
                </p>

                {entry.reference_source && (
                  <div
                    style={{
                      fontSize: '11px',
                      color: 'var(--text-muted)',
                      fontStyle: 'italic',
                      backgroundColor: 'rgba(59, 36, 22, 0.04)',
                      padding: '6px 10px',
                      borderRadius: '4px',
                      marginBottom: '12px',
                    }}
                  >
                    Source: {entry.reference_source}
                  </div>
                )}
              </div>

              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  paddingTop: '12px',
                  borderTop: '1px solid var(--sand-dark)',
                }}
              >
                <code style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{entry.id}</code>
                <div style={{ display: 'flex', gap: '6px' }}>
                  <button
                    className="btn-secondary"
                    style={{ padding: '6px 10px', fontSize: '12px' }}
                    onClick={() => openEditModal(entry)}
                  >
                    <Edit size={14} />
                    <span>Edit</span>
                  </button>
                  <button
                    className="btn-secondary"
                    style={{ padding: '6px 8px', color: 'var(--terracotta)' }}
                    onClick={() => setDeleteId(entry.id)}
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Edit/Create Modal */}
      {isModalOpen && (
        <div className="modal-backdrop">
          <div className="modal-card" style={{ maxWidth: '540px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: 'bold', color: 'var(--deep-earth)', marginBottom: '16px' }}>
              {editingEntry ? 'Edit Journal Entry' : 'New Journal Entry'}
            </h2>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                saveMutation.mutate(formData);
              }}
            >
              {!editingEntry && (
                <div style={{ marginBottom: '14px' }}>
                  <label className="label">Entry ID</label>
                  <input
                    type="text"
                    className="input"
                    value={formData.id}
                    onChange={(e) => setFormData({ ...formData, id: e.target.value })}
                    required
                  />
                </div>
              )}

              <div style={{ marginBottom: '14px' }}>
                <label className="label">Title</label>
                <input
                  type="text"
                  className="input"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder="e.g. The Sacred Kaya Forest"
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '14px' }}>
                <div>
                  <label className="label">Category</label>
                  <select
                    className="input"
                    value={formData.category}
                    onChange={(e) =>
                      setFormData({
                        ...formData,
                        category: e.target.value as 'STORY' | 'HISTORY' | 'CULTURAL' | 'CHARACTER',
                      })
                    }
                  >
                    <option value="STORY">STORY</option>
                    <option value="HISTORY">HISTORY</option>
                    <option value="CULTURAL">CULTURAL</option>
                    <option value="CHARACTER">CHARACTER</option>
                  </select>
                </div>

                <div>
                  <label className="label">Status</label>
                  <select
                    className="input"
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value as ContentStatus })}
                  >
                    <option value="DRAFT">DRAFT</option>
                    <option value="PUBLISHED">PUBLISHED</option>
                    <option value="ARCHIVED">ARCHIVED</option>
                  </select>
                </div>
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label className="label">Journal Text Content</label>
                <textarea
                  className="input"
                  rows={5}
                  value={formData.content}
                  onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                  placeholder="Detailed lore description unlocked in the player's journal..."
                  required
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label className="label">Historical Source / Academic Reference</label>
                <input
                  type="text"
                  className="input"
                  value={formData.reference_source}
                  onChange={(e) => setFormData({ ...formData, reference_source: e.target.value })}
                  placeholder="e.g. Cynthia Brantley, The Giriama and the British Colonial Administration"
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={saveMutation.isPending}>
                  {saveMutation.isPending ? 'Saving...' : editingEntry ? 'Save Changes' : 'Create Entry'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Modal */}
      <ConfirmModal
        isOpen={deleteId !== null}
        title="Delete Journal Entry"
        message="Are you sure you want to delete this journal entry from the game's codex?"
        confirmText="Delete Entry"
        isDanger={true}
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        onCancel={() => setDeleteId(null)}
      />
    </div>
  );
};
