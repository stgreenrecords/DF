#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DF_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

role="${1:-}"
task_id="${2:-}"
state="${3:-}"
prompt_file="${4:-}"

if [ -z "$role" ] || [ -z "$task_id" ] || [ -z "$state" ] || [ -z "$prompt_file" ]; then
  printf '[df-agent-runner][error] expected arguments: <role> <task-id> <state> <prompt-file>\n' >&2
  exit 2
fi

resolve_runner() {
  if [ -n "${DF_AGENT_RUNNER:-}" ]; then
    printf '%s\n' "$DF_AGENT_RUNNER"
    return 0
  fi

  for candidate in copilot gh claude aider cursor code gemini llm openai; do
    if command -v "$candidate" >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

load_copilot_token() {
  local token_file token_value token_line

  case "${DF_AGENT_IGNORE_TOKEN:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
  esac

  if [ -n "${COPILOT_GITHUB_TOKEN:-}" ]; then
    return 0
  fi

  token_file="${DF_AGENT_TOKEN_FILE:-$DF_ROOT/token}"
  [ -f "$token_file" ] || return 0

  token_line="$(tr -d '\r' < "$token_file" | head -n 1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  case "$token_line" in
    export\ COPILOT_GITHUB_TOKEN=*) token_value="${token_line#export COPILOT_GITHUB_TOKEN=}" ;;
    COPILOT_GITHUB_TOKEN=*) token_value="${token_line#COPILOT_GITHUB_TOKEN=}" ;;
    export\ GH_TOKEN=*) token_value="${token_line#export GH_TOKEN=}" ;;
    GH_TOKEN=*) token_value="${token_line#GH_TOKEN=}" ;;
    export\ GITHUB_TOKEN=*) token_value="${token_line#export GITHUB_TOKEN=}" ;;
    GITHUB_TOKEN=*) token_value="${token_line#GITHUB_TOKEN=}" ;;
    *) token_value="$token_line" ;;
  esac
  token_value="${token_value#\"}"
  token_value="${token_value%\"}"
  token_value="${token_value#\'}"
  token_value="${token_value%\'}"
  [ -n "$token_value" ] || return 0

  export COPILOT_GITHUB_TOKEN="$token_value"
  export GH_TOKEN="$token_value"
  export GITHUB_TOKEN="$token_value"
}

copilot_prompt() {
  {
    printf 'Repository root: %s\n' "$DF_ROOT"
    printf 'Role: %s\n' "$role"
    printf 'Task: %s\n' "$task_id"
    printf 'State: %s\n\n' "$state"
    cat "$prompt_file"
  }
}

run_copilot() {
  local prompt_text token_source auth_mode out_file err_file status
  local heartbeat_seconds start_ts now_ts elapsed pid out_pipe err_pipe out_tee_pid err_tee_pid

  load_copilot_token
  token_source="${DF_AGENT_TOKEN_FILE:-$DF_ROOT/token}"
  auth_mode="stored-login"
  if [ -n "${COPILOT_GITHUB_TOKEN:-}" ]; then
    auth_mode="token-file"
  fi
  if [ "$auth_mode" = "token-file" ] && [ -z "${COPILOT_GITHUB_TOKEN:-}" ]; then
    printf '[df-agent-runner][error] copilot runner requires COPILOT_GITHUB_TOKEN or a token file at %s\n' "$token_source" >&2
    exit 5
  fi

  prompt_text="$(copilot_prompt)"
  out_file="$(mktemp -t df-copilot-out.XXXXXX)"
  err_file="$(mktemp -t df-copilot-err.XXXXXX)"
  out_pipe="$(mktemp -u -t df-copilot-out-pipe.XXXXXX)"
  err_pipe="$(mktemp -u -t df-copilot-err-pipe.XXXXXX)"
  mkfifo "$out_pipe" "$err_pipe"
  heartbeat_seconds="${DF_AGENT_HEARTBEAT_SECONDS:-15}"
  case "$heartbeat_seconds" in
    ''|*[!0-9]*) heartbeat_seconds=15 ;;
    *) [ "$heartbeat_seconds" -ge 1 ] || heartbeat_seconds=15 ;;
  esac

  set +e
  printf '[df-agent-runner] launching Copilot session model=%s mode=%s task=%s role=%s\n' \
    "${DF_AGENT_MODEL:-gpt-5.4}" "${DF_AGENT_MODE:-autopilot}" "$task_id" "$role" >&2
  printf '[df-agent-runner] waiting for completion; heartbeat every %ss\n' "$heartbeat_seconds" >&2
  printf '[df-agent-runner] streaming child session logs below\n' >&2
  start_ts="$(date +%s)"

  awk '{ print "[df-agent-runner][stdout] " $0; fflush(); }' < "$out_pipe" | tee "$out_file" &
  out_tee_pid=$!
  awk '{ print "[df-agent-runner][stderr] " $0 > "/dev/stderr"; fflush("/dev/stderr"); }' < "$err_pipe" | tee "$err_file" >/dev/null &
  err_tee_pid=$!

  copilot \
    -C "$DF_ROOT" \
    --model "${DF_AGENT_MODEL:-gpt-5.4}" \
    --mode "${DF_AGENT_MODE:-autopilot}" \
    --name "df:${task_id}:${role}" \
    --allow-all \
    --no-ask-user \
    --secret-env-vars=COPILOT_GITHUB_TOKEN,GH_TOKEN,GITHUB_TOKEN \
    -p "$prompt_text" \
    >"$out_pipe" 2>"$err_pipe" &
  pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    sleep "$heartbeat_seconds"
    if kill -0 "$pid" 2>/dev/null; then
      now_ts="$(date +%s)"
      elapsed=$((now_ts - start_ts))
      printf '[df-agent-runner] Copilot still running (%ss elapsed) for task=%s role=%s\n' \
        "$elapsed" "$task_id" "$role" >&2
    fi
  done
  wait "$pid"
  status=$?
  wait "$out_tee_pid"
  wait "$err_tee_pid"
  rm -f "$out_pipe" "$err_pipe"
  set -e

  if [ "$status" -eq 0 ]; then
    cat "$out_file"
    cat "$err_file" >&2
    rm -f "$out_file" "$err_file"
    return 0
  fi

  if grep -Eq 'Authentication failed|No authentication information found' "$err_file"; then
    cat "$err_file" >&2
    if [ "$auth_mode" = "token-file" ]; then
      cat >&2 <<EOF
[df-agent-runner][error] Copilot CLI loaded authentication input from the token file but GitHub rejected it.

Checked token source:
  $token_source

Next steps:
  1. run: copilot
  2. inside Copilot CLI, run: /login
  3. set DF_AGENT_IGNORE_TOKEN='true' in .df-factory.env to prefer stored login
  4. then retry: ./start factory

If you prefer token-file auth, replace ./token with a valid fine-grained PAT that
has the 'Copilot Requests' permission and is not expired.
EOF
    else
      cat >&2 <<'EOF'
[df-agent-runner][error] Copilot CLI stored login is not currently usable.

Next steps:
  1. run: copilot
  2. inside Copilot CLI, run: /login
  3. then retry: ./start factory

If you prefer file-based auth instead, set DF_AGENT_TOKEN_FILE in .df-factory.env
and provide a valid fine-grained PAT with the 'Copilot Requests' permission.
EOF
    fi
  else
    cat "$err_file" >&2
  fi

  rm -f "$out_file" "$err_file"
  exit "$status"
}

run_with_runner() {
  local runner="$1"
  shift

  case "$runner" in
    copilot)
      run_copilot
      ;;
    gh)
      printf '[df-agent-runner][error] found gh, but no supported non-interactive GitHub Copilot session command is configured. Set DF_AGENT_RUNNER in .df-factory.env.\n' >&2
      exit 3
      ;;
    claude|aider|cursor|code|gemini|llm|openai)
      exec "$runner" "$@"
      ;;
    *)
      /usr/bin/env bash -c "$runner \"\$@\"" _ "$@"
      ;;
  esac
}

if ! runner="$(resolve_runner)"; then
  cat >&2 <<'EOF'
[df-agent-runner][error] No supported agent launcher was found.

What to do:
1. install or expose your agent CLI in PATH, or
2. set DF_AGENT_RUNNER in .df-factory.env.

Example .df-factory.env:
  DF_AGENT_CMD='./df/agent-router/run-role-session.bash'
  DF_AGENT_RUNNER='copilot'
  DF_AGENT_MODEL='gpt-5.4'
  DF_AGENT_MODE='autopilot'
  DF_AGENT_IGNORE_TOKEN='true'
  DF_FACTORY_ADAPTER='auto'
  DF_FACTORY_MAX_ITERATIONS='300'
EOF
  exit 4
fi

printf '[df-agent-runner] runner=%s role=%s task=%s state=%s prompt=%s\n' "$runner" "$role" "$task_id" "$state" "$prompt_file" >&2
run_with_runner "$runner" "$role" "$task_id" "$state" "$prompt_file"

