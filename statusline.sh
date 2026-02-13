#!/usr/bin/env python3
"""Claude Code status line: model, context window, tokens, and git info."""

import json, sys, subprocess, os

data = json.load(sys.stdin)

# ── Extract fields ──
model = data.get('model', {}).get('display_name', '?')
pct = int(data.get('context_window', {}).get('used_percentage', 0) or 0)
total_in = data.get('context_window', {}).get('total_input_tokens', 0) or 0
total_out = data.get('context_window', {}).get('total_output_tokens', 0) or 0

cur = data.get('context_window', {}).get('current_usage') or {}
cur_in = cur.get('input_tokens', 0) or 0
cur_out = cur.get('output_tokens', 0) or 0
cur_cache_create = cur.get('cache_creation_input_tokens', 0) or 0
cur_cache_read = cur.get('cache_read_input_tokens', 0) or 0

# ── Colors ──
CYAN, GREEN, YELLOW, RED, DIM, RESET = (
    '\033[36m', '\033[32m', '\033[33m', '\033[31m', '\033[2m', '\033[0m'
)

# ── Format tokens (15234 → 15.2k) ──
def fmt(n):
    if n >= 1_000_000: return f'{n/1_000_000:.1f}M'
    if n >= 1_000: return f'{n/1_000:.1f}k'
    return str(n)

# ── Context bar (color-coded) ──
bar_color = RED if pct >= 50 else YELLOW if pct >= 40 else GREEN
filled = pct * 10 // 100
bar = '█' * filled + '░' * (10 - filled)

# ── Git info (cached for performance) ──
CACHE_FILE = '/tmp/claude-statusline-git-cache'
CACHE_MAX_AGE = 5

def cache_is_stale():
    if not os.path.exists(CACHE_FILE):
        return True
    import time
    return time.time() - os.path.getmtime(CACHE_FILE) > CACHE_MAX_AGE

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ''

git_info = ''
if cache_is_stale():
    try:
        subprocess.check_output(['git', 'rev-parse', '--git-dir'], stderr=subprocess.DEVNULL)
        branch = run(['git', 'branch', '--show-current'])
        staged = len([l for l in run(['git', 'diff', '--cached', '--numstat']).split('\n') if l])
        modified = len([l for l in run(['git', 'diff', '--numstat']).split('\n') if l])
        untracked = len([l for l in run(['git', 'ls-files', '--others', '--exclude-standard']).split('\n') if l])
        with open(CACHE_FILE, 'w') as f:
            f.write(f'{branch}|{staged}|{modified}|{untracked}')
    except Exception:
        with open(CACHE_FILE, 'w') as f:
            f.write('|||')

try:
    with open(CACHE_FILE) as f:
        parts = f.read().strip().split('|')
    branch, staged, modified, untracked = parts[0], int(parts[1] or 0), int(parts[2] or 0), int(parts[3] or 0)
except Exception:
    branch, staged, modified, untracked = '', 0, 0, 0

if branch:
    status_parts = []
    if staged > 0: status_parts.append(f'{GREEN}+{staged}{RESET}')
    if modified > 0: status_parts.append(f'{YELLOW}~{modified}{RESET}')
    if untracked > 0: status_parts.append(f'{RED}?{untracked}{RESET}')
    git_status = ' '.join(status_parts)
    git_info = f'{DIM}|{RESET} {CYAN}{branch}{RESET} {git_status}'

# ── Line 1: Model + Git ──
print(f'{CYAN}[{model}]{RESET} {git_info}')

# ── Line 2: Context bar + token stats ──
cur_cache = cur_cache_create + cur_cache_read
print(f'{bar_color}{bar}{RESET} {pct}% {DIM}|{RESET} in:{fmt(total_in)} out:{fmt(total_out)} {DIM}|{RESET} cur: {fmt(cur_in)}+{fmt(cur_cache)}cache {DIM}→{RESET} {fmt(cur_out)}')
