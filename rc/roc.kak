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
  # hook window InsertChar \n -group roc-indent roc-insert-on-new-line
  hook window InsertChar \n -group roc-indent roc-indent-on-new-line
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

add-highlighter shared/roc regions
add-highlighter shared/roc/code default-region group
# TODO: Does Roc have multi-line strings?
# TODO: Support escapes in strings (e.g. `"caf\u(e9)" == "café"` and the usual
# `"\n\t"`)
add-highlighter shared/roc/string region '"' (?<!\\)(?:\\\\)*" regions
add-highlighter shared/roc/string/fill default-region fill string
add-highlighter shared/roc/string/interpolation region (?<!\\)(?:\\\\)*\$\( \) ref roc
add-highlighter shared/roc/comment region '^\h*#' $ fill comment
add-highlighter shared/roc/code/keyword group
add-highlighter shared/roc/code/keyword/module regex \b(?:interface|app|package|platform)\b 0:keyword
# TODO: Is this old syntax?
# https://www.roc-lang.org/tutorial#app-module-header
add-highlighter shared/roc/code/keyword/module2 regex \b(?:packages|imports|provides|to)\b 0:keyword
# TODO: Is this list old? Doesn't include newer `import` (singular) keyword.
# https://www.roc-lang.org/tutorial#reserved-keywords
add-highlighter shared/roc/code/keyword/reserved regex \b(?:if|then|else|when|as|is|dbg|expect|expect-fx|crash|interface|app|package|platform|hosted|exposes|imports|with|generates|packages|requires|provides|to)\b 0:keyword
add-highlighter shared/roc/code/keyword/import regex \b(?:import|exposing)\b 0:keyword
add-highlighter shared/roc/code/keyword/branch regex \b(?:when|is|if|then|else)\b 0:keyword
# TODO: Ditch "keyword operator vs keyword symbol" distinction
# https://www.roc-lang.org/tutorial#operator-desugaring-table (list is incomplete, doesn't include `Ord`-y operators)
add-highlighter shared/roc/code/keyword/operator regex (?:\+|-|\*|/|//|\^|%|==|!=|<|<=|>|>=|&&|\|\||\b!|\|>) 0:keyword
add-highlighter shared/roc/code/keyword/symbol regex (?:=|:|:=|->|<-|\$?\(|\)|\{|\}|\[|\]|,|!\b|\\|\||&|\?|\b_\b) 0:keyword
add-highlighter shared/roc/code/keyword/other regex (?:dbg|crash|expect) 0:keyword
add-highlighter shared/roc/code/module regex (?:import)\h+\b(\w+(?:\.[A-Z]\w+)*)\b 1:module
add-highlighter shared/roc/code/number group
# TODO: Highlight tags. Should be PascalCase things lacking dots. Don't do this
# if there are things like that which aren't tags; ambiguity bad. Newtypes have
# an `@` prefix, it seems?
add-highlighter shared/roc/code/number/decimal regex (?:(\b|-)[0-9](?:[0-9_]*[0-9])?(?:\.[0-9](?:[0-9_]*[0-9])?)?)(?:[ui](?:8|16|32|64|128)|f(?:32|64)|dec)?\b 0:value
add-highlighter shared/roc/code/number/hexadecimal regex \b(0x[0-9a-f_]*[0-9a-f])(?:[ui](?:8|16|32|64|128)|f(?:32|64)|dec)?\b 0:value
add-highlighter shared/roc/code/number/binary regex \b(?:0b[01_+]*[01])(?:[ui](?:8|16|32|64|128)|f(?:32|64)|dec)?\b 0:value

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden roc-trim-indent %{
  try %{ execute-keys -draft -itersel x s \h+$ <ret> d }
}

define-command -hidden roc-insert-on-new-line %{
  # TODO: Continue comment blocks
  # TODO: Close pairs
  nop
}

define-command -hidden roc-indent-on-new-line %<
  evaluate-commands -draft -itersel %<
    # Preserve previous indent
    try %{ execute-keys -draft <semicolon> K <a-&> }
    # Trim trailing whitespace from previous line
    try %{ execute-keys -draft k x s \h+$ <ret> d }
    # Increase indentation if previous line has special ending
    try %< execute-keys -draft k x <a-k> \b(?:is|then|else)\b|(?:\(|\{|\[|=|:|<lt>-|-<gt>)$ <ret> <a-K> ^\h*# <ret> j <a-gt> >
  >
>

§
