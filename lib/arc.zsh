# arc VCS prompt support for oh-my-zsh
# arc is an internal Yandex VCS tool (similar to git)

function _omz_arc_prompt_info() {
  # Walk up from $PWD to find the .arc directory (no process spawn)
  local dir="$PWD"
  local arc_dir=""
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.arc" ]]; then
      arc_dir="$dir/.arc"
      break
    fi
    dir="${dir:h}"
  done
  [[ -z "$arc_dir" ]] && return 0

  # Read branch directly from .arc/HEAD (no process spawn)
  # Format: Symbolic: "branch_name"
  local head_file="$arc_dir/HEAD"
  [[ -f "$head_file" ]] || return 0

  local raw_head
  raw_head=$(< "$head_file")
  [[ "$raw_head" == Symbolic:* ]] || return 0

  local ref="${raw_head#Symbolic: \"}"
  ref="${ref%\"}"
  [[ -z "$ref" ]] && return 0

  # Dirty status: opt-in only (arc status is slow — set ARC_PROMPT_SHOW_DIRTY=1 to enable)
  local dirty
  if [[ "${ARC_PROMPT_SHOW_DIRTY:-0}" == "1" ]]; then
    if [[ -n "$(command arc status --short 2>/dev/null | grep -v '^## ')" ]]; then
      dirty="$ZSH_THEME_ARC_PROMPT_DIRTY"
    else
      dirty="$ZSH_THEME_ARC_PROMPT_CLEAN"
    fi
  else
    dirty="$ZSH_THEME_ARC_PROMPT_CLEAN"
  fi

  echo "${ZSH_THEME_ARC_PROMPT_PREFIX}${ref:gs/%/%%}${dirty}${ZSH_THEME_ARC_PROMPT_SUFFIX}"
}

function arc_prompt_info() {
  _omz_arc_prompt_info
}

ZSH_THEME_ARC_PROMPT_PREFIX="${ZSH_THEME_ARC_PROMPT_PREFIX:-%{$fg_bold[blue]%}arc:(%{$fg[red]%}}"
ZSH_THEME_ARC_PROMPT_SUFFIX="${ZSH_THEME_ARC_PROMPT_SUFFIX:-%{$reset_color%} }"
ZSH_THEME_ARC_PROMPT_DIRTY="${ZSH_THEME_ARC_PROMPT_DIRTY:-%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}}"
ZSH_THEME_ARC_PROMPT_CLEAN="${ZSH_THEME_ARC_PROMPT_CLEAN:-%{$fg[blue]%})}"