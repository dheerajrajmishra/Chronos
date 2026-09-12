import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

export interface CodeFileNode {
  path: string;
  name: string;
  extension: string;
  sizeBytes: number;
  category: 'source' | 'model' | 'controller' | 'config' | 'test' | 'schema' | 'doc';
  mtime: number;
}

export interface CodeModule {
  name: string;
  directory: string;
  filesCount: number;
  tech: string;
  keyFiles: string[];
}

export interface CodebaseGraph {
  projectId: string;
  repoPath: string;
  repoUrl?: string;
  branch: string;
  lastSyncedAt: string;
  filesCount: number;
  totalSizeBytes: number;
  techStack: string[];
  dependencies: Record<string, string>;
  modules: CodeModule[];
  topFiles: CodeFileNode[];
  graphDigest: string;
  isFromCache: boolean;
  summaryMarkdown: string;
}

const IGNORED_DIRS = new Set([
  'node_modules',
  '.git',
  '.dart_tool',
  'dist',
  'build',
  '__pycache__',
  '.idea',
  '.vscode',
  'coverage',
  '.pub-cache',
  '.pub',
  'postgres_data',
]);

const IGNORED_EXTENSIONS = new Set([
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.ico',
  '.svg',
  '.pdf',
  '.zip',
  '.tar',
  '.gz',
  '.mp4',
  '.webm',
  '.lock',
]);

function getCacheDir(): string {
  const dir = path.join(__dirname, '..', '..', 'cache', 'graphs');
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

function getCacheFilePath(projectId: string): string {
  const safeId = projectId.replace(/[^a-zA-Z0-9_-]/g, '_');
  return path.join(getCacheDir(), `${safeId}.json`);
}

function categorizeFile(fileName: string, relativePath: string): CodeFileNode['category'] {
  const lower = fileName.toLowerCase();
  const relLower = relativePath.toLowerCase();

  if (lower.includes('test') || relLower.includes('test')) return 'test';
  if (lower.includes('model') || relLower.includes('model')) return 'model';
  if (lower.includes('controller') || relLower.includes('controller')) return 'controller';
  if (lower.endsWith('.sql') || lower.includes('schema') || lower.includes('migration')) return 'schema';
  if (lower.endsWith('.md') || lower.endsWith('.txt')) return 'doc';
  if (
    lower.endsWith('.json') ||
    lower.endsWith('.yaml') ||
    lower.endsWith('.yml') ||
    lower.endsWith('.toml') ||
    lower.startsWith('docker') ||
    lower.startsWith('.env')
  ) {
    return 'config';
  }
  return 'source';
}

interface ScanFileState {
  files: CodeFileNode[];
  totalSize: number;
  hasher: crypto.Hash;
}

function scanDirectory(
  currentDir: string,
  rootPath: string,
  state: ScanFileState,
  currentDepth = 0,
  maxDepth = 7
): void {
  if (currentDepth > maxDepth) return;
  if (!fs.existsSync(currentDir)) return;

  let entries: fs.Dirent[];
  try {
    entries = fs.readdirSync(currentDir, { withFileTypes: true });
  } catch (err) {
    return;
  }

  for (const entry of entries) {
    const entryName = entry.name;
    const fullPath = path.join(currentDir, entryName);

    if (entry.isDirectory()) {
      if (IGNORED_DIRS.has(entryName) || entryName.startsWith('.')) continue;
      scanDirectory(fullPath, rootPath, state, currentDepth + 1, maxDepth);
    } else if (entry.isFile()) {
      const ext = path.extname(entryName).toLowerCase();
      if (IGNORED_EXTENSIONS.has(ext)) continue;

      try {
        const stats = fs.statSync(fullPath);
        const relPath = path.relative(rootPath, fullPath).replace(/\\/g, '/');
        
        state.hasher.update(`${relPath}:${stats.mtimeMs}:${stats.size}`);
        state.totalSize += stats.size;

        state.files.push({
          path: relPath,
          name: entryName,
          extension: ext,
          sizeBytes: stats.size,
          category: categorizeFile(entryName, relPath),
          mtime: Math.floor(stats.mtimeMs),
        });
      } catch (e) {
        // Skip unreadable files
      }
    }
  }
}

function extractDependenciesAndTech(rootPath: string): { techStack: string[]; dependencies: Record<string, string> } {
  const techStack = new Set<string>();
  const dependencies: Record<string, string> = {};

  // 1. Check Node / TypeScript package.json
  const pkgPaths = [
    path.join(rootPath, 'package.json'),
    path.join(rootPath, 'backend', 'package.json'),
  ];
  for (const p of pkgPaths) {
    if (fs.existsSync(p)) {
      try {
        const content = JSON.parse(fs.readFileSync(p, 'utf-8'));
        techStack.add('Node.js');
        if (content.dependencies?.typescript || content.devDependencies?.typescript) techStack.add('TypeScript');
        if (content.dependencies?.['@temporalio/workflow']) techStack.add('Temporal Durable Execution');
        if (content.dependencies?.['@langchain/openai']) techStack.add('LangChain AI');
        if (content.dependencies?.express) techStack.add('Express.js REST API');
        if (content.dependencies?.pg) techStack.add('PostgreSQL Driver (pg)');

        if (content.dependencies) {
          Object.assign(dependencies, content.dependencies);
        }
      } catch (e) {}
    }
  }

  // 2. Check Flutter pubspec.yaml
  const pubspecPaths = [
    path.join(rootPath, 'pubspec.yaml'),
    path.join(rootPath, 'frontend', 'pubspec.yaml'),
  ];
  for (const p of pubspecPaths) {
    if (fs.existsSync(p)) {
      try {
        const raw = fs.readFileSync(p, 'utf-8');
        techStack.add('Flutter / Dart');
        if (raw.includes('get:')) techStack.add('GetX State Architecture');
        if (raw.includes('google_fonts:')) techStack.add('Google Fonts');
        if (raw.includes('flutter_markdown:')) techStack.add('Flutter Markdown');
        if (raw.includes('http:')) techStack.add('HTTP Networking');
      } catch (e) {}
    }
  }

  // 3. Check Python requirements.txt
  const reqPaths = [
    path.join(rootPath, 'requirements.txt'),
    path.join(rootPath, 'zero_trust_gateway', 'requirements.txt'),
  ];
  for (const p of reqPaths) {
    if (fs.existsSync(p)) {
      try {
        const raw = fs.readFileSync(p, 'utf-8');
        techStack.add('Python 3');
        if (raw.includes('fastapi')) techStack.add('FastAPI Microservices');
        if (raw.includes('presidio')) techStack.add('Microsoft Presidio DLP Tokenizer');
        if (raw.includes('redis')) techStack.add('Redis Token Vault');
      } catch (e) {}
    }
  }

  // 4. Check Docker Compose
  const dockerPath = path.join(rootPath, 'docker-compose.yml');
  if (fs.existsSync(dockerPath)) {
    try {
      const raw = fs.readFileSync(dockerPath, 'utf-8');
      techStack.add('Docker Compose');
      if (raw.includes('postgres:')) techStack.add('PostgreSQL Database');
      if (raw.includes('redis:')) techStack.add('Redis 7 In-Memory Store');
      if (raw.includes('temporalio/')) techStack.add('Temporal Server Cluster');
    } catch (e) {}
  }

  return {
    techStack: Array.from(techStack),
    dependencies,
  };
}

function identifyModules(files: CodeFileNode[]): CodeModule[] {
  const dirBuckets: Record<string, { count: number; keyFiles: string[]; tech: string }> = {};

  for (const f of files) {
    const parts = f.path.split('/');
    if (parts.length >= 2) {
      const topDir = parts.length >= 3 ? `${parts[0]}/${parts[1]}` : parts[0];
      if (!dirBuckets[topDir]) {
        dirBuckets[topDir] = { count: 0, keyFiles: [], tech: 'Mixed' };
      }
      dirBuckets[topDir].count++;
      if (dirBuckets[topDir].keyFiles.length < 5) {
        dirBuckets[topDir].keyFiles.push(f.name);
      }

      if (f.path.startsWith('frontend/')) dirBuckets[topDir].tech = 'Flutter/Dart (Client)';
      else if (f.path.startsWith('backend/')) dirBuckets[topDir].tech = 'Node.js/TypeScript (Server)';
      else if (f.path.startsWith('zero_trust_gateway/')) dirBuckets[topDir].tech = 'Python/FastAPI (Gateway)';
    }
  }

  return Object.entries(dirBuckets)
    .sort((a, b) => b[1].count - a[1].count)
    .slice(0, 10)
    .map(([dir, info]) => ({
      name: path.basename(dir),
      directory: dir,
      filesCount: info.count,
      tech: info.tech,
      keyFiles: info.keyFiles,
    }));
}

function generateGraphSummaryMarkdown(
  repoPath: string,
  techStack: string[],
  modules: CodeModule[],
  filesCount: number,
  totalSizeBytes: number,
  dependencies: Record<string, string>
): string {
  const sizeMb = (totalSizeBytes / (1024 * 1024)).toFixed(2);
  const depList = Object.keys(dependencies).slice(0, 12).join(', ');

  return `### Codebase Graph & Architecture Baseline
- **Root Location:** \`${repoPath}\`
- **Total Files Indexed:** ${filesCount} files (${sizeMb} MB source footprint)
- **Primary Tech Stack:** ${techStack.join(', ')}
- **Key Modules Detected:**
${modules.map(m => `  - **\`${m.directory}\`** (${m.filesCount} files, ${m.tech}): ${m.keyFiles.join(', ')}`).join('\n')}
- **Core Dependencies:** ${depList || 'Standard framework dependencies'}
`;
}

export async function scanRepositoryGraph(
  projectPath: string,
  projectId = 'default',
  repoUrl = 'https://github.com/dheerajrajmishra/Chronos.git',
  branch = 'main',
  forceResync = false
): Promise<CodebaseGraph> {
  const cacheFile = getCacheFilePath(projectId);

  // Fast pre-check: calculate current directory digest
  const state: ScanFileState = {
    files: [],
    totalSize: 0,
    hasher: crypto.createHash('sha256'),
  };

  scanDirectory(projectPath, projectPath, state);
  const currentDigest = state.hasher.digest('hex');

  // Check if cache is still valid
  if (!forceResync && fs.existsSync(cacheFile)) {
    try {
      const cached = JSON.parse(fs.readFileSync(cacheFile, 'utf-8')) as CodebaseGraph;
      if (cached.graphDigest === currentDigest && cached.filesCount === state.files.length) {
        cached.isFromCache = true;
        return cached;
      }
    } catch (e) {
      // Invalid cache, continue to re-index
    }
  }

  // Full Indexing
  const { techStack, dependencies } = extractDependenciesAndTech(projectPath);
  const modules = identifyModules(state.files);
  const topFiles = state.files
    .filter(f => f.category === 'controller' || f.category === 'model' || f.category === 'schema' || f.category === 'config')
    .slice(0, 30);

  const summaryMarkdown = generateGraphSummaryMarkdown(
    projectPath,
    techStack,
    modules,
    state.files.length,
    state.totalSize,
    dependencies
  );

  const graph: CodebaseGraph = {
    projectId,
    repoPath: projectPath,
    repoUrl,
    branch,
    lastSyncedAt: new Date().toISOString(),
    filesCount: state.files.length,
    totalSizeBytes: state.totalSize,
    techStack,
    dependencies,
    modules,
    topFiles,
    graphDigest: currentDigest,
    isFromCache: false,
    summaryMarkdown,
  };

  // Write to local cache
  try {
    fs.writeFileSync(cacheFile, JSON.stringify(graph, null, 2), 'utf-8');
  } catch (err) {
    console.warn('[CodeGraph] Warning: Failed to write graph cache to disk', err);
  }

  return graph;
}

export function getCachedRepositoryGraph(projectId: string): CodebaseGraph | null {
  const cacheFile = getCacheFilePath(projectId);
  if (fs.existsSync(cacheFile)) {
    try {
      const graph = JSON.parse(fs.readFileSync(cacheFile, 'utf-8')) as CodebaseGraph;
      graph.isFromCache = true;
      return graph;
    } catch (e) {}
  }
  return null;
}
