import React from 'react';
import { useExecutionStore } from '../store/executionStore';

const ERROR_DESCRIPTIONS = {
  OOB: 'Array index out of bounds',
  UAF: 'Use-after-free - accessing freed memory',
  NULL_DEREF: 'Null pointer dereference',
  DOUBLE_FREE: 'Double free - freeing already freed memory',
  LEAK: 'Memory leak - allocated memory not freed',
  SYNTAX: 'Syntax or parse error'
};

export const ErrorDisplay: React.FC = () => {
  const { errors } = useExecutionStore();

  if (errors.length === 0) {
    return (
      <div className="p-3 bg-42-darker border-t border-42-gray">
        <div className="flex items-center gap-2 text-xs">
          <span className="text-green-500">✓</span>
          <span className="text-gray-400">No errors detected</span>
        </div>
      </div>
    );
  }

  return (
    <div className="p-3 bg-42-darker border-t border-42-gray">
      <div className="space-y-2">
        {errors.map((error, idx) => (
          <div key={idx} className="error-box animate-fade-in">
            <div className="flex items-start gap-2">
              <span className="text-red-500 font-bold text-lg">⚠️</span>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-red-400 font-bold text-xs">
                    {error.type}
                  </span>
                  <span className="text-gray-600 text-xs">
                    Line {error.line}
                  </span>
                </div>
                <div className="text-white text-sm mb-1">
                  {error.message}
                </div>
                <div className="text-gray-400 text-xs">
                  {ERROR_DESCRIPTIONS[error.type] || 'Unknown error'}
                </div>
                {error.details && (
                  <div className="text-gray-500 text-xs mt-2">
                    {error.details}
                  </div>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
