# Nexor Mobile - OpenCode Components Mapping

## Purpose
Document OpenCode source locations to migrate to Nexor Flutter app.

---

## Core State Management

### Global Sync (`/packages/app/src/context/global-sync/`)

| File | Purpose | Nexor Equivalent |
|------|---------|------------------|
| `types.ts` | All TypeScript interfaces (Session, Message, Config, etc.) | Create Dart models |
| `bootstrap.ts` | Connect to server, load initial data | `servers_provider.dart` |
| `event-reducer.ts` | Handle real-time events (create/update/delete) | Chat/session providers |
| `session-cache.ts` | LRU cache for sessions (40 limit) | `session_repository.dart` |
| `session-load.ts` | Load sessions with pagination | `get_sessions.dart` |
| `session-trim.ts` | Remove old sessions | Auto-cleanup logic |
| `session-prefetch.ts` | Preload sessions | Optimistic loading |
| `child-store.ts` | Multi-directory support | Future: project support |
| `queue.ts` | Refresh/update queue | `ref.invalidate()` |

### File Management (`/packages/app/src/context/file/`)

| File | Purpose | Nexor Equivalent |
|------|---------|------------------|
| `tree-store.ts` | File tree state (expand/collapse/load) | `files_provider.dart` |
| `content-cache.ts` | LRU cache for file content (40 files, 20MB) | `file_repository.dart` |
| `path.ts` | Path utilities | `path_validator.dart` |
| `watcher.ts` | Watch file changes | Not implemented |
| `view-cache.ts` | Cache file views | Not implemented |

### Command System (`/packages/app/src/context/command.tsx`)

| Feature | Purpose |
|---------|---------|
| Keybinds | Global keyboard shortcuts |
| Command Palette | Ctrl+Shift+P style |
| Slash Commands | `/` prefixed commands |

---

## Hooks

| File | Purpose |
|------|---------|
| `/hooks/use-providers.ts` | AI Provider selection & connection status |

---

## Components

| Path | Purpose |
|------|---------|
| `/components/settings-providers.tsx` | Provider settings UI |
| `/components/dialog-select-provider.tsx` | Provider picker |
| `/components/dialog-custom-provider.tsx` | Custom provider form |

---

## SDK (`/packages/sdk/`)

```
sdk/js/src/client/v2/
├── session.ts      → Session CRUD
├── message.ts      → Message handling
├── provider.ts     → Provider management
├── project.ts      → Project info
├── config.ts       → Configuration
├── path.ts         → Path operations
├── command.ts      → Commands
├── mcp.ts          → MCP status
├── lsp.ts          → LSP status
└── vcs.ts          → Version control
```

---

## Key Types (from `types.ts`)

```typescript
Session {
  id, title, directory, parentID, agent,
  time: { created, updated, archived },
  model: { providerID, modelID }
}

Message {
  id, sessionID, role: 'user' | 'assistant',
  time: { created, updated },
  parts: Part[]
}

Part {
  id, messageID, sessionID,
  type: 'text' | 'tool_use' | 'tool_result' | 'error' | 'stop'
}

PermissionRequest {
  id, sessionID, type, description, fingerprint
}

QuestionRequest {
  id, sessionID, text, options
}

Todo {
  id, sessionID, status, content
}
```

---

## Migration Notes

### State Management

| OpenCode | Nexor (Riverpod) |
|----------|-------------------|
| `createStore()` | `StateNotifier` |
| `createMemo()` | `select()` |
| `reconcile()` | `copyWith()` |
| `produce()` | Immutable updates |
| `batch()` | `runBatch()` |
| `createContext` | `Provider.family` |

### File Paths

```
OpenCode: /packages/app/src/context/
Nexor:    /lib/presentation/providers/
          /lib/core/session/
          /lib/data/repositories/
```

---

## Quick Reference

| Need | Source |
|-------|--------|
| Session logic | `global-sync/event-reducer.ts` |
| Message handling | `global-sync/event-reducer.ts:177-211` |
| File tree | `file/tree-store.ts` |
| Provider setup | `hooks/use-providers.ts` |
| Types | `global-sync/types.ts` |
| Bootstrap | `global-sync/bootstrap.ts` |
