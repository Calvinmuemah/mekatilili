import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { Quest, ContentStatus, ObjectiveType } from '../types';
import { StatusBadge } from '../components/StatusBadge';
import { Plus, CheckSquare, Compass } from 'lucide-react';

export const QuestsPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [selectedChapter, setSelectedChapter] = useState<string>('ALL');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingQuest, setEditingQuest] = useState<Quest | null>(null);

  const [formData, setFormData] = useState({
    id: '',
    chapter_id: 'chapter_1',
    title: '',
    description: '',
    reward_text: '',
    status: 'DRAFT' as ContentStatus,
    objectives: [
      { id: '', description: '', objectiveType: 'TALK_TO_NPC' as ObjectiveType },
    ],
  });

  const { data: chapters = [] } = useQuery({
    queryKey: ['chapters'],
    queryFn: () => contentApi.getChapters(),
  });

  const { data: quests = [], isLoading } = useQuery({
    queryKey: ['quests', selectedChapter],
    queryFn: () => contentApi.getQuests(selectedChapter === 'ALL' ? undefined : selectedChapter),
  });

  const saveMutation = useMutation({
    mutationFn: (data: typeof formData) => {
      if (editingQuest) {
        return contentApi.updateQuest(editingQuest.id, {
          title: data.title,
          description: data.description,
          reward_text: data.reward_text,
          status: data.status,
        });
      }
      return contentApi.createQuest({
        id: data.id,
        chapter_id: data.chapter_id,
        title: data.title,
        description: data.description,
        reward_text: data.reward_text,
        status: data.status,
        order_index: 1,
        objectives: data.objectives.map((o, idx) => ({
          id: o.id || `${data.id}_obj_${idx + 1}`,
          quest_id: data.id,
          title: o.description,
          description: o.description,
          objective_type: o.objectiveType,
          required: true,
          order_index: idx + 1,
        })),
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['quests'] });
      setIsModalOpen(false);
      setEditingQuest(null);
    },
  });

  const openCreateModal = () => {
    setEditingQuest(null);
    setFormData({
      id: `quest_ch1_${Date.now().toString().slice(-4)}`,
      chapter_id: chapters[0]?.id || 'chapter_1',
      title: '',
      description: '',
      reward_text: 'Community Support gained.',
      status: 'DRAFT',
      objectives: [
        { id: '', description: 'Consult with the village elder', objectiveType: 'TALK_TO_NPC' },
      ],
    });
    setIsModalOpen(true);
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Quest & Objective Management</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Structure missions, community gathering objectives, and cultural milestones
          </p>
        </div>
        <button className="btn-primary" onClick={openCreateModal}>
          <Plus size={16} />
          <span>New Quest</span>
        </button>
      </div>

      {/* Chapter Filter */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <span style={{ fontSize: '13px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>Filter by Chapter:</span>
        <select
          className="input-field"
          style={{ width: '220px' }}
          value={selectedChapter}
          onChange={(e) => setSelectedChapter(e.target.value)}
        >
          <option value="ALL">All Chapters</option>
          {chapters.map((ch) => (
            <option key={ch.id} value={ch.id}>Chapter {ch.chapter_number}: {ch.title}</option>
          ))}
        </select>
      </div>

      {/* Quests List */}
      {isLoading ? (
        <div style={{ color: 'var(--text-muted)' }}>Loading quests...</div>
      ) : quests.length === 0 ? (
        <div className="card" style={{ padding: '40px', textAlign: 'center' }}>
          <p style={{ color: 'var(--text-muted)' }}>No quests found.</p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {quests.map((q) => (
            <div key={q.id} className="card">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ width: '36px', height: '36px', borderRadius: '8px', backgroundColor: 'var(--bg-panel)', color: 'var(--terracotta)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Compass size={20} />
                  </div>
                  <div>
                    <h3 style={{ fontSize: '17px', color: 'var(--deep-earth)' }}>{q.title}</h3>
                    <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Chapter ID: {q.chapter_id}</span>
                  </div>
                </div>
                <StatusBadge status={q.status} />
              </div>

              <p style={{ fontSize: '14px', color: 'var(--text-main)', marginBottom: '16px' }}>{q.description}</p>

              {/* Objectives List */}
              <div style={{ backgroundColor: 'var(--bg-primary)', padding: '14px', borderRadius: '8px', marginBottom: '14px' }}>
                <div style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--deep-earth)', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                  Objectives ({q.objectives?.length || 0})
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {q.objectives?.map((obj, i) => (
                    <div key={obj.id} style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '13px' }}>
                      <CheckSquare size={16} color="var(--forest-green)" />
                      <span style={{ fontWeight: '600', color: 'var(--deep-earth)' }}>Step {i + 1}:</span>
                      <span style={{ flex: 1, color: 'var(--text-main)' }}>{obj.description}</span>
                      <span style={{ fontSize: '11px', padding: '2px 8px', borderRadius: '4px', backgroundColor: 'var(--bg-surface)', border: '1px solid var(--border-color)', color: 'var(--text-muted)' }}>
                        {obj.objective_type}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              {q.reward_text && (
                <div style={{ fontSize: '12px', color: 'var(--forest-green)', fontWeight: '600' }}>
                  Reward: {q.reward_text}
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Quest Modal */}
      {isModalOpen && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: 'rgba(33, 28, 24, 0.6)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          zIndex: 1000,
        }}>
          <div className="card" style={{ width: '640px', maxWidth: '95%', maxHeight: '90vh', overflowY: 'auto' }}>
            <h2 style={{ fontSize: '20px', color: 'var(--deep-earth)', marginBottom: '16px' }}>Create New Quest</h2>
            <form onSubmit={(e) => { e.preventDefault(); saveMutation.mutate(formData); }} style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div>
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Quest ID</label>
                <input
                  type="text"
                  className="input-field"
                  value={formData.id}
                  onChange={(e) => setFormData({ ...formData, id: e.target.value })}
                  required
                />
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
                <label style={{ fontSize: '12px', fontWeight: 'bold' }}>Reward Text</label>
                <input
                  type="text"
                  className="input-field"
                  value={formData.reward_text}
                  onChange={(e) => setFormData({ ...formData, reward_text: e.target.value })}
                />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '16px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>Cancel</button>
                <button type="submit" className="btn-primary" disabled={saveMutation.isPending}>Save Quest</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
