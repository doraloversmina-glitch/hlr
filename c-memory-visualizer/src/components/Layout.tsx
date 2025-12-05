import React, { useState } from 'react';
import { Play, Square, SkipForward, RotateCcw, ChevronLeft, Pause } from 'lucide-react';
import { useExecutionStore } from '../store/executionStore';
import { CodeEditor } from './CodeEditor';
import { StackView } from './StackView';
import { HeapView } from './HeapView';
import { LogView } from './LogView';
import { ErrorDisplay } from './ErrorDisplay';

type Tab = 'stack' | 'heap' | 'log';

export const Layout: React.FC = () => {
  const {
    isRunning,
    isHalted,
    errors,
    speed,
    step,
    run,
    pause,
    reset,
    stepBack,
    setSpeed,
    history
  } = useExecutionStore();

  const [activeTab, setActiveTab] = useState<Tab>('stack');
  const [speedValue, setSpeedValue] = useState(speed);

  const handleSpeedChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newSpeed = parseInt(e.target.value);
    setSpeedValue(newSpeed);
    setSpeed(newSpeed);
  };

  return (
    <div className="h-screen flex flex-col bg-42-dark text-white font-mono">
      {/* Header */}
      <header className="border-b border-42-gray p-3 flex items-center justify-between bg-42-darker">
        <div className="flex items-center gap-4">
          <h1 className="text-42-cyan font-bold text-sm">C-MEM-VIZ v1.0.0</h1>
          <span className="text-gray-500 text-xs">42 Network Edition</span>
        </div>
        <div className="flex items-center gap-4 text-xs">
          <span className="text-gray-400">
            Status: <span className={isRunning ? 'text-green-400' : 'text-gray-500'}>
              {isRunning ? '●' : '○'} {isRunning ? 'RUNNING' : isHalted ? 'HALTED' : 'READY'}
            </span>
          </span>
        </div>
      </header>

      {/* Main Content */}
      <div className="flex-1 flex overflow-hidden">
        {/* Left: Code Editor */}
        <div className="w-1/2 border-r border-42-gray flex flex-col">
          <div className="p-2 bg-42-darker border-b border-42-gray text-xs text-gray-400 flex items-center justify-between">
            <span>CODE EDITOR</span>
            <span className="text-xs text-gray-600">
              Click examples below to load code
            </span>
          </div>
          <CodeEditor />
          <ErrorDisplay />
        </div>

        {/* Right: Visualization */}
        <div className="w-1/2 flex flex-col">
          {/* Tabs */}
          <div className="p-2 bg-42-darker border-b border-42-gray flex gap-4 text-xs">
            <button
              className={`tab-btn ${activeTab === 'stack' ? 'tab-btn-active' : ''}`}
              onClick={() => setActiveTab('stack')}
            >
              📚 STACK
            </button>
            <button
              className={`tab-btn ${activeTab === 'heap' ? 'tab-btn-active' : ''}`}
              onClick={() => setActiveTab('heap')}
            >
              🧱 HEAP
            </button>
            <button
              className={`tab-btn ${activeTab === 'log' ? 'tab-btn-active' : ''}`}
              onClick={() => setActiveTab('log')}
            >
              📋 LOG
            </button>
          </div>

          {/* Tab Content */}
          <div className="flex-1 overflow-auto">
            {activeTab === 'stack' && <StackView />}
            {activeTab === 'heap' && <HeapView />}
            {activeTab === 'log' && <LogView />}
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="border-t border-42-gray p-3 bg-42-darker flex items-center justify-between">
        <div className="flex gap-2">
          <button
            className="btn"
            onClick={reset}
            disabled={isRunning}
            title="Reset to beginning"
          >
            <RotateCcw size={14} />
            reset
          </button>
          <button
            className="btn"
            onClick={stepBack}
            disabled={isRunning || history.length === 0}
            title="Step backward"
          >
            <ChevronLeft size={14} />
            back
          </button>
          <button
            className="btn btn-primary"
            onClick={step}
            disabled={isRunning || isHalted}
            title="Execute next line"
          >
            <SkipForward size={14} />
            step
          </button>
          {isRunning ? (
            <button
              className="btn"
              onClick={pause}
              title="Pause execution"
            >
              <Pause size={14} />
              pause
            </button>
          ) : (
            <button
              className="btn"
              onClick={run}
              disabled={isHalted || errors.length > 0}
              title="Run until completion"
            >
              <Play size={14} />
              run
            </button>
          )}
        </div>

        <div className="flex items-center gap-2 text-xs">
          <span className="text-gray-400">Speed:</span>
          <input
            type="range"
            min="100"
            max="2000"
            step="100"
            value={speedValue}
            onChange={handleSpeedChange}
            className="w-32"
            disabled={isRunning}
          />
          <span className="text-gray-400 w-16">{speedValue}ms</span>
        </div>
      </div>

      {/* Command Line */}
      <div className="bg-42-darker border-t border-42-gray p-2 text-xs text-gray-500">
        <span className="text-42-cyan">&gt;</span> Ready. Load example code or paste your own.
      </div>
    </div>
  );
};
