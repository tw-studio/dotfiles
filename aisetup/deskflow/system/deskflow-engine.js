#!/usr/bin/env node
// Deskflow Engine — deterministic bookkeeping for the Deskflow system.
// Spec: deskflow/system/deskflow-engine-README.md
// Invoked only through `just desk*` commands; user never runs this directly.
// Zero dependencies: Node built-ins only.

'use strict';

const fs = require('fs');
const path = require('path');

////////////////////////////////////////////////////////////////////////////////
//
// MARK: Paths (relative to workspace root, where justfile runs)
//
////////////////////////////////////////////////////////////////////////////////

const PATHS = {
    desk: 'deskflow/desk',
    deskArchive: 'deskflow/desk/archive',
    epics: 'deskflow/epics',
    epicsIndex: 'deskflow/epics/EPICS.md',
    board: 'deskflow/TASKBOARD.md',
    snapshots: 'deskflow/system/snapshots',
    boardHistory: 'deskflow/system/board-history',
    engineEvents: 'deskflow/system/engine-events.md',
};

////////////////////////////////////////////////////////////////////////////////
//
// MARK: Utilities
//
////////////////////////////////////////////////////////////////////////////////

function now() {
    const d = new Date();
    return {
        date: d,
        ymd: fmt(d, 'yymmdd'),
        hm: fmt(d, 'hhmm'),
        hms: fmt(d, 'hhmmss'),
        day: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'][d.getDay()],
        iso: d.toISOString().replace(/[TZ]/g, ' ').trim().slice(0, 16),
    };
}

function fmt(d, shape) {
    const yy = String(d.getFullYear()).slice(2);
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    const hh = String(d.getHours()).padStart(2, '0');
    const mi = String(d.getMinutes()).padStart(2, '0');
    const ss = String(d.getSeconds()).padStart(2, '0');
    if (shape === 'yymmdd') return `${yy}${mm}${dd}`;
    if (shape === 'hhmm') return `${hh}${mi}`;
    if (shape === 'hhmmss') return `${hh}${mi}${ss}`;
    return '';
}

function ensureDir(p) { fs.mkdirSync(p, { recursive: true }); }

function readIfExists(p) {
    try { return fs.readFileSync(p, 'utf8'); } catch { return null; }
}

const DESK_NAME = /^DESK_\d{6}-\d{4}(-\d{2})?\.md$/;

function latestFile(dir, prefix) {
    ensureDir(dir);
    const files = fs.readdirSync(dir)
        .filter(f => f.startsWith(prefix) && f.endsWith('.md'))
        .filter(f => prefix !== 'DESK_' || DESK_NAME.test(f))
        .sort();
    return files.length ? path.join(dir, files[files.length - 1]) : null;
}

function deskStampName(t) {
    const base = `DESK_${t.ymd}-${t.hm}.md`;
    const full = path.join(PATHS.desk, base);
    if (!fs.existsSync(full)) return base;
    let n = 1;
    while (fs.existsSync(path.join(PATHS.desk, `DESK_${t.ymd}-${t.hm}-${String(n).padStart(2, '0')}.md`))) n++;
    return `DESK_${t.ymd}-${t.hm}-${String(n).padStart(2, '0')}.md`;
}

////////////////////////////////////////////////////////////////////////////////
//
// MARK: Parsers
//
////////////////////////////////////////////////////////////////////////////////

function parseEpics() {
    const src = readIfExists(PATHS.epicsIndex);
    if (!src) return [];
    const rows = [];
    for (const line of src.split('\n')) {
        if (!line.startsWith('|')) continue;
        const cells = line.split('|').slice(1, -1).map(c => c.trim());
        if (cells.length < 4) continue;
        const rank = parseInt(cells[0]);
        if (isNaN(rank)) continue; // header and separator rows
        if (cells.length >= 5) {
            rows.push({ rank, name: cells[1], type: cells[2] || 'Objective', statement: cells[3], folder: cells[4] });
        } else {
            rows.push({ rank, name: cells[1], type: 'Objective', statement: cells[2], folder: cells[3] });
        }
    }
    return rows;
}

function findPlanFiles(epicFolder) {
    const base = path.join(PATHS.epics, epicFolder);
    if (!fs.existsSync(base)) return [];
    const plans = [];
    for (const f of fs.readdirSync(base)) {
        if (f.endsWith('.md') && f !== 'EPICS.md' && !f.startsWith('.')) {
            plans.push(path.join(base, f));
        }
    }
    // Also check planning subfolders for drafts
    const planDir = path.join(base, 'planning');
    if (fs.existsSync(planDir)) {
        for (const sub of fs.readdirSync(planDir)) {
            const subPath = path.join(planDir, sub);
            if (fs.statSync(subPath).isDirectory()) {
                for (const f of fs.readdirSync(subPath)) {
                    if (f.endsWith('.md')) plans.push(path.join(subPath, f));
                }
            }
        }
    }
    return plans;
}

function parsePlanFile(filePath) {
    const src = readIfExists(filePath);
    if (!src) return null;
    const plan = { path: filePath, title: '', epic: '', tasks: [] };
    const lines = src.split('\n');
    for (const line of lines) {
        if (line.startsWith('# ') && !plan.title) plan.title = line.slice(2).trim();
        const em = line.match(/^epic:\s*(.+)/);
        if (em) plan.epic = em[1].trim();
    }
    // Parse task breakdown table
    let inTable = false;
    for (const line of lines) {
        if (line.includes('Task Gist') && line.includes('|')) { inTable = true; continue; }
        if (inTable && line.match(/^\|[-\s|]+\|$/)) continue; // separator
        if (inTable && line.startsWith('|')) {
            const cells = line.split('|').map(c => c.trim()).filter(Boolean);
            if (cells.length >= 4) {
                plan.tasks.push({
                    num: cells[0],
                    gist: cells[1],
                    agent: cells[2],
                    review: cells.length > 3 ? cells[3] : '',
                    pri: cells.length > 4 ? cells[4] : '',
                    id: cells.length > 5 ? cells[5] : '',
                });
            }
        } else if (inTable && !line.startsWith('|')) {
            inTable = false;
        }
    }
    return plan;
}

function findAllEvents() {
    const events = [];
    // Engine's own events
    const eng = readIfExists(PATHS.engineEvents);
    if (eng) events.push(...parseEvents(eng));
    // Scan epic planning workspaces for session events
    if (fs.existsSync(PATHS.epics)) {
        const walk = (dir) => {
            for (const f of fs.readdirSync(dir)) {
                const fp = path.join(dir, f);
                if (fs.statSync(fp).isDirectory()) walk(fp);
                else if (f === 'events.md') events.push(...parseEvents(fs.readFileSync(fp, 'utf8')));
            }
        };
        walk(PATHS.epics);
    }
    return events;
}

function parseEvents(src) {
    const events = [];
    for (const line of src.split('\n')) {
        const m = line.match(/^\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.+?)\s*\|\s*(.*?)\s*\|/);
        if (m && m[1] !== 'Time' && !m[1].startsWith('-')) {
            events.push({ time: m[1].trim(), ref: m[2].trim(), event: m[3].trim(), note: m[4].trim() });
        }
    }
    return events;
}

function parseDeskIds(src) {
    // Returns a map of id -> checked (boolean)
    const map = {};
    for (const line of src.split('\n')) {
        const idMatch = line.match(/\[#([a-z]{2})\]/);
        if (idMatch) {
            const checked = /\[x\]/i.test(line);
            map[idMatch[1]] = checked;
        }
    }
    return map;
}

////////////////////////////////////////////////////////////////////////////////
//
// MARK: Generators
//
////////////////////////////////////////////////////////////////////////////////

function generateDesk(epics, allPlans, allEvents, t, supersedes) {
    const doneIds = new Set(allEvents.filter(e => e.event === 'done').map(e => e.ref.replace('#', '')));
    const lines = [];

    lines.push('---');
    lines.push(`name: DESK_${t.ymd}-${t.hm}.md`);
    if (supersedes) lines.push(`supersedes: ${path.basename(supersedes)}`);
    lines.push(`snapshot: .snapshots/DESK_${t.ymd}-${t.hm}.snap.md`);
    lines.push('---');
    lines.push('');
    lines.push(`# DESK — ${t.day}.${t.ymd}, ${t.hm.slice(0,2)}:${t.hm.slice(2)}`);
    lines.push('');

    // Operations Today
    lines.push('## Operations Today');
    lines.push('');
    for (const epic of epics) {
        const plans = allPlans[epic.folder] || [];
        const opPlans = plans.filter(p => p.title && p.title.toLowerCase().includes('operation'));
        if (opPlans.length > 0) {
            for (const plan of opPlans) {
                lines.push(`1. [ ] ${epic.name} 🔄 [#${randomId()}]`);
                for (const task of plan.tasks) {
                    lines.push(`    1. [ ] ${task.gist} [#${randomId()}]`);
                }
            }
        }
    }
    if (lines[lines.length - 1] === '') lines.pop(); // remove trailing blank
    lines.push('');

    // Epics Today
    lines.push(`## Epics Today [${t.day}.${t.ymd}]`);
    lines.push('');
    let epicNum = 1;
    for (const epic of epics) {
        const plans = allPlans[epic.folder] || [];
        const objPlans = plans.filter(p => !p.title || !p.title.toLowerCase().includes('operation'));
        const marker = objPlans.length > 0 ? ' ✓' : ' 🟧';
        lines.push(`${epicNum}. [ ] ${epic.name}${marker} [#${randomId()}]`);
        for (const plan of objPlans) {
            for (const task of plan.tasks) {
                const done = doneIds.has(task.id ? task.id.replace('#', '') : '');
                const check = done ? 'x' : ' ';
                const idStr = task.id ? ` [${task.id}]` : ` [#${randomId()}]`;
                lines.push(`    1. [${check}] ${task.gist}${idStr}`);
            }
        }
        epicNum++;
    }
    lines.push('');

    // Waiting
    lines.push('## Waiting');
    lines.push('');
    lines.push('');

    // One-offs & Inbox Today
    lines.push(`## One-offs & Inbox Today [${t.day}.${t.ymd}]`);
    lines.push('');
    lines.push('');

    // Done Today
    lines.push(`## Done Today [${t.day}.${t.ymd}]`);
    lines.push('');
    lines.push('');

    // Meetings
    lines.push('## Meetings');
    lines.push('');
    lines.push(`[${t.day}.${t.ymd}]:`);
    lines.push('');

    return lines.join('\n');
}

const usedIds = new Set();
function randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    let id;
    do {
        id = chars[Math.floor(Math.random() * 26)] + chars[Math.floor(Math.random() * 26)];
    } while (usedIds.has(id));
    usedIds.add(id);
    return id;
}

function generateBoard(epics, allPlans, allEvents, t) {
    const doneEvents = allEvents.filter(e => e.event === 'done');
    const doneIds = new Set(doneEvents.map(e => e.ref.replace('#', '')));
    const reviewEvents = allEvents.filter(e => e.event === 'review-ready');
    const stageEvents = allEvents.filter(e => e.event === 'stage');

    const lines = [];
    lines.push('# TASKBOARD');
    lines.push('');
    lines.push(`**${t.day}.${t.ymd} · ${t.hm.slice(0,2)}:${t.hm.slice(2)}:00**`);
    lines.push('');

    // For Your Review — items with review-ready events not yet done
    const reviewItems = reviewEvents.filter(e => !doneIds.has(e.ref.replace('#', '')));
    if (reviewItems.length > 0) {
        lines.push('## For Your Review');
        lines.push('');
        lines.push('| # | Epic | Task | Working On | Link |');
        lines.push('|---|---|---|---|---|');
        let n = 1;
        for (const ev of reviewItems) {
            const link = ev.note && ev.note.includes('[') ? ev.note : 'session';
            lines.push(`| ${n} | — | — | ${ev.note || 'Ready for review'} | ${link} |`);
            n++;
        }
        lines.push('');
    }

    // Epics table
    lines.push('## Epics');
    lines.push('');
    lines.push('| # | Epic | Task | Working On | ▶ | Agent |');
    lines.push('|---|---|---|---|---|---|');
    let n = 1;
    for (const epic of epics) {
        const plans = allPlans[epic.folder] || [];
        // Find current task: first non-done task across all plans
        let currentTask = null;
        for (const plan of plans) {
            for (const task of plan.tasks) {
                const tid = task.id ? task.id.replace('#', '') : '';
                if (!doneIds.has(tid)) { currentTask = task; break; }
            }
            if (currentTask) break;
        }
        if (!currentTask && plans.length > 0) continue; // all done, skip

        const taskGist = currentTask ? currentTask.gist : '—';
        const agent = currentTask ? (currentTask.agent || 'tbd') : 'tbd';
        const status = (agent === 'me' || agent === 'you') ? '●' : '▶';
        const agentDisplay = agent === 'me' ? 'you' : agent;

        // Find latest stage event for context
        const latestStage = stageEvents.filter(e => {
            const tid = currentTask && currentTask.id ? currentTask.id.replace('#', '') : '';
            return e.ref.replace('#', '') === tid;
        }).pop();
        const workingOn = latestStage ? latestStage.note : (plans.length === 0 ? 'No plan yet' : 'Starting');

        lines.push(`| ${n} | ${epic.name} | ${taskGist} | ${workingOn} | ${status} | ${agentDisplay} |`);
        n++;
    }
    lines.push('');
    lines.push('▶ agent is working · ● your turn');
    lines.push('');

    // Waiting
    lines.push('## Waiting');
    lines.push('');
    lines.push('| # | Item | Since | Who |');
    lines.push('|---|---|---|---|');
    lines.push('');

    // Up Next — epics with no plans at all
    const upNext = epics.filter(e => {
        const plans = allPlans[e.folder] || [];
        return plans.length === 0;
    });
    if (upNext.length > 0) {
        lines.push('## Up Next');
        lines.push('');
        lines.push('| # | Epic | Planned | First Task | First Step | Agent |');
        lines.push('|---|---|---|---|---|---|');
        let un = 1;
        for (const epic of upNext) {
            lines.push(`| ${un} | ${epic.name} |  | — | — | tbd |`);
            un++;
        }
        lines.push('');
    }

    // Recent Self-Improvements
    lines.push('## Recent Self-Improvements');
    lines.push('');
    lines.push('*No self-improvements yet.*');
    lines.push('');

    // Recently Done
    const todayDone = doneEvents.filter(e => e.time.startsWith(t.ymd));
    if (todayDone.length > 0) {
        lines.push('## Recently Done');
        lines.push('');
        lines.push('| # | Epic | Close-Out | When |');
        lines.push('|---|---|---|---|');
        let dn = 1;
        for (const ev of todayDone) {
            const time = ev.time.split(' ').pop() || ev.time;
            lines.push(`| ${dn} | — | ${ev.note || ev.ref} | ${time} |`);
            dn++;
        }
        lines.push('');
    }

    return lines.join('\n');
}

////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: archive
//
////////////////////////////////////////////////////////////////////////////////

function archive() {
    const t = now();
    ensureDir(PATHS.deskArchive);

    const deskFiles = fs.readdirSync(PATHS.desk)
        .filter(f => DESK_NAME.test(f) && f.includes(t.ymd))
        .sort();

    if (deskFiles.length === 0) {
        console.log('No desk files to archive for today.');
        return;
    }

    const archivePath = path.join(PATHS.deskArchive, `DESK_${t.ymd}.md`);
    // Take the last file as canonical
    const lastFile = deskFiles[deskFiles.length - 1];
    fs.copyFileSync(path.join(PATHS.desk, lastFile), archivePath);
    console.log(`Archived ${deskFiles.length} desk file(s) for ${t.ymd} -> ${archivePath}`);
}

////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: doctor
//
////////////////////////////////////////////////////////////////////////////////

function doctor() {
    const { spawnSync } = require('child_process');
    const checks = [
        { tool: 'git', args: ['--version'], hint: 'brew install git  ·  winget install Git.Git' },
        { tool: 'just', args: ['--version'], hint: 'brew install just  ·  winget install Casey.Just' },
        { tool: 'copilot', args: ['--version'], hint: 'npm install -g @github/copilot', optional: true },
        { tool: 'code', args: ['--version'], hint: "VS Code command palette: Shell Command: Install 'code' command in PATH", optional: true },
    ];
    console.log('Deskflow prerequisites:');
    console.log(`  node       ok (${process.version})`);
    let missingRequired = false;
    let copilotMissing = false;
    for (const c of checks) {
        const r = spawnSync(`${c.tool} ${c.args.join(' ')}`, { shell: true, timeout: 8000, encoding: 'utf8' });
        const ok = r.status === 0;
        if (ok) {
            const ver = ((r.stdout || '').split('\n')[0] || '').trim();
            console.log(`  ${c.tool.padEnd(10)} ok (${ver})`);
        } else {
            console.log(`  ${c.tool.padEnd(10)} MISSING${c.optional ? ' (optional)' : ''}  ->  ${c.hint}`);
            if (!c.optional) missingRequired = true;
            if (c.tool === 'copilot') copilotMissing = true;
        }
    }
    if (missingRequired) {
        console.log('Install the missing required tools above, then rerun.');
        process.exitCode = 1;
    } else if (copilotMissing) {
        console.log('Ready. Without copilot, /deskflow runs in single-session mode; install it to enable background epic sessions.');
    } else {
        console.log('All tools present. Background epic sessions available.');
    }
}


////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: export
//
////////////////////////////////////////////////////////////////////////////////

function exportSystem() {
    const t = now();
    const destRoot = path.join('deskflow', 'export', `${t.ymd}-${t.hm}`, 'deskflow');

    // Work content never leaves: desks, epics, pulse, generated views, run artifacts, prior exports.
    const skipEntries = new Set(['TASKBOARD.md', 'engine-events.md']);
    const skipTrees = new Set(['desk', 'epics', 'export',
        'system/snapshots', 'system/improvements', 'system/board-history']);
    // Stripped folders ship empty so adopters get the correct scaffold.
    const emptyDirs = ['desk', 'desk/archive', 'epics', 'system/snapshots', 'system/improvements'];

    function walk(rel) {
        for (const entry of fs.readdirSync(path.join('deskflow', rel))) {
            const relPath = rel ? `${rel}/${entry}` : entry;
            if (skipEntries.has(entry) || skipTrees.has(relPath)) continue;
            const srcPath = path.join('deskflow', relPath);
            const destPath = path.join(destRoot, relPath);
            if (fs.statSync(srcPath).isDirectory()) {
                fs.mkdirSync(destPath, { recursive: true });
                walk(relPath);
            } else {
                fs.mkdirSync(path.dirname(destPath), { recursive: true });
                fs.copyFileSync(srcPath, destPath);
            }
        }
    }
    walk('');
    for (const d of emptyDirs) {
        const dir = path.join(destRoot, d);
        fs.mkdirSync(dir, { recursive: true });
        fs.writeFileSync(path.join(dir, '.gitkeep'), '');
    }
    console.log(`Exported clean system -> ${destRoot}`);
}

////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: fresh
//
////////////////////////////////////////////////////////////////////////////////

function fresh() {
    const t = now();
    ensureDir(PATHS.desk);
    ensureDir(PATHS.deskArchive);

    // Archive yesterday: find desk files from previous days
    const today = t.ymd;
    const deskFiles = fs.readdirSync(PATHS.desk).filter(f => DESK_NAME.test(f)).sort();
    const yesterdayFiles = deskFiles.filter(f => {
        const dateMatch = f.match(/DESK_(\d{6})/);
        return dateMatch && dateMatch[1] !== today;
    });

    // Group by date and archive
    const byDate = {};
    for (const f of yesterdayFiles) {
        const dateMatch = f.match(/DESK_(\d{6})/);
        if (dateMatch) {
            if (!byDate[dateMatch[1]]) byDate[dateMatch[1]] = [];
            byDate[dateMatch[1]].push(f);
        }
    }
    for (const [date, files] of Object.entries(byDate)) {
        // Daily board record: the board as it stood entering this fresh depicts the
        // archived day's closing state. Written once per day, never overwritten, tracked in git.
        const boardRecord = path.join(PATHS.boardHistory, `TASKBOARD_${date}.md`);
        const currentBoard = readIfExists(PATHS.board);
        if (currentBoard !== null && !fs.existsSync(boardRecord)) {
            ensureDir(PATHS.boardHistory);
            fs.writeFileSync(boardRecord, currentBoard);
            console.log(`Board record ${date} -> ${boardRecord}`);
        }
        const archivePath = path.join(PATHS.deskArchive, `DESK_${date}.md`);
        // Always rewrite the archive from the true last stamp of that day,
        // so stamps made after a mid-day desk-archive are never lost.
        const lastFile = files[files.length - 1];
        const src = fs.readFileSync(path.join(PATHS.desk, lastFile), 'utf8');
        fs.writeFileSync(archivePath, src);
        console.log(`Archived ${date} -> ${archivePath}`);
        // Remove the archived day's files from desk/ only after the archive is written
        for (const f of files) {
            fs.unlinkSync(path.join(PATHS.desk, f));
        }
    }

    // Load system state
    const epics = parseEpics();
    const allPlans = {};
    for (const epic of epics) {
        allPlans[epic.folder] = findPlanFiles(epic.folder).map(parsePlanFile).filter(Boolean);
    }
    const allEvents = findAllEvents();

    // Find latest desk to supersede
    const latestDesk = latestFile(PATHS.desk, 'DESK_');

    // Carry forward one-offs from latest desk
    // (v0: we rely on the user seeing them in the previous desk; full carry-forward is a future verb)

    // Stamp new desk
    const deskName = deskStampName(t);
    const deskContent = generateDesk(epics, allPlans, allEvents, t, latestDesk);
    const deskPath = path.join(PATHS.desk, deskName);
    fs.writeFileSync(deskPath, deskContent);

    // Also render the board
    const boardContent = generateBoard(epics, allPlans, allEvents, t);
    fs.writeFileSync(PATHS.board, boardContent);

    console.log(`Today's desk -> ${deskPath}`);
}


////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: open
//
////////////////////////////////////////////////////////////////////////////////

function openDesk() {
    const p = latestFile(PATHS.desk, 'DESK_');
    if (!p) {
        console.log('No DESK file yet. Run `just desk-fresh` first.');
        process.exitCode = 1;
        return;
    }
    const { spawn } = require('child_process');
    const child = spawn(`code "${p}"`, { stdio: 'ignore', detached: true, shell: true });
    child.on('error', () => console.log(`Could not launch VS Code. Open manually: ${p}`));
    child.unref();
    console.log(`Opened ${p}`);
}


////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: render
//
////////////////////////////////////////////////////////////////////////////////

function render() {
    const t = now();
    const epics = parseEpics();
    const allPlans = {};
    for (const epic of epics) {
        allPlans[epic.folder] = findPlanFiles(epic.folder).map(parsePlanFile).filter(Boolean);
    }
    const allEvents = findAllEvents();

    const boardContent = generateBoard(epics, allPlans, allEvents, t);
    const prevBoard = readIfExists(PATHS.board);

    fs.writeFileSync(PATHS.board, boardContent);

    // Snapshot if content changed
    if (prevBoard !== null && prevBoard !== boardContent) {
        saveSnapshot(boardContent, t);
    }
}

function saveSnapshot(content, t) {
    ensureDir(PATHS.snapshots);
    const name = `TASKBOARD_${t.ymd}-${t.hms}.md`;
    fs.writeFileSync(path.join(PATHS.snapshots, name), content);
}


////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: snapshot-cleanup
//
////////////////////////////////////////////////////////////////////////////////

function snapshotCleanup() {
    ensureDir(PATHS.snapshots);
    const files = fs.readdirSync(PATHS.snapshots)
        .filter(f => f.startsWith('TASKBOARD_') && f.endsWith('.md'))
        .sort();

    const t = now();
    const cutoff = new Date(t.date);
    cutoff.setDate(cutoff.getDate() - 7);

    // Group files older than 7 days by date
    const oldByDate = {};
    const keep = [];

    for (const f of files) {
        const dateMatch = f.match(/TASKBOARD_(\d{6})/);
        if (!dateMatch) { keep.push(f); continue; }

        const fileDate = parseYmd(dateMatch[1]);
        if (fileDate >= cutoff) {
            keep.push(f); // Within 7 days: keep all
        } else {
            if (!oldByDate[dateMatch[1]]) oldByDate[dateMatch[1]] = [];
            oldByDate[dateMatch[1]].push(f);
        }
    }

    // For each old date, keep only the last snapshot
    let removed = 0;
    for (const [date, dateFiles] of Object.entries(oldByDate)) {
        dateFiles.sort();
        const keepFile = dateFiles[dateFiles.length - 1]; // last of day
        keep.push(keepFile);
        for (const f of dateFiles) {
            if (f !== keepFile) {
                fs.unlinkSync(path.join(PATHS.snapshots, f));
                removed++;
            }
        }
    }

    console.log(`Snapshot cleanup: ${removed} removed, ${keep.length} remaining.`);
}

function parseYmd(ymd) {
    const yy = parseInt(ymd.slice(0, 2)) + 2000;
    const mm = parseInt(ymd.slice(2, 4)) - 1;
    const dd = parseInt(ymd.slice(4, 6));
    return new Date(yy, mm, dd);
}


////////////////////////////////////////////////////////////////////////////////
//
// MARK: Verb: watch
//
////////////////////////////////////////////////////////////////////////////////

function watch() {
    console.log('deskflow-engine watch started. Ctrl+C to stop.');

    const epics = parseEpics();
    let debounceTimer = null;
    let lastDeskIds = {};

    // Initialize: snapshot the current desk state
    const currentDesk = latestFile(PATHS.desk, 'DESK_');
    if (currentDesk) {
        const src = fs.readFileSync(currentDesk, 'utf8');
        lastDeskIds = parseDeskIds(src);
    }

    function onChangeDetected() {
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => processChange(), 2000);
    }

    function processChange() {
        const t = now();
        const deskPath = latestFile(PATHS.desk, 'DESK_');
        if (!deskPath) return;

        const src = fs.readFileSync(deskPath, 'utf8');
        const currentIds = parseDeskIds(src);

        // Detect checkbox flips: unchecked -> checked = done event
        for (const [id, checked] of Object.entries(currentIds)) {
            if (checked && lastDeskIds[id] === false) {
                // Checkbox was flipped to done
                appendEvent(t, `#${id}`, 'done', `Checked off in desk`);
                console.log(`${t.hm.slice(0,2)}:${t.hm.slice(2)}  → Done: [#${id}]`);
            }
        }
        lastDeskIds = currentIds;

        // Re-render the board
        render();
    }

    // Watch desk/ and epics/ for changes
    const watchDirs = [PATHS.desk];
    if (fs.existsSync(PATHS.epics)) watchDirs.push(PATHS.epics);

    for (const dir of watchDirs) {
        try {
            fs.watch(dir, { recursive: true }, (eventType, filename) => {
                if (filename && (filename.endsWith('.md'))) {
                    onChangeDetected();
                }
            });
        } catch (e) {
            console.log(`Warning: could not watch ${dir}: ${e.message}`);
        }
    }

    // Also watch for new event files
    const sysDir = path.dirname(PATHS.engineEvents);
    if (fs.existsSync(sysDir)) {
        try {
            fs.watch(sysDir, { recursive: true }, (eventType, filename) => {
                if (filename && filename.endsWith('.md')) onChangeDetected();
            });
        } catch (e) { /* non-critical */ }
    }
}

function appendEvent(t, ref, event, note) {
    ensureDir(path.dirname(PATHS.engineEvents));
    const header = '| Time | Ref | Event | Note |\n|---|---|---|---|\n';
    const line = `| ${t.ymd} ${t.hm.slice(0,2)}:${t.hm.slice(2)}:00 | ${ref} | ${event} | ${note} |\n`;

    if (!fs.existsSync(PATHS.engineEvents)) {
        fs.writeFileSync(PATHS.engineEvents, `# Events — deskflow-engine\n\n${header}${line}`);
    } else {
        fs.appendFileSync(PATHS.engineEvents, line);
    }
}


////////////////////////////////////////////////////////////////////////////////
//
// MARK: Dispatch
//
////////////////////////////////////////////////////////////////////////////////

const verbs = {
  archive,
  doctor,
  export: exportSystem,
  fresh,
  open: openDesk,
  render,
  'snapshot-cleanup': snapshotCleanup,
  watch,
};

function main() {
    const verb = process.argv[2];
    if (!verb || !verbs[verb]) {
        console.log('deskflow-engine — verbs: ' + Object.keys(verbs).join(', '));
        console.log('Invoke through `just desk-*` commands, not directly.');
        process.exitCode = verb ? 1 : 0;
        return;
    }
    verbs[verb]();
}

main();
