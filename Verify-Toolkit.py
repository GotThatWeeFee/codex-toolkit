"""Verify a toolkit release. Requires Python 3.11+; no third-party packages."""
from pathlib import Path
import hashlib
import json
import re
import sys
import tomllib

root = Path(__file__).resolve().parent
errors = []
files = [p for p in root.rglob('*') if p.is_file() and p.relative_to(root).parts[0] != '.git']
manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
actual = {p.relative_to(root).as_posix() for p in files if p.name != 'manifest.json'}
expected = set(manifest['files'])
for name in sorted(expected - actual):
    errors.append('Missing: ' + name)
for name in sorted(actual - expected):
    errors.append('Unexpected: ' + name)
for name in sorted(expected & actual):
    digest = hashlib.sha256((root / name).read_bytes()).hexdigest()
    if digest != manifest['files'][name]:
        errors.append('Hash mismatch: ' + name)

roles = set()
for p in (p for p in files if p.suffix == '.toml'):
    try:
        data = tomllib.loads(p.read_text(encoding='utf-8-sig'))
        if p.parent.name == 'agents':
            if data.get('name') in roles:
                errors.append('Duplicate agent name: ' + str(data.get('name')))
            roles.add(data.get('name'))
            for key in ('name', 'description', 'developer_instructions'):
                if not isinstance(data.get(key), str) or not data[key].strip():
                    errors.append(f'Missing agent field {key}: {p.name}')
            if 'sandbox_mode' in data:
                errors.append('Agent sets unsupported permission override: ' + p.name)
    except Exception as exc:
        errors.append(f'Invalid TOML {p.relative_to(root)}: {exc}')
needed = {'pipeline_' + s for s in ('planner','implementer','documentation','specialist_reviewer','senior_engineer','qa','final_reviewer','language_mentor')}
if roles != needed:
    errors.append('Pipeline role set is incomplete or unexpected')

for p in (p for p in files if p.name == 'SKILL.md'):
    text = p.read_text(encoding='utf-8-sig')
    frontmatter = re.match(r'\A---\s*\n(.*?)\n---', text, re.S)
    if not frontmatter:
        errors.append('Missing frontmatter: ' + str(p.relative_to(root)))
        continue
    for field in ('name','description'):
        if not re.search(r'^' + field + r':\s*\S', frontmatter[1], re.M):
            errors.append('Missing skill ' + field + ': ' + str(p.relative_to(root)))

for p in (p for p in files if p.suffix == '.md'):
    text = p.read_text(encoding='utf-8-sig')
    for link in re.findall(r'\]\(([^)]+)\)', text):
        target = link.split('#', 1)[0]
        if not target or re.match(r'[a-zA-Z]+:', target) or target.startswith('/'):
            continue
        if not (p.parent / target).exists():
            errors.append(f'Broken local link {target}: {p.relative_to(root)}')

patterns = {
    'personal Windows path': r'(?i)[A-Z]:[\\/]+Users[\\/]+(?!Public\b|Default\b)[^\s"\x27<>]+',
    'private key': r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'OpenAI-style secret': r'\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{24,}',
    'GitHub-style secret': r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,})',
}
for p in files:
    if p.is_file() and p.suffix.lower() in {'.md','.toml','.yaml','.json','.txt','.sh','.ps1'}:
        text = p.read_text(encoding='utf-8-sig')
        for label, pattern in patterns.items():
            if re.search(pattern, text):
                errors.append(label + ' detected in ' + str(p.relative_to(root)))

if errors:
    print('\n'.join('FAIL: ' + e for e in errors))
    sys.exit(1)
print(f'PASS: {len(expected)} file hashes, TOML syntax, 3 skill frontmatter checks, 8 roles, local links and heuristic secret/path scan.')
print('Not tested: Codex discovery, role execution, full pipeline behavior, optional browser workflow.')
