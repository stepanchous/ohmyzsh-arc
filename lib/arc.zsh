# arc VCS prompt support for oh-my-zsh
# arc is an internal Yandex VCS tool (similar to git)

function _omz_arc_prompt_info() {
  # Get branch and status in one arc call.
  # arc status -b -s outputs:
  #   "## branch...remote/branch" on first line (with -b)
  #   followed by short status lines for dirty files (with -s)
  # Returns non-zero exit code when not in an arc repo.
  local status_output
  status_output=$(command arc status -b -s 2>/dev/null) || return 0
  [[ -z "$status_output" ]] && return 0

  # First line must start with "## " (branch tracking line)
  local first_line="${status_output%%$'\n'*}"
  [[ "$first_line" == \#\#* ]] || return 0

  # Extract branch name: strip "## " prefix, then "...remote" suffix
  local ref="${first_line#\#\# }"
  ref="${ref%%...*}"
  [[ -z "$ref" ]] && return 0

  # Dirty if there are additional lines after the branch line
  local dirty
  if [[ "$status_output" == *$'\n'* ]]; then
    dirty="$ZSH_THEME_ARC_PROMPT_DIRTY"
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
