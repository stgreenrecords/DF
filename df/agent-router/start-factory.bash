#!/usr/bin/env bash
# Dark Factory - autonomous role-session router.
#
# The human starts the factory once. This router then drives the SDLC loop:
# on each iteration it reads df/runtime/board.md, selects the highest-priority
# actionable task, resolves the responsible role, and launches exactly ONE
# fresh role-session through the selected adapter. After the session returns,
# the router re-reads the board and automatically launches the next role-session
# until the work reaches DONE / NO_TASKS / BLOCKED or a safety limit is hit.
#
# "One role per session" is preserved: each iteration is an isolated single-role
# session. The novelty is that the router chains those sessions automatically so
# the human does not have to re-trigger each role by hand.
#
# Adapters:
#   manual  - prints the next role-session prompt and stops after one role
#             (conservative; a human copies the prompt into a new session).
#   auto    - executes $DF_AGENT_CMD for every role-session and loops
#             automatically until the factory reaches a stop condition.
#
# Compatible with bash 3.2 (macOS default).

set -euo pipefail

DF_ROUTER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DF_ROOT="$(cd -- "$DF_ROUTER_DIR/../.." && pwd)"
DF_RUNTIME="$DF_ROOT/df/runtime"
DF_BOARD="$DF_RUNTIME/board.md"
DF_ACTIVITY="$DF_RUNTIME/activity-log.md"

# shellcheck source=state-role-map.bash
. "$DF_ROUTER_DIR/state-role-map.bash"
# shellcheck source=board-parser.bash
. "$DF_ROUTER_DIR/board-parser.bash"

# ---- defaults ---------------------------------------------------------------
ADAPTER="manual"
MAX_ITERATIONS=20
FILTER_TASK_ID=""
FORCE_ROLE=""
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: start-factory.bash [options]

Options:
  --adapter <manual|auto>   Session driver. Default: manual.
  --max-iterations <n>      Safety cap on chained role-sessions. Default: 20.
  --task-id <id>            Restrict the loop to a single task id.
  --role <short-name>       Force the first role-session (sa, qa, po, ...).
  --dry-run                 Plan and print actions without launching sessions.
  -h, --help                Show this help.

Environment:
  DF_AGENT_CMD              Required for the "auto" adapter. Command that runs
                            one role-session. It receives the role prompt on
                            stdin and these arguments:
                              $1 = role short-name
                              $2 = task id
                              $3 = task state
                              $4 = prompt file path
                            The command MUST update df/runtime/board.md to
                            reflect the new state when the role finishes.
EOF
}

log() { printf '[df-router] %s\n' "$*" >&2; }
die() { printf '[df-router][error] %s\n' "$*" >&2; exit 1; }

# ---- argument parsing -------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --adapter) ADAPTER="${2:-}"; shift 2 ;;
    --max-iterations) MAX_ITERATIONS="${2:-}"; shift 2 ;;
    --task-id) FILTER_TASK_ID="${2:-}"; shift 2 ;;
    --role) FORCE_ROLE="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

case "$ADAPTER" in
  manual|auto) : ;;
  *) die "unsupported adapter: $ADAPTER (use manual or auto)" ;;
esac

case "$MAX_ITERATIONS" in
  ''|*[!0-9]*) die "--max-iterations must be a positive integer" ;;
esac
[ "$MAX_ITERATIONS" -ge 1 ] || die "--max-iterations must be >= 1"

[ -f "$DF_BOARD" ] || die "board not found: $DF_BOARD (create it from df/templates/board.md)"

if [ "$ADAPTER" = "auto" ] && [ "$DRY_RUN" -eq 0 ]; then
  [ -n "${DF_AGENT_CMD:-}" ] || die "auto adapter requires DF_AGENT_CMD to be set"
fi

# ---- task selection ---------------------------------------------------------
# Sets globals: SEL_TASK_ID, SEL_STATE, SEL_OWNER, SEL_ROLE.
# Returns 0 when an actionable task was selected, 1 otherwise.
SEL_TASK_ID=""; SEL_STATE=""; SEL_OWNER=""; SEL_ROLE=""
select_next() {
  SEL_TASK_ID=""; SEL_STATE=""; SEL_OWNER=""; SEL_ROLE=""
  local best_rank=9999
  local prio task state owner rank
  local rows
  rows="$(df_parse_board "$DF_BOARD")"
  [ -n "$rows" ] || return 1

  while IFS=$'\t' read -r prio task state owner; do
    [ -n "$task" ] || continue
    if [ -n "$FILTER_TASK_ID" ] && [ "$task" != "$FILTER_TASK_ID" ]; then
      continue
    fi
    df_state_is_actionable "$state" || continue
    rank="$(df_state_rank "$state")"
    if [ "$rank" -lt "$best_rank" ]; then
      best_rank="$rank"
      SEL_TASK_ID="$task"
      SEL_STATE="$state"
      SEL_OWNER="$owner"
    fi
  done <<EOF
$rows
EOF

  [ -n "$SEL_TASK_ID" ] || return 1

  SEL_ROLE="$(df_role_for_state "$SEL_STATE")"
  if [ "$SEL_ROLE" = "delivery" ]; then
    # Resolve the concrete delivery lane from the board owner column.
    case "$SEL_OWNER" in
      backend-dev|frontend-dev|devops|data-engineer) SEL_ROLE="$SEL_OWNER" ;;
      *) SEL_ROLE="delivery (lane unspecified - see board owner)" ;;
    esac
  fi
  return 0
}

# ---- prompt building --------------------------------------------------------
build_prompt() {
  local role="$1" task="$2" state="$3" file="$4"
  {
    echo "# Dark Factory role-session"
    echo
    echo "You are running as a single role for ONE task, then you must stop."
    echo
    echo "- Role: $role"
    echo "- Task: $task"
    echo "- Current state: $state"
    echo
    echo "## Required reading"
    echo
    echo "1. df/00-start-here.md"
    echo "2. df/01-operating-model.md"
    echo "3. df/02-state-machine.md"
    echo "4. df/03-orchestration-rules.md"
    echo "5. df/04-documentation-standards.md"
    echo "6. df/roles/${role}.md (if it exists for this lane)"
    echo "7. df/runtime/ current files"
    echo
    echo "## Mandatory outcomes"
    echo
    echo "- Execute only the $role checklist for task $task."
    echo "- Update df/runtime/board.md with the new task state."
    echo "- Append an entry to df/runtime/activity-log.md."
    echo "- Write a handoff note naming the next role and next action."
    echo "- Do not switch roles or self-approve within this session."
  } > "$file"
}

# ---- adapters ---------------------------------------------------------------
run_manual_session() {
  local role="$1" task="$2" state="$3" file="$4"
  log "manual adapter: prepared role-session prompt for role='$role' task='$task' state='$state'"
  echo "----------------------------------------------------------------------"
  cat "$file"
  echo "----------------------------------------------------------------------"
  log "manual adapter is conservative: copy the prompt above into a NEW session."
}

run_auto_session() {
  local role="$1" task="$2" state="$3" file="$4"
  log "auto adapter: launching role-session role='$role' task='$task' state='$state'"
  # The agent command reads the prompt from stdin and receives context args.
  # It is expected to update the board before returning.
  /usr/bin/env bash -c "$DF_AGENT_CMD \"\$@\"" _ "$role" "$task" "$state" "$file" < "$file"
}

# ---- main loop --------------------------------------------------------------
log "starting factory: adapter=$ADAPTER max-iterations=$MAX_ITERATIONS dry-run=$DRY_RUN"
[ -n "$FILTER_TASK_ID" ] && log "restricted to task: $FILTER_TASK_ID"

iteration=0
prev_signature=""

while [ "$iteration" -lt "$MAX_ITERATIONS" ]; do
  if ! select_next; then
    log "no actionable tasks remain (NO_TASKS / DONE / BLOCKED). Stopping."
    exit 0
  fi

  role="$SEL_ROLE"
  if [ "$iteration" -eq 0 ] && [ -n "$FORCE_ROLE" ]; then
    log "forcing first role-session to '$FORCE_ROLE' (board suggested '$SEL_ROLE')"
    role="$FORCE_ROLE"
  fi

  iteration=$((iteration + 1))
  log "iteration $iteration/$MAX_ITERATIONS -> role='$role' task='$SEL_TASK_ID' state='$SEL_STATE'"

  prompt_file="$(mktemp -t df-prompt.XXXXXX)"
  build_prompt "$role" "$SEL_TASK_ID" "$SEL_STATE" "$prompt_file"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "dry-run: would launch role-session for '$role' on task '$SEL_TASK_ID'"
    cat "$prompt_file"
    rm -f "$prompt_file"
    # In dry-run we cannot make progress; show only the next planned step.
    exit 0
  fi

  if [ "$ADAPTER" = "manual" ]; then
    run_manual_session "$role" "$SEL_TASK_ID" "$SEL_STATE" "$prompt_file"
    rm -f "$prompt_file"
    log "manual adapter runs one role per invocation. Stopping after one session."
    exit 0
  fi

  # auto adapter
  run_auto_session "$role" "$SEL_TASK_ID" "$SEL_STATE" "$prompt_file"
  rm -f "$prompt_file"

  # Progress / stall detection: if the board signature is unchanged after a
  # session, the role made no state change. Stop to avoid an infinite loop.
  signature="$(df_parse_board "$DF_BOARD")"
  if [ "$signature" = "$prev_signature" ]; then
    log "no board change after role-session for task '$SEL_TASK_ID'. Stopping to avoid a loop."
    die "stalled: role '$role' did not advance task '$SEL_TASK_ID' (state still '$SEL_STATE')"
  fi
  prev_signature="$signature"
done

log "reached max-iterations ($MAX_ITERATIONS). Stopping. Re-run to continue."
