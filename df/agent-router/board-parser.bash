#!/usr/bin/env bash
# Dark Factory - board.md parser.
# Reads df/runtime/board.md and emits one TSV line per real task:
#   priority<TAB>task_id<TAB>state<TAB>owner_role
# The placeholder NO_TASKS row and header/separator rows are skipped.
# Compatible with bash 3.2.

# df_trim STRING -> echoes the string with leading/trailing whitespace removed.
df_trim() {
  local s="$1"
  # strip leading whitespace
  s="${s#"${s%%[![:space:]]*}"}"
  # strip trailing whitespace
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

# df_parse_board BOARD_FILE -> prints TSV rows for real tasks.
df_parse_board() {
  local board="$1"
  [ -f "$board" ] || return 0

  local line col1 col2 col3 col5 col6
  while IFS= read -r line || [ -n "$line" ]; do
    # Must look like a markdown table data row.
    case "$line" in
      \|*\|*) : ;;
      *) continue ;;
    esac
    # Skip the markdown separator row (|---|---|...).
    case "$line" in
      *---*) continue ;;
    esac

    # Split on '|'. Leading '|' produces an empty first field, so the
    # real columns start at index 2.
    local IFS='|'
    # shellcheck disable=SC2206
    local fields=($line)
    unset IFS

    col1="$(df_trim "${fields[1]}")" # Priority
    col2="$(df_trim "${fields[2]}")" # Task ID
    col3="$(df_trim "${fields[5]}")" # State
    col5="$(df_trim "${fields[6]}")" # Owner role

    # Skip the header row.
    case "$col1" in
      Priority) continue ;;
    esac
    # Skip the placeholder / empty rows.
    [ -z "$col2" ] && continue
    [ "$col2" = "-" ] && continue
    case "$col3" in
      NO_TASKS|"") continue ;;
    esac

    printf '%s\t%s\t%s\t%s\n' "$col1" "$col2" "$col3" "$col5"
  done < "$board"
}
