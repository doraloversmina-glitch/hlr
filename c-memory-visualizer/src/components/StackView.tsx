import React from 'react';
import { useExecutionStore } from '../store/executionStore';
import { Variable, PointerValue } from '../types';

export const StackView: React.FC = () => {
  const { callStack } = useExecutionStore();

  if (callStack.length === 0) {
    return (
      <div className="p-4">
        <div className="text-gray-500 text-sm">
          No stack frames yet. Load and run code to see the stack.
        </div>
      </div>
    );
  }

  const renderValue = (variable: Variable): string => {
    if (typeof variable.value === 'number') {
      return variable.value.toString();
    }

    if (Array.isArray(variable.value)) {
      return `[${variable.value.join(', ')}]`;
    }

    if (variable.value && typeof variable.value === 'object' && 'targetBlock' in variable.value) {
      const ptr = variable.value as PointerValue;
      if (ptr.targetBlock === null) {
        return 'NULL';
      }
      return `───► ${ptr.targetBlock}`;
    }

    return String(variable.value);
  };

  return (
    <div className="p-4 space-y-4">
      {callStack.map((frame, frameIdx) => (
        <div key={frameIdx} className="memory-block animate-fade-in">
          <div className="text-xs text-gray-400 mb-3 pb-2 border-b border-42-gray">
            <div className="flex items-center justify-between">
              <span className="text-42-cyan font-bold">
                FRAME: {frame.functionName}()
              </span>
              <span className="address">{frame.framePointer}</span>
            </div>
          </div>

          <div className="space-y-2">
            {frame.variables.size === 0 ? (
              <div className="text-gray-600 text-xs">No variables yet</div>
            ) : (
              Array.from(frame.variables.entries()).map(([name, variable]) => (
                <div key={name} className="variable-row">
                  <span className="text-42-cyan min-w-[60px]">{name}</span>
                  <span className="text-gray-500">=</span>
                  <span className={`value flex-1 ${
                    variable.isPointer ? 'pointer-arrow' : ''
                  }`}>
                    {renderValue(variable)}
                  </span>
                  <span className="address">{variable.address}</span>
                </div>
              ))
            )}
          </div>
        </div>
      ))}
    </div>
  );
};
