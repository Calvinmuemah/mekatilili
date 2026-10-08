import React from 'react';
import { AlertTriangle, X } from 'lucide-react';

interface ConfirmModalProps {
  isOpen: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  confirmText?: string;
  cancelLabel?: string;
  isDestructive?: boolean;
  isDanger?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

export const ConfirmModal: React.FC<ConfirmModalProps> = ({
  isOpen,
  title,
  message,
  confirmLabel,
  confirmText,
  cancelLabel = 'Cancel',
  isDestructive = false,
  isDanger = false,
  onConfirm,
  onCancel,
}) => {
  const finalConfirmLabel = confirmLabel || confirmText || 'Confirm';
  const finalIsDestructive = isDestructive || isDanger;

  if (!isOpen) return null;

  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(33, 28, 24, 0.6)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 1000,
    }}>
      <div className="card" style={{ width: '440px', maxWidth: '90%', position: 'relative' }}>
        <button
          onClick={onCancel}
          style={{ position: 'absolute', top: '16px', right: '16px', color: 'var(--text-muted)' }}
        >
          <X size={20} />
        </button>

        <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
          <div style={{
            backgroundColor: isDestructive ? '#FDE8E8' : '#FEF3C7',
            color: isDestructive ? '#C53030' : '#D97706',
            width: '44px',
            height: '44px',
            borderRadius: '50%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexShrink: 0,
          }}>
            <AlertTriangle size={24} />
          </div>
          <div>
            <h3 style={{ fontSize: '18px', color: 'var(--deep-earth)', marginBottom: '6px' }}>{title}</h3>
            <p style={{ fontSize: '14px', color: 'var(--text-muted)' }}>{message}</p>
          </div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '24px' }}>
          <button className="btn-secondary" onClick={onCancel}>
            {cancelLabel}
          </button>
          <button
            className={finalIsDestructive ? 'btn-danger' : 'btn-primary'}
            onClick={onConfirm}
          >
            {finalConfirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
};
