# arc VCS prompt support for oh-my-zsh
# arc is an internal Yandex VCS tool (similar to git)

typeset -g _ARC_ROOT_CACHE=""      # path to arcadia root, e.g. /Users/user/arcadia
typeset -g _ARC_HEAD_FILE_CACHE="" # path to .arc/HEAD
typeset -g _ARC_PROMPT_CACHE=""    # fully rendered prompt string

function _arc_render_prompt() {
  _ARC_PROMPT_CACHE=""
  [[ -z "$_ARC_HEAD_FILE_CACHE" ]] && return

  local raw_head
  raw_head=$(< "$_ARC_HEAD_FILE_CACHE" 2>/dev/null) || return
  [[ "$raw_head" == Symbolic:* ]] || return

  local ref="${raw_head#Symbolic: \"}"
  ref="${ref%\"}"
  [[ -z "$ref" ]] && return

  _ARC_PROMPT_CACHE="${ZSH_THEME_ARC_PROMPT_PREFIX}${ref:gs/%/%%}${ZSH_THEME_ARC_PROMPT_CLEAN}${ZSH_THEME_ARC_PROMPT_SUFFIX}"
}

function _arc_chpwd() {
  # Fast path: still inside the cached arc root — just re-read HEAD for branch changes
  if [[ -n "$_ARC_ROOT_CACHE" ]]; then
    if [[ "$PWD" == "$_ARC_ROOT_CACHE" || "$PWD" == "$_ARC_ROOT_CACHE/"* ]]; then
      _arc_render_prompt
      return
    fi
    # Left arc root — clear cache
    _ARC_ROOT_CACHE=""
    _ARC_HEAD_FILE_CACHE=""
    _ARC_PROMPT_CACHE=""
    return
  fi

  # Slow path: walk up to find .arc directory (only runs when entering arcadia)
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.arc/HEAD" ]]; then
      _ARC_ROOT_CACHE="$dir"
      _ARC_HEAD_FILE_CACHE="$dir/.arc/HEAD"
      _arc_render_prompt
      return
    fi
    dir="${dir:h}"
  done
  _ARC_PROMPT_CACHE=""
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _arc_chpwd
_arc_chpwd  # initialize on shell start

# arc_prompt_info is instant — just prints the cached string
function arc_prompt_info() {
  echo -n "$_ARC_PROMPT_CACHE"
}

ZSH_THEME_ARC_PROMPT_PREFIX="${ZSH_THEME_ARC_PROMPT_PREFIX:-%{$fg_bold[blue]%}arc:(%{$fg[red]%}}"
ZSH_THEME_ARC_PROMPT_SUFFIX="${ZSH_THEME_ARC_PROMPT_SUFFIX:-%{$reset_color%} }"
ZSH_THEME_ARC_PROMPT_DIRTY="${ZSH_THEME_ARC_PROMPT_DIRTY:-%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}}"
ZSH_THEME_ARC_PROMPT_CLEAN="${ZSH_THEME_ARC_PROMPT_CLEAN:-%{$fg[blue]%})}"