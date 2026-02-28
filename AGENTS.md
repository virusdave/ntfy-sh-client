# Agentic Instructions

## Git Operations

Always prefix mutating git commands with `umask 0002`, and ensure any created files or directories are group-writeable.

Example:
```bash
umask 0002 && git add . && git commit -m "message"
```
