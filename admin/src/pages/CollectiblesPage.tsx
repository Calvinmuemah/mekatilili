import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { Collectible, ContentStatus } from '../types';
import { StatusBadge } from '../components/StatusBadge';
import { ConfirmModal } from '../components/ConfirmModal';
import { Sparkles, Plus, Edit, Trash2, Filter } from 'lucide-react';

export const CollectiblesPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [selectedCategory, setSelectedCategory] = useState<string>('ALL');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [editingItem, setEditingItem] = useState<Collectible | null>(null);

  const [formData, setFormData] = useState({
    id: '',
    name: '',
    description: '',
    category: 'CULTURAL_ARTIFACT',
    historical_context: '',
    image_url: '',
    chapter_id: 'chapter_1',
    status: 'PUBLISHED' as ContentStatus,
  });

  const { data: collectibles = [], isLoading } = useQuery({
    queryKey: ['collectibles'],
    queryFn: () => contentApi.getCollectibles(),
  });

  const saveMutation = useMutation({
    mutationFn: (data: typeof formData) => {
      if (editingItem) {
        return contentApi.updateCollectible(editingItem.id, {
          name: data.name,
          description: data.description,
          category: data.category,
          historical_context: data.historical_context,
          image_url: data.image_url,
          chapter_id: data.chapter_id,
          status: data.status,
        });
      }
      return contentApi.createCollectible(data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['collectibles'] });
      setIsModalOpen(false);
      setEditingItem(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteCollectible(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['collectibles'] });
      setDeleteId(null);
    },
  });

  const openCreateModal = () => {
    setEditingItem(null);
    setFormData({
      id: `col_${Date.now().toString().slice(-4)}`,
      name: '',
      description: '',
      category: 'CULTURAL_ARTIFACT',
      historical_context: '',
      image_url: 'res://assets/sprites/items/kifudu.png',
      chapter_id: 'chapter_1',
      status: 'PUBLISHED',
    });
    setIsModalOpen(true);
  };

  const openEditModal = (item: Collectible) => {
    setEditingItem(item);
    setFormData({
      id: item.id,
      name: item.name,
      description: item.description,
      category: item.category,
      historical_context: item.historical_context || '',
      image_url: item.image_url || '',
      chapter_id: item.chapter_id || 'chapter_1',
      status: item.status,
    });
    setIsModalOpen(true);
  };

  const filteredItems = selectedCategory === 'ALL'
    ? collectibles
    : collectibles.filter((c) => c.category === selectedCategory);

  const categories = Array.from(new Set(collectibles.map((c) => c.category)));

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Cultural Collectibles</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Sacred artifacts, traditional tools, and cultural relics Mekatilili encounters
          </p>
        </div>
        <button className="btn-primary" onClick={openCreateModal}>
          <Plus size={16} />
          <span>New Artifact</span>
        </button>
      </div>

      {/* Category Filter */}
      <div style={{ display: 'flex', gap: '8px', marginBottom: '20px', alignItems: 'center', flexWrap: 'wrap' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-muted)', fontSize: '13px', marginRight: '8px' }}>
          <Filter size={14} /> Filter:
        </div>
        <button
          className={selectedCategory === 'ALL' ? 'btn-primary' : 'btn-secondary'}
          style={{ padding: '6px 12px', fontSize: '12px' }}
          onClick={() => setSelectedCategory('ALL')}
        >
          All ({collectibles.length})
        </button>
        {categories.map((cat) => (
          <button
            key={cat}
            className={selectedCategory === cat ? 'btn-primary' : 'btn-secondary'}
            style={{ padding: '6px 12px', fontSize: '12px' }}
            onClick={() => setSelectedCategory(cat)}
          >
            {cat.replace(/_/g, ' ')}
          </button>
        ))}
      </div>

      {isLoading ? (
        <div style={{ color: 'var(--text-muted)' }}>Loading collectibles...</div>
      ) : filteredItems.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '48px' }}>
          <Sparkles size={40} style={{ color: 'var(--warm-gold)', margin: '0 auto 12px auto' }} />
          <h3 style={{ fontSize: '18px', color: 'var(--deep-earth)' }}>No collectibles found</h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '6px' }}>
            Add sacred artifacts or items to populate the player's cultural journal.
          </p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '16px' }}>
          {filteredItems.map((item) => (
            <div key={item.id} className="card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <div
                      style={{
                        width: '40px',
                        height: '40px',
                        borderRadius: '8px',
                        backgroundColor: 'var(--sand-dark)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        color: 'var(--warm-gold)',
                      }}
                    >
                      <Sparkles size={20} />
                    </div>
                    <div>
                      <h3 style={{ fontSize: '16px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>{item.name}</h3>
                      <span
                        style={{
                          fontSize: '11px',
                          color: 'var(--terracotta)',
                          fontWeight: '600',
                          textTransform: 'uppercase',
                        }}
                      >
                        {item.category.replace(/_/g, ' ')}
                      </span>
                    </div>
                  </div>
                  <StatusBadge status={item.status} />
                </div>

                <p style={{ fontSize: '13px', color: 'var(--deep-earth)', lineHeight: '1.5', marginBottom: '12px' }}>
                  {item.description}
                </p>

                {item.historical_context && (
                  <div
                    style={{
                      backgroundColor: 'rgba(217, 164, 65, 0.08)',
                      borderLeft: '3px solid var(--warm-gold)',
                      padding: '8px 12px',
                      borderRadius: '4px',
                      fontSize: '12px',
                      color: 'var(--deep-earth)',
                      marginBottom: '14px',
                    }}
                  >
                    <span style={{ fontWeight: '600', color: 'var(--terracotta)' }}>Historical Context: </span>
                    {item.historical_context}
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
                <code style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{item.id}</code>
                <div style={{ display: 'flex', gap: '6px' }}>
                  <button
                    className="btn-secondary"
                    style={{ padding: '6px 10px', fontSize: '12px' }}
                    onClick={() => openEditModal(item)}
                  >
                    <Edit size={14} />
                    <span>Edit</span>
                  </button>
                  <button
                    className="btn-secondary"
                    style={{ padding: '6px 8px', color: 'var(--terracotta)' }}
                    onClick={() => setDeleteId(item.id)}
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
          <div className="modal-card" style={{ maxWidth: '520px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: 'bold', color: 'var(--deep-earth)', marginBottom: '16px' }}>
              {editingItem ? 'Edit Collectible' : 'Create New Collectible'}
            </h2>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                saveMutation.mutate(formData);
              }}
            >
              {!editingItem && (
                <div style={{ marginBottom: '14px' }}>
                  <label className="label">Identifier (ID)</label>
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
                <label className="label">Artifact Name</label>
                <input
                  type="text"
                  className="input"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="e.g. Vigango Memorial Totem"
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '14px' }}>
                <div>
                  <label className="label">Category</label>
                  <select
                    className="input"
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                  >
                    <option value="CULTURAL_ARTIFACT">Cultural Artifact</option>
                    <option value="SACRED_ITEM">Sacred Item</option>
                    <option value="TRADITIONAL_TOOL">Traditional Tool</option>
                    <option value="CEREMONIAL_REGALIA">Ceremonial Regalia</option>
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
                <label className="label">In-Game Description</label>
                <textarea
                  className="input"
                  rows={3}
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  placeholder="Visual and narrative description seen by the player..."
                  required
                />
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label className="label">Historical Context & Giriama Significance</label>
                <textarea
                  className="input"
                  rows={3}
                  value={formData.historical_context}
                  onChange={(e) => setFormData({ ...formData, historical_context: e.target.value })}
                  placeholder="Kenyan heritage details and cultural importance..."
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label className="label">Godot Asset / Image Path</label>
                <input
                  type="text"
                  className="input"
                  value={formData.image_url}
                  onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                  placeholder="res://assets/sprites/items/..."
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn-primary" disabled={saveMutation.isPending}>
                  {saveMutation.isPending ? 'Saving...' : editingItem ? 'Save Changes' : 'Create Artifact'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      <ConfirmModal
        isOpen={deleteId !== null}
        title="Delete Collectible"
        message="Are you sure you want to delete this cultural artifact? Players who have already found this item may have orphaned save references."
        confirmText="Delete Artifact"
        isDanger={true}
        onConfirm={() => deleteId && deleteMutation.mutate(deleteId)}
        onCancel={() => setDeleteId(null)}
      />
    </div>
  );
};
