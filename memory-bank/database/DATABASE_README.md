# Memory Bank Database

*Initialized: 2025-05-12 15:15:01 GMT+5:30*

## Overview

This directory contains the SQLite database for your Memory Bank using better-sqlite3 for direct database access.

## Quick Start

### 1. Install Dependencies
```bash
pnpm install
```

### 2. Parse Memory Bank Files

Parse edit history:
```bash
node parse-edits.js
```

Parse tasks:
```bash
node parse-tasks.js
```

Or parse both at once:
```bash
pnpm run parse
```

**Supported Formats:**

Edit history entries support both formats:
- With timezone: `#### 19:43:25 IST - T3: Description`
- Without timezone: `#### 03:37 - T13: Description` (defaults to UTC)

File modifications:
- `- Created \`file\` - description`
- `- Modified \`file\` - description`
- `- Updated \`file\` - description`

Tasks table format (flexible column count):
- Basic: `| T1 | Title | 🔄 | HIGH | 2025-11-03 | Dependencies |`
- With status details: `| T1 | Title | 🔄 (70%) | HIGH | 2025-11-03 | - | Extra info |`
- Status icons: 🔄 (in progress), ✅ (completed), ⏸️ (paused)

### 3. Query the Database

View statistics:
```bash
node query.js stats
```

View all entries:
```bash
node query.js all 50
```

Query by task:
```bash
node query.js task T3
```

Search files:
```bash
node query.js files schema.prisma
```

### 4. View Tasks

```bash
node query-tasks.js
```

## Files

- **parse-edits.js** - Parser for edit_history.md
- **parse-tasks.js** - Parser for tasks.md
- **query.js** - Interactive query tool for edit history
- **query-tasks.js** - Task query tool
- **memory_bank.db** - SQLite database (generated after parsing)

## Database Structure

The database contains two main tables:

**edit_entries** - Records from edit_history.md
- date, time, timezone, timestamp
- task_id (optional)
- task_description

**edit_modifications** - File changes within each entry
- action (Created, Modified, Updated)
- file_path
- description

**task_items** - Records from tasks.md
- id (task ID like T1, T2)
- title, status, priority
- started date
- details

**task_dependencies** - Relationships between tasks
- task_id -> depends_on

## Using with SQLite Tools

The memory_bank.db file is a standard SQLite database and can be opened with:
- DB Browser for SQLite (https://sqlitebrowser.org/)
- sqlite3 command-line tool: `sqlite3 memory_bank.db`
- VS Code SQLite extensions
- Any SQLite viewer

## Next Steps

1. Install dependencies: `pnpm install`
2. Parse your markdown files: `pnpm run parse`
3. Query the database: `node query.js stats`
4. Open memory_bank.db in your favorite SQLite viewer
