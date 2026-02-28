# ntfy-push

A simple Nix flake that wraps [ntfy.sh](https://ntfy.sh/) for sending push notifications from the command line.

## Installation

### Using nix flake run (temporary)

```bash
nix run github:virusdave/ntfy-sh-client -- --help
```

### Using nix profile (permanent)

```bash
nix profile install github:virusdave/ntfy-sh-client
```

### Using direnv

Add to your `.envrc`:

```bash
use flake
```

Then run `direnv allow`.

## Usage

Set the `NTFY_SH_TOPIC` environment variable to specify the notification topic, then run `ntfy-push` with your message:

### Basic message (as argument)

```bash
NTFY_SH_TOPIC=alerts ntfy-push "System down!"
```

### Message from stdin

```bash
echo "Backup complete" | NTFY_SH_TOPIC=backup ntfy-push
```

### With title and priority

```bash
NTFY_SH_TOPIC=backup ntfy-push -t "Backup Complete" -p high "Full backup finished"
```

### With badge/emoji

```bash
NTFY_SH_TOPIC=alerts ntfy-push -b ⚠️ -p high "Warning message"
```

### With attachment URL

```bash
NTFY_SH_TOPIC=screenshots ntfy-push -a "https://example.com/image.jpg" "Screenshot attached"
```

### Multiple attachments

```bash
NTFY_SH_TOPIC=files ntfy-push -a "https://example.com/file1.jpg" -a "https://example.com/file2.jpg" "Multiple files"
```

## Options

```
Usage: ntfy-push [OPTIONS] [MESSAGE...]

ENVIRONMENT VARIABLES:
  NTFY_SH_TOPIC    Required. The topic to publish to.
  NTFY_URL         Optional. Base URL (default: https://ntfy.sh)

OPTIONS:
  -t, --title TEXT       Notification title
  -p, --priority LEVEL   Priority: min, low, default, high, max (or 1-5)
  -b, --badge EMOJI      Badge/emoji for notification
  -a, --attach URL       Attachment URL (can be used multiple times)
  -h, --help             Show this help message
```

## Environment Variables

- **`NTFY_SH_TOPIC`** (required): The topic to send notifications to. Topics are public, so choose something that cannot be easily guessed.
- **`NTFY_URL`** (optional): Override the ntfy.sh server URL. Defaults to `https://ntfy.sh`.

## Priority Levels

Priorities can be specified by name or number:

- `min` or `1`: Minimum priority
- `low` or `2`: Low priority
- `default` or `3`: Default priority (if not specified)
- `high` or `4`: High priority
- `max`, `urgent`, or `5`: Maximum/urgent priority

## Examples

### Cronjob notification

```bash
#!/bin/bash
BACKUP_LOG=$(mktemp)
if /path/to/backup.sh > "$BACKUP_LOG" 2>&1; then
  NTFY_SH_TOPIC=backups ntfy-push -t "Backup Success" -p high "Daily backup completed"
else
  NTFY_SH_TOPIC=backups ntfy-push -t "Backup Failed" -p max -b ❌ "$(cat $BACKUP_LOG)"
fi
rm -f "$BACKUP_LOG"
```

### Script completion notification

```bash
#!/bin/bash
long_running_task && \
  NTFY_SH_TOPIC=tasks ntfy-push -t "Task Complete" "Your long task is done!" || \
  NTFY_SH_TOPIC=tasks ntfy-push -t "Task Failed" -p high -b ❌ "Your task failed"
```

### Pipeline error notification

```bash
#!/bin/bash
TOPIC=my-alerts
if ./build.sh 2>&1 | tee build.log; then
  NTFY_SH_TOPIC=$TOPIC ntfy-push -t "Build Success" -p high "Build completed successfully"
else
  NTFY_SH_TOPIC=$TOPIC ntfy-push -t "Build Failed" -p max -b 🔨 "Build failed, check logs"
fi
```

## Development

### Enter development shell

```bash
nix flake enter
```

### Test the script locally

```bash
./ntfy-push.sh --help
```

### Build the package

```bash
nix build
```

## License

This flake is provided as-is. The ntfy.sh service is provided by [Philipp C. Heckel](https://github.com/binwiederhier/ntfy).
