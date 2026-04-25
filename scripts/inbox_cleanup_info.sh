#!/usr/bin/env bash
# inbox_cleanup_info.sh — severity=info の古いメッセージを自動 read=true 化
# 48h を超過した未読 info メッセージは token 節約のため自動既読にする。
# critical は対象外（重要メッセージは消えない）。
#
# Usage: bash scripts/inbox_cleanup_info.sh [agent_id]
#   agent_id 省略 → queue/inbox/ 配下の全 agent を処理
#
# 推奨: cron または inbox_watcher.sh のタイムアウトサイクルで定期実行
# Example (cron): 0 */6 * * * bash /path/to/scripts/inbox_cleanup_info.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INBOX_DIR="$SCRIPT_DIR/queue/inbox"
THRESHOLD_HOURS="${INBOX_CLEANUP_INFO_HOURS:-48}"

if [ ! -d "$INBOX_DIR" ]; then
    echo "[inbox_cleanup_info] ERROR: inbox dir not found: $INBOX_DIR" >&2
    exit 1
fi

process_inbox() {
    local inbox="$1"
    local lockfile="${inbox}.lock"

    (
        if command -v flock &>/dev/null; then
            flock -w 5 200 || { echo "[inbox_cleanup_info] Lock timeout: $inbox" >&2; return 1; }
        else
            local _ld="${lockfile}.d"
            local _i=0
            while ! mkdir "$_ld" 2>/dev/null; do
                sleep 0.1
                _i=$((_i+1))
                [ $_i -ge 50 ] && { echo "[inbox_cleanup_info] Lock timeout: $inbox" >&2; return 1; }
            done
            trap "rmdir '$_ld' 2>/dev/null" EXIT
        fi

        INBOX_PATH="$inbox" THRESHOLD_HOURS="$THRESHOLD_HOURS" \
        "$SCRIPT_DIR/.venv/bin/python3" - << 'PY'
import datetime
import os
import yaml

inbox = os.environ.get("INBOX_PATH", "")
threshold_hours = int(os.environ.get("THRESHOLD_HOURS", "48"))
now = datetime.datetime.now(datetime.timezone.utc)
cutoff = now - datetime.timedelta(hours=threshold_hours)

try:
    with open(inbox, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    messages = data.get("messages", []) or []
    cleaned = 0
    for m in messages:
        if m.get("read", False):
            continue
        if m.get("severity", "info") == "critical":
            continue
        ts_raw = m.get("timestamp", "")
        if not ts_raw:
            continue
        try:
            ts = datetime.datetime.fromisoformat(str(ts_raw))
            if ts.tzinfo is None:
                ts = ts.replace(tzinfo=datetime.timezone.utc)
            if ts < cutoff:
                m["read"] = True
                cleaned += 1
        except Exception:
            pass

    if cleaned == 0:
        print(f"SKIP:{os.path.basename(inbox)} (no expired info messages)")
        raise SystemExit(0)

    data["messages"] = messages
    tmp_path = f"{inbox}.tmp.{os.getpid()}"
    with open(tmp_path, "w", encoding="utf-8") as f:
        yaml.safe_dump(data, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
    os.replace(tmp_path, inbox)
    print(f"CLEANED:{os.path.basename(inbox)}:{cleaned}")
except SystemExit:
    raise
except Exception as e:
    print(f"ERROR:{inbox}:{e}", flush=True)
    raise SystemExit(1)
PY
    ) 200>"$lockfile"
}

# Determine target inbox files
if [ -n "${1:-}" ]; then
    targets=("$INBOX_DIR/${1}.yaml")
else
    mapfile -t targets < <(find "$INBOX_DIR" -name "*.yaml" ! -name "*.lock" 2>/dev/null | sort)
fi

for inbox in "${targets[@]}"; do
    [ -f "$inbox" ] || continue
    result=$(process_inbox "$inbox" 2>&1)
    echo "[$(date '+%Y-%m-%dT%H:%M:%S')] [inbox_cleanup_info] $result" >&2
done
