import React, { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { contentApi } from '../services/contentApi';
import { Dialogue, DialogueNode } from '../types';
import { Save, Play, Plus, Trash2, ArrowRight } from 'lucide-react';

export const DialogueEditorPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [selectedDialogueId, setSelectedDialogueId] = useState<string>('');
  const [selectedNodeKey, setSelectedNodeKey] = useState<string>('start');
  const [previewNodeKey, setPreviewNodeKey] = useState<string>('start');

  const { data: dialogues = [], isLoading } = useQuery({
    queryKey: ['dialogues'],
    queryFn: () => contentApi.getDialogues(),
  });

  const [activeDialogue, setActiveDialogue] = useState<Dialogue | null>(null);

  useEffect(() => {
    if (dialogues.length > 0 && !selectedDialogueId) {
      setSelectedDialogueId(dialogues[0].id);
      setActiveDialogue(dialogues[0]);
      setSelectedNodeKey(dialogues[0].start_node_id || 'start');
      setPreviewNodeKey(dialogues[0].start_node_id || 'start');
    }
  }, [dialogues, selectedDialogueId]);

  const handleSelectDialogue = (id: string) => {
    setSelectedDialogueId(id);
    const d = dialogues.find((item) => item.id === id);
    if (d) {
      setActiveDialogue(JSON.parse(JSON.stringify(d)));
      const startKey = d.start_node_id || 'start';
      setSelectedNodeKey(startKey);
      setPreviewNodeKey(startKey);
    }
  };

  const saveMutation = useMutation({
    mutationFn: () => {
      if (!activeDialogue) return Promise.reject();
      return contentApi.updateDialogue(activeDialogue.id, {
        title: activeDialogue.title,
        start_node_id: activeDialogue.start_node_id,
        raw_nodes: activeDialogue.raw_nodes,
        status: activeDialogue.status,
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['dialogues'] });
      alert('Dialogue tree saved successfully!');
    },
  });

  if (isLoading) {
    return <div style={{ color: 'var(--text-muted)' }}>Loading visual dialogue editor...</div>;
  }

  const nodes = activeDialogue?.raw_nodes || {};
  const currentNode: DialogueNode = nodes[selectedNodeKey] || {
    speaker: 'Speaker',
    text: '',
    choices: [],
  };
  const previewNode: DialogueNode = nodes[previewNodeKey] || currentNode;

  const updateCurrentNode = (patch: Partial<DialogueNode>) => {
    if (!activeDialogue) return;
    const updated = {
      ...activeDialogue,
      raw_nodes: {
        ...activeDialogue.raw_nodes,
        [selectedNodeKey]: {
          ...currentNode,
          ...patch,
        },
      },
    };
    setActiveDialogue(updated);
  };

  const addNewNode = () => {
    if (!activeDialogue) return;
    const newKey = `node_${Date.now().toString().slice(-4)}`;
    const updated = {
      ...activeDialogue,
      raw_nodes: {
        ...activeDialogue.raw_nodes,
        [newKey]: {
          speaker: activeDialogue.npc_name || 'Speaker',
          text: 'New response text here...',
          next: '',
          choices: [],
        },
      },
    };
    setActiveDialogue(updated);
    setSelectedNodeKey(newKey);
  };

  return (
    <div>
      {/* Header bar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', color: 'var(--deep-earth)', fontWeight: 'bold' }}>Visual Dialogue Authoring</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginTop: '4px' }}>
            Design narrative trees, branching elder choices, and historical events
          </p>
        </div>
        <div style={{ display: 'flex', gap: '12px' }}>
          <select
            className="input-field"
            style={{ width: '260px' }}
            value={selectedDialogueId}
            onChange={(e) => handleSelectDialogue(e.target.value)}
          >
            {dialogues.map((d) => (
              <option key={d.id} value={d.id}>{d.title} ({d.id})</option>
            ))}
          </select>
          <button className="btn-primary" onClick={() => saveMutation.mutate()} disabled={saveMutation.isPending}>
            <Save size={16} />
            <span>{saveMutation.isPending ? 'Saving...' : 'Save Dialogue Tree'}</span>
          </button>
        </div>
      </div>

      {/* Editor Grid: Left = Nodes List, Middle = Node Editor, Right = Interactive In-Game Preview */}
      <div style={{ display: 'grid', gridTemplateColumns: '220px 1fr 380px', gap: '20px', alignItems: 'start' }}>
        
        {/* 1. NODES LIST */}
        <div className="card" style={{ padding: '16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
            <span style={{ fontSize: '13px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>Dialogue Nodes</span>
            <button
              onClick={addNewNode}
              style={{ padding: '4px 8px', backgroundColor: 'var(--bg-panel)', borderRadius: '4px', fontSize: '12px', fontWeight: '600', color: 'var(--terracotta)' }}
              title="Add Node"
            >
              <Plus size={14} />
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            {Object.keys(nodes).map((nodeKey) => {
              const isSelected = selectedNodeKey === nodeKey;
              return (
                <button
                  key={nodeKey}
                  onClick={() => {
                    setSelectedNodeKey(nodeKey);
                    setPreviewNodeKey(nodeKey);
                  }}
                  style={{
                    padding: '8px 10px',
                    textAlign: 'left',
                    borderRadius: '6px',
                    fontSize: '13px',
                    fontWeight: isSelected ? '600' : '400',
                    backgroundColor: isSelected ? 'var(--terracotta)' : 'var(--bg-primary)',
                    color: isSelected ? '#FFFFFF' : 'var(--text-main)',
                    border: '1px solid var(--border-color)',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                  }}
                >
                  <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{nodeKey}</span>
                  {nodeKey === activeDialogue?.start_node_id && (
                    <span style={{ fontSize: '10px', padding: '1px 4px', borderRadius: '3px', backgroundColor: isSelected ? '#FFFFFF' : 'var(--sand)', color: 'var(--deep-earth)' }}>
                      Start
                    </span>
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* 2. NODE EDITOR */}
        <div className="card">
          <h3 style={{ fontSize: '16px', color: 'var(--deep-earth)', marginBottom: '16px' }}>
            Editing Node: <span style={{ color: 'var(--terracotta)' }}>{selectedNodeKey}</span>
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div>
              <label style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>Speaker Name</label>
              <input
                type="text"
                className="input-field"
                value={currentNode.speaker || ''}
                onChange={(e) => updateCurrentNode({ speaker: e.target.value })}
              />
            </div>

            <div>
              <label style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>Dialogue Text</label>
              <textarea
                className="input-field"
                rows={4}
                value={currentNode.text || ''}
                onChange={(e) => updateCurrentNode({ text: e.target.value })}
              />
            </div>

            <div>
              <label style={{ fontSize: '12px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                Next Node (Linear Continuation)
              </label>
              <input
                type="text"
                className="input-field"
                placeholder="Target node ID, or leave blank if branching choices"
                value={currentNode.next || ''}
                onChange={(e) => updateCurrentNode({ next: e.target.value })}
              />
            </div>

            {/* Choices Section */}
            <div style={{ backgroundColor: 'var(--bg-primary)', padding: '14px', borderRadius: '8px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                <span style={{ fontSize: '13px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                  Branching Choices ({currentNode.choices?.length || 0})
                </span>
                <button
                  type="button"
                  onClick={() => {
                    const newChoice = { text: 'New choice option...', next: '' };
                    updateCurrentNode({ choices: [...(currentNode.choices || []), newChoice] });
                  }}
                  className="btn-secondary"
                  style={{ padding: '4px 8px', fontSize: '12px' }}
                >
                  <Plus size={14} /> Add Choice
                </button>
              </div>

              {currentNode.choices && currentNode.choices.length > 0 ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  {currentNode.choices.map((choice, cIdx) => (
                    <div key={cIdx} style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                      <input
                        type="text"
                        className="input-field"
                        style={{ flex: 2 }}
                        value={choice.text}
                        onChange={(e) => {
                          const updated = [...currentNode.choices!];
                          updated[cIdx] = { ...updated[cIdx], text: e.target.value };
                          updateCurrentNode({ choices: updated });
                        }}
                      />
                      <input
                        type="text"
                        className="input-field"
                        style={{ flex: 1 }}
                        placeholder="Next node"
                        value={choice.next || ''}
                        onChange={(e) => {
                          const updated = [...currentNode.choices!];
                          updated[cIdx] = { ...updated[cIdx], next: e.target.value };
                          updateCurrentNode({ choices: updated });
                        }}
                      />
                      <button
                        type="button"
                        onClick={() => {
                          const updated = currentNode.choices!.filter((_, i) => i !== cIdx);
                          updateCurrentNode({ choices: updated });
                        }}
                        style={{ color: '#C53030', padding: '6px' }}
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  ))}
                </div>
              ) : (
                <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                  No choices added for this node. The dialogue will proceed to the next linear node.
                </p>
              )}
            </div>
          </div>
        </div>

        {/* 3. IN-GAME DIALOGUE BOX PREVIEW */}
        <div className="card" style={{ backgroundColor: 'var(--deep-earth)', color: '#FFFFFF', padding: '20px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '14px' }}>
            <Play size={18} color="var(--warm-gold)" />
            <h3 style={{ fontSize: '15px', color: 'var(--warm-gold)', fontWeight: 'bold' }}>
              In-Game Preview
            </h3>
          </div>

          <div style={{
            backgroundColor: 'var(--sand)',
            border: '3px solid var(--warm-gold)',
            borderRadius: '10px',
            padding: '16px',
            color: 'var(--charcoal)',
            display: 'flex',
            flexDirection: 'column',
            gap: '12px',
            minHeight: '220px',
          }}>
            <div>
              <span style={{ fontSize: '14px', fontWeight: 'bold', color: 'var(--deep-earth)' }}>
                {previewNode.speaker}
              </span>
            </div>

            <p style={{ fontSize: '13px', lineHeight: 1.4, flex: 1 }}>
              "{previewNode.text}"
            </p>

            {/* Interactive choices preview */}
            {previewNode.choices && previewNode.choices.length > 0 ? (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', marginTop: '10px' }}>
                {previewNode.choices.map((ch, i) => (
                  <button
                    key={i}
                    onClick={() => {
                      if (ch.next && nodes[ch.next]) {
                        setPreviewNodeKey(ch.next);
                      }
                    }}
                    style={{
                      backgroundColor: 'var(--terracotta)',
                      color: '#FFFFFF',
                      padding: '6px 12px',
                      borderRadius: '4px',
                      fontSize: '12px',
                      fontWeight: '600',
                      textAlign: 'left',
                    }}
                  >
                    ▶ {ch.text}
                  </button>
                ))}
              </div>
            ) : previewNode.next && nodes[previewNode.next] ? (
              <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '10px' }}>
                <button
                  onClick={() => setPreviewNodeKey(previewNode.next!)}
                  style={{
                    backgroundColor: 'var(--terracotta)',
                    color: '#FFFFFF',
                    padding: '6px 14px',
                    borderRadius: '4px',
                    fontSize: '12px',
                    fontWeight: '600',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px',
                  }}
                >
                  <span>NEXT</span>
                  <ArrowRight size={14} />
                </button>
              </div>
            ) : (
              <div style={{ fontSize: '11px', color: 'var(--forest-green)', fontWeight: 'bold', textAlign: 'right' }}>
                [Conversation Ends]
              </div>
            )}
          </div>

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '16px' }}>
            <span style={{ fontSize: '12px', color: 'var(--ivory)' }}>
              Current Preview: <strong>{previewNodeKey}</strong>
            </span>
            <button
              onClick={() => setPreviewNodeKey(activeDialogue?.start_node_id || 'start')}
              style={{ fontSize: '12px', color: 'var(--warm-gold)', textDecoration: 'underline' }}
            >
              Reset to Start
            </button>
          </div>
        </div>

      </div>
    </div>
  );
};
