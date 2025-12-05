import React from 'react';
import { useExecutionStore } from '../store/executionStore';
import { HeapBlock } from '../types';

export const HeapView: React.FC = () => {
  const { heap } = useExecutionStore();

  const heapBlocks = Array.from(heap.values());

  if (heapBlocks.length === 0) {
    return (
      <div className="p-4">
        <div className="text-gray-500 text-sm">
          No heap allocations yet. Use malloc() to allocate memory.
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 space-y-4">
      {heapBlocks.map((block) => (
        <div
          key={block.id}
          className={`memory-block animate-slide-in ${
            block.status === 'allocated'
              ? 'memory-block-allocated'
              : 'memory-block-freed'
          }`}
        >
          <div className="flex items-center justify-between mb-3 pb-2 border-b border-42-gray">
            <div className="flex items-center gap-2">
              <span className={`${
                block.status === 'allocated' ? 'text-green-400' : 'text-red-400'
              } font-bold`}>
                {block.status === 'allocated' ? '✓' : '✗'}
              </span>
              <span className="address">{block.address}</span>
              <span className="text-gray-600">({block.size} bytes)</span>
            </div>
            <span className={`text-xs font-bold ${
              block.status === 'allocated' ? 'text-green-400' : 'text-red-400'
            }`}>
              {block.status === 'allocated' ? 'ALLOCATED' : 'FREED'}
            </span>
          </div>

          <div className="text-xs space-y-1">
            <div className="text-gray-400">
              malloc() at line {block.allocatedAt}
            </div>
            {block.freedAt && (
              <div className="text-red-400">
                free() at line {block.freedAt}
              </div>
            )}

            {block.status === 'allocated' && block.data.length > 0 && (
              <div className="mt-3 pt-3 border-t border-42-gray">
                <div className="text-gray-400 mb-2">Data:</div>
                <div className="flex flex-wrap gap-2">
                  {block.data.map((value, idx) => (
                    <div key={idx} className="flex items-center gap-1">
                      <span className="text-gray-600">[{idx}]</span>
                      <span className="value">
                        {value !== null ? value : '???'}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {block.status === 'freed' && (
              <div className="mt-3 pt-3 border-t border-red-900 text-red-400">
                ⚠️ Invalid memory - do not access!
              </div>
            )}
          </div>
        </div>
      ))}
    </div>
  );
};
