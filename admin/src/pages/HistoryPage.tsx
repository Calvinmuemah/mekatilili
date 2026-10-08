import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { HistoricalReference } from '../types';
import { ConfirmModal } from '../components/ConfirmModal';
import { Scroll, Plus, Edit, Trash2, CheckCircle2, AlertCircle, ExternalLink } from 'lucide-react';

export const HistoryPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [editingRef, setEditingRef] = useState<HistoricalReference | null>(null);

  const [formData, setFormData] = useState({
    id: '',
    title: '',
    description: '',
    source: '',
    source_url: '',
    author: '',
    publication_date: '',
    notes: '',
    related_chapter_id: 'chapter_1',
    is_verified: true,
  });

  const { data: references = [], isLoading } = useQuery({
    queryKey: ['history'],
    queryFn: () => contentApi.getHistory(),
  });

  const saveMutation = useMutation({
    mutationFn: (data: typeof formData) => {
      if (editingRef) {
        return contentApi.updateHistory(editingRef.id, {
          title: data.title,
          description: data.description,
          source: data.source,
          source_url: data.source_url,
          author: data.author,
          publication_date: data.publication_date,
          notes: data.notes,
          related_chapter_id: data.related_chapter_id,
          is_verified: data.is_verified,
        });
      }
      return contentApi.createHistory(data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['history'] });
      setIsModalOpen(false);
      setEditingRef(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteHistory(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['history'] });
      setDeleteId(null);
    },
  });

  const openCreateModal = () => {
    setEditingRef(null);
    setFormData({
      id: `hist_${Date.now().toString().slice(-4)}`,
      title: '',
      description: '',
      source: '',
      source_url: '',
      author: '',
      publication_date: '',
      notes: '',
      related_chapter_id: 'chapter_1',
      is_verified: true,
    });
    setIsModalOpen(true);
  };

  const openEditModal = (ref: HistoricalReference) => {
    setEditingRef(ref);
    setFormData({
      id: ref.id,
      title: ref.title,
      description: ref.description,
      source: ref.source,
      source_url: ref.source_url || '',
      author: ref.author || '',
      publication_date: ref.publication_date || '',
      notes: ref.notes || '',
      related_chapter_id: ref.related_chapter_id || 'chapter_1',
      is_verified: ref.is_verified,
    });
    setIsModalOpen(true);
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Historical References</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Academic citations, colonial archival records, and oral history documentation backing game lore
          </p>
        </div>
        <button className="btn-primary" onClick={openCreateModal}>
          <Plus size={16} />
          <span>New Citation</span>
        </button>
      </div>

      {isLoading ? (
        <div style={{ color: 'var(--text-muted)' }}>Loading historical references...</div>
      ) : references.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '48px' }}>
          <Scroll size={40} style={{ color: 'var(--warm-gold)', margin: '0 auto 12px auto' }} />
          <h3 style={{ fontSize: '18px', color: 'var(--deep-earth)' }}>No historical references logged</h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '6px' }}>
            Document historical sources and colonial records to maintain cultural integrity.
          </p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(360px, 1fr))', gap: '16px' }}>
          {references.map((ref) => (
            <div key={ref.id} className="card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                  <h3 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>{ref.title}</h3>
                  {ref.is_verified ? (
                    <span
                      style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '4px',
                        backgroundColor: 'rgba(49, 92, 58, 0.12)',
                        color: 'var(--forest-green)',
                        padding: '3px 8px',
                        borderRadius: '12px',
                        fontSize: '11px',
                        fontWeight: '600',
                      }}
                    >
                      <CheckCircle2 size={12} />
                      Verified
                    </span>
                  ) : (
                    <span
                      style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '4px',
                        backgroundColor: 'rgba(184, 92, 56, 0.12)',
                        color: 'var(--terracotta)',
                        padding: '3px 8px',
                        borderRadius: '12px',
                        fontSize: '11px',
                        fontWeight: '600',
                      }}
                    >
                      <AlertCircle size={12} />
                      Unverified
                    </span>
                  )}
                </div>

                <p style={{ fontSize: '13px', color: 'var(--deep-earth)', lineHeight: '1.5', marginBottom: '12px' }}>
                  {ref.description}
                </p>

                <div
                  style={{
                    backgroundColor: 'var(--sand-light)',
                    padding: '10px 12px',
                    borderRadius: '6px',
                    fontSize: '12px',
                    color: 'var(--deep-earth)',
                    marginBottom: '12px',
                    border: '1px solid var(--sand-dark)',
                  }}
                >
                  <div style={{ fontWeight: '600', color: 'var(--terracotta)', marginBottom: '2px' }}>
                    Citation: {ref.source}
                  </div>
                  {(ref.author || ref.publication_date) && (
                    <div style={{ color: 'var(--text-muted)', fontSize: '11px' }}>
                      {ref.author} {ref.publication_date ? `(${ref.publication_date})` : ''}
                    </div>
                  )}
                  {ref.source_url && (
                    <a
                      href={ref.source_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: '4px',
                        color: 'var(--forest-green)',
                        textDecoration: 'underline',
                        fontSize: '11px',
                        marginTop: '4px',
                      }}
                    >
                      <span>External Source Link</span>
                      <ExternalLink size={10} />
                    </a>
                  )}
                </div>

                {ref.notes && (
                  <p style={{ fontSize: '12px', color: 'var(--text-muted)', fontStyle: 'italic', marginBottom: '12px' }}>
                    Note: {ref.notes}
                  </p>
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
                <code style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{ref.id}</code>
                <div style={{ display: 'flex', gap: '6px' }}>
                  <button
                    className="btn-secondary"
                    style={{ padding: '6px 10px', fontSize: '12px' }}
                    onClick={() => openEditModal(ref)}
                  >
                    <Edit size={14} />
                    <span>Edit</span>
                  </button>
                  <button
                    className="btn-secondary"
                    style={{ padding: '6px 8px', color: 'var(--terracotta)' }}
                    onClick={() => setDeleteId(ref.id)}
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
              {editingRef ? 'Edit Historical Reference' : 'New Historical Reference'}
            </h2>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                saveMutation.mutate(formData);
              }}
            >
              {!editingRef && (
                <div style={{ marginBottom: '14px' }}>
                  <label className="label">Reference ID</label>
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
                <label className="label">Historical Subject / Title</label>
                <input
                  type="text"
                  className="input"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder="e.g. 1913 Giriama Resistance Oath at Kaya Fungo"
                  required
                />
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label className="label">Historical Event Description</label>
                <textarea
                  className="input"
                  rows={3}
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  placeholder="Historical synopsis and significance..."
                  required
                />
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label className="label">Primary Citation / Source Title</label>
                <input
                  type="text"
                  className="input"
                  value={formData.source}
                  onChange={(e) => setFormData({ ...formData, source: e.target.value })}
                  placeholder="e.g. Kenya National Archives, Coast Province DC/KFI/1"
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '14px' }}>
                <div>
                  <label className="label">Author / Historian</label>
                  <input
                    type="text"
                    className="input"
                    value={formData.author}
                    onChange={(e) => setFormData({ ...formData, author: e.target.value })}
                    placeholder="e.g. Dr. Cynthia Brantley"
                  />
                </div>
                <div>
                  <label className="label">Year / Publication Date</label>
                  <input
                    type="text"
                    className="input"
                    value={formData.publication_date}
                    onChange={(e) => setFormData({ ...formData, publication_date: e.target.value })}
                    placeholder="e.g. 1981"
                  />
                </div>
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label className="label">Source URL / Digital Archive Link</label>
                <input
                  type="url"
                  className="input"
                  value={formData.source_url}
                  onChange={(e) => setFormData({ ...formData, source_url: e.target.value })}
                  placeholder="https://..."
                />
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label className="label">Internal Researcher Notes</label>
                <textarea
                  className="input"
                  rows={2}
                  value={formData.notes}
                  onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                  placeholder="Notes on how this translates into gameplay or dialogue..."
                />
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
                <input
                  type="checkbox"
                  id="verified-check"
                  checked={formData.is_verified}
                  onChange={(e) => setFormData({ ...formData, is_verified: e.target.checked })}
                  style={{ width: '16px', height: '16px', accentColor: 'var(--forest-green)' }}
                />
                <label htmlFor="verified-check" style={{ fontSize: '13px', color: 'var(--deep-earth)', cursor: 'pointer' }}>
                  Mark as verified by cultural historians / primary documentation
                </label>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={saveMutation.isPending}>
                  {saveMutation.isPending ? 'Saving...' : editingRef ? 'Save Changes' : 'Create Reference'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Modal */}
      <ConfirmModal
        isOpen={deleteId !== null}
        title="Delete Historical Reference"
        message="Are you sure you want to delete this historical citation?"
        confirmText="Delete Reference"
        isDanger={true}
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        onCancel={() => setDeleteId(null)}
      />
    </div>
  );
};
