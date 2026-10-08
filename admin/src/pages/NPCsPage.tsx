import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { NPC } from '../types';
import { Users, Plus, MapPin, Edit } from 'lucide-react';

export const NPCsPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingNPC, setEditingNPC] = useState<NPC | null>(null);

  const [formData, setFormData] = useState({
    id: '',
    name: '',
    description: '',
    role: '',
    portrait_url: '',
    location_name: '',
    chapter_id: 'chapter_1',
  });

  const { data: npcs = [], isLoading } = useQuery({
    queryKey: ['npcs'],
    queryFn: () => contentApi.getNPCs(),
  });

  const saveMutation = useMutation({
    mutationFn: (data: typeof formData) => {
      if (editingNPC) {
        return contentApi.updateNPC(editingNPC.id, {
          name: data.name,
          description: data.description,
          role: data.role,
          portrait_url: data.portrait_url,
          location_name: data.location_name,
        });
      }
      return contentApi.createNPC({
        id: data.id,
        name: data.name,
        description: data.description,
        role: data.role,
        portrait_url: data.portrait_url,
        chapter_id: data.chapter_id,
        location_name: data.location_name,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['npcs'] });
      setIsModalOpen(false);
      setEditingNPC(null);
    },
  });

  const openCreateModal = () => {
    setEditingNPC(null);
    setFormData({
      id: `npc_${Date.now().toString().slice(-4)}`,
      name: '',
      description: '',
      role: 'Villager',
      portrait_url: 'res://assets/characters/portraits/nyevu.png',
      location_name: 'Ulungu Village',
      chapter_id: 'chapter_1',
    });
    setIsModalOpen(true);
  };

  const openEditModal = (npc: NPC) => {
    setEditingNPC(npc);
    setFormData({
      id: npc.id,
      name: npc.name,
      description: npc.description,
      role: npc.role,
      portrait_url: npc.portrait_url || '',
      location_name: npc.location_name || '',
      chapter_id: npc.chapter_id || 'chapter_1',
    });
    setIsModalOpen(true);
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>NPC Cast Management</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Historical elders, warriors, advisors, and village community members
          </p>
        </div>
        <button className="btn-primary" onClick={openCreateModal}>
          <Plus size={16} />
          <span>New NPC</span>
        </button>
      </div>

      {isLoading ? (
        <div style={{ color: 'var(--text-muted)' }}>Loading NPCs...</div>
      ) : npcs.length === 0 ? (
        <div className="card" style={{ padding: '40px', textAlign: 'center' }}>
          <p style={{ color: 'var(--text-muted)' }}>No NPCs registered.</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
          {npcs.map((npc) => (
            <div key={npc.id} className="card" style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                <div style={{
                  width: '52px',
                  height: '52px',
                  borderRadius: '50%',
                  backgroundColor: 'var(--bg-panel)',
                  border: '2px solid var(--warm-gold)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: 'var(--terracotta)',
                  fontWeight: 'bold',
                }}>
                  <Users size={24} />
                </div>
                <div>
                  <h3 style={{ fontSize: '16px', color: 'var(--deep-earth)' }}>{npc.name}</h3>
                  <span style={{ fontSize: '12px', fontWeight: '600', color: 'var(--terracotta)' }}>{npc.role}</span>
                </div>
              </div>

              <p style={{ fontSize: '13px', color: 'var(--text-main)', flex: 1 }}>{npc.description}</p>

              {npc.location_name && (
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px', color: 'var(--text-muted)' }}>
                  <MapPin size={14} color="var(--terracotta)" />
                  <span>{npc.location_name}</span>
                </div>
              )}

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '10px', borderTop: '1px solid var(--border-color)' }}>
                <span style={{ fontSize: '11px', color: 'var(--text-muted)', fontFamily: 'monospace' }}>{npc.id}</span>
                <button className="btn-secondary" style={{ padding: '4px 10px', fontSize: '12px' }} onClick={() => openEditModal(npc)}>
                  <Edit size={14} />
                  <span>Edit</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* NPC Modal */}
      {isModalOpen && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: 'rgba(33, 28, 24, 0.6)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          zIndex: 1000,
        }}>
          <div className="card" style={{ width: '500px', maxWidth: '95%' }}>
            <h2 style={{ fontSize: '18px', color: 'var(--deep-earth)', marginBottom: '14px' }}>
              {editingNPC ? 'Edit NPC' : 'Register New NPC'}
            </h2>
            <form onSubmit={(e) => { e.preventDefault(); saveMutation.mutate(formData); }} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Name</label>
                <input
                  type="text"
                  className="input-field"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  required
                />
              </div>
              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Role / Title</label>
                <input
                  type="text"
                  className="input-field"
                  value={formData.role}
                  onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                  required
                />
              </div>
              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Description / Background</label>
                <textarea
                  className="input-field"
                  rows={3}
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  required
                />
              </div>
              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Location Name</label>
                <input
                  type="text"
                  className="input-field"
                  value={formData.location_name}
                  onChange={(e) => setFormData({ ...formData, location_name: e.target.value })}
                />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '16px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saveMutation.isPending}>Save NPC</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
