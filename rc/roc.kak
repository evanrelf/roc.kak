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
add-highlighter shared/roc/string region %{(?<!')"} (?<!\\)(\\\\)*" fill string
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
# https://www.roc-lang.org/tutorial#operator-desugaring-table (list is incomplete, doesn't include `Ord`-y operators)
add-highlighter shared/roc/code/keyword/operator regex (?:\+|-|\*|/|//|\^|%|==|!=|<|<=|>|>=|&&|\|\||\b!|\|>) 0:keyword
add-highlighter shared/roc/code/keyword/symbol regex (?:=|:|->|<-|\(|\)|\{|\}|\[|\]|,|!\b|\\|\||) 0:keyword
add-highlighter shared/roc/code/keyword/other regex (?:dbg|crash) 0:keyword
# TODO: Does Roc allow `_`s in number literals?
add-highlighter shared/roc/code/number regex ((\b|-)[0-9](?:[0-9_]*[0-9])?(?:\.[0-9](?:[0-9_]*[0-9])?)?)\b 1:value

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden roc-trim-indent %{
  try %{ execute-keys -draft -itersel x s \h+$ <ret> d }
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
