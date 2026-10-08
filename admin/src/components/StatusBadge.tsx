import React from 'react';
import { ContentStatus } from '../types';

interface StatusBadgeProps {
  status: ContentStatus | string;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const norm = (status || 'DRAFT').toUpperCase();
  if (norm === 'PUBLISHED') {
    return <span className="badge badge-published">Published</span>;
  }
  if (norm === 'ARCHIVED') {
    return <span className="badge badge-archived">Archived</span>;
  }
  return <span className="badge badge-draft">Draft</span>;
};
