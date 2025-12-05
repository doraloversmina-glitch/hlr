import React, { useEffect, useState } from 'react';
import { useExecutionStore } from '../store/executionStore';

const EXAMPLES = [
  {
    name: '00_hello_ptr',
    title: 'Hello Pointers',
    code: `int main(void)
{
    int x;
    int *p;

    x = 42;
    p = &x;
    *p = 21;
    return (0);
}`
  },
  {
    name: '01_malloc',
    title: 'Basic Malloc',
    code: `int main(void)
{
    int *p;

    p = malloc(sizeof(int));
    *p = 42;
    free(p);
    return (0);
}`
  },
  {
    name: '02_array',
    title: 'Array Allocation',
    code: `int main(void)
{
    int *arr;
    int i;

    arr = malloc(sizeof(int) * 5);
    i = 0;
    while (i < 5)
    {
        arr[i] = i * 10;
        i = i + 1;
    }
    free(arr);
    return (0);
}`
  },
  {
    name: '03_bug',
    title: 'Find the Bug!',
    code: `int main(void)
{
    int *p;

    p = malloc(sizeof(int));
    *p = 42;
    free(p);
    *p = 21;
    return (0);
}`
  },
  {
    name: '04_leak',
    title: 'Memory Leak',
    code: `int main(void)
{
    int *p1;
    int *p2;

    p1 = malloc(sizeof(int) * 10);
    p2 = malloc(sizeof(int) * 20);
    free(p1);
    return (0);
}`
  }
];

export const CodeEditor: React.FC = () => {
  const { code, setCode, currentLine } = useExecutionStore();
  const [editableCode, setEditableCode] = useState(code);

  useEffect(() => {
    if (code !== editableCode) {
      setEditableCode(code);
    }
  }, [code]);

  const handleLoadExample = (exampleCode: string) => {
    setCode(exampleCode);
    setEditableCode(exampleCode);
  };

  const handleCodeChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setEditableCode(e.target.value);
  };

  const handleApplyCode = () => {
    setCode(editableCode);
  };

  const lines = editableCode.split('\n');

  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      {/* Code Display */}
      <div className="flex-1 overflow-auto p-4 bg-42-darker">
        <div className="font-mono text-sm">
          {lines.map((line, idx) => {
            const lineNum = idx + 1;
            const isCurrent = lineNum === currentLine;

            return (
              <div
                key={idx}
                className={`code-line ${isCurrent ? 'code-line-current' : ''}`}
              >
                <span className="text-gray-600 select-none mr-2 inline-block w-8 text-right">
                  {isCurrent && '►'}{lineNum}
                </span>
                <span className="text-gray-300">{line || ' '}</span>
              </div>
            );
          })}
        </div>
      </div>

      {/* Code Input */}
      <div className="border-t border-42-gray bg-42-darker p-3">
        <div className="mb-2">
          <textarea
            value={editableCode}
            onChange={handleCodeChange}
            className="w-full h-32 p-2 bg-42-dark border border-42-gray text-xs font-mono text-white resize-none focus:outline-none focus:border-42-cyan"
            placeholder="Paste your C code here..."
          />
        </div>
        <div className="flex items-center justify-between">
          <button
            onClick={handleApplyCode}
            className="btn btn-primary text-xs"
          >
            Load Code
          </button>
          <div className="text-xs text-gray-500">
            or select example →
          </div>
        </div>
      </div>

      {/* Examples */}
      <div className="border-t border-42-gray bg-42-darker p-3">
        <div className="text-xs text-gray-400 mb-2">EXAMPLES:</div>
        <div className="flex flex-wrap gap-2">
          {EXAMPLES.map((example) => (
            <button
              key={example.name}
              onClick={() => handleLoadExample(example.code)}
              className="btn text-xs"
              title={example.title}
            >
              {example.title}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};
