import React from 'react';
import { useExecutionStore } from '../store/executionStore';
import { ExecutionEvent } from '../types';

const getLogIcon = (type: ExecutionEvent['type']): string => {
  switch (type) {
    case 'malloc': return '🔴';
    case 'free': return '🟢';
    case 'assignment': return '✏️';
    case 'declaration': return '📝';
    case 'error': return '❌';
    default: return '•';
  }
};

const getLogColor = (type: ExecutionEvent['type']): string => {
  switch (type) {
    case 'malloc': return 'text-green-400';
    case 'free': return 'text-red-400';
    case 'assignment': return 'text-blue-400';
    case 'declaration': return 'text-cyan-400';
    case 'error': return 'text-red-500';
    default: return 'text-gray-400';
  }
};

export const LogView: React.FC = () => {
  const { log } = useExecutionStore();

  if (log.length === 0) {
    return (
      <div className="p-4">
        <div className="text-gray-500 text-sm">
          Execution log is empty. Run code to see events.
        </div>
      </div>
    );
  }

  return (
    <div className="p-4">
      <div className="space-y-1">
        {log.map((event, idx) => (
          <div key={idx} className="log-entry">
            <span className="text-xs text-gray-600 min-w-[30px]">
              L{event.line}
            </span>
            <span className="text-xs">
              {getLogIcon(event.type)}
            </span>
            <span className={`text-xs flex-1 ${getLogColor(event.type)}`}>
              {event.message}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};
