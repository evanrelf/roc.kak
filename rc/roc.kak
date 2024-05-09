# https://www.roc-lang.org/
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](roc) %{
  set-option buffer filetype roc
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=roc %<
  require-module roc
  hook window ModeChange pop:insert:.* -group roc-trim-indent roc-trim-indent
  hook -once -always window WinSetOption filetype=.* %{ remove-hooks window roc-.+ }
>

hook -group roc-highlight global WinSetOption filetype=roc %{
  add-highlighter window/roc ref roc
  hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/roc }
}

provide-module roc %§

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden roc-trim-indent %{
  try %{ execute-keys -draft -itersel x s \h+$ <ret> d }
}

§
