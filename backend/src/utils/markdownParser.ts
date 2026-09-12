export interface ParsedFile {
  filepath: string;
  code: string;
}

export function parseMarkdownFiles(markdown: string): ParsedFile[] {
  const files: ParsedFile[] = [];
  const lines = markdown.split('\n');

  let currentFilepath = '';
  let inCodeBlock = false;
  let currentCode: string[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Check for file header
    if (line.trim().startsWith('### FILE:')) {
      // If we already had a file but didn't hit a closing block (malformed), save it
      if (currentFilepath && currentCode.length > 0 && !inCodeBlock) {
        files.push({ filepath: currentFilepath, code: currentCode.join('\n') });
      }

      currentFilepath = line.replace('### FILE:', '').trim();
      currentCode = [];
      inCodeBlock = false;
      continue;
    }

    // Check for code block boundaries
    if (line.trim().startsWith('```')) {
      if (inCodeBlock) {
        // Closing the code block
        inCodeBlock = false;
        if (currentFilepath) {
          files.push({ filepath: currentFilepath, code: currentCode.join('\n') });
          currentFilepath = '';
          currentCode = [];
        }
      } else {
        // Opening the code block
        inCodeBlock = true;
      }
      continue;
    }

    // If we are inside a code block and have a filepath, capture the code
    if (inCodeBlock && currentFilepath) {
      currentCode.push(line);
    }
  }

  // Handle case where file wasn't properly closed
  if (currentFilepath && currentCode.length > 0) {
    files.push({ filepath: currentFilepath, code: currentCode.join('\n') });
  }

  return files;
}
