" Highlight @define-color declarations
syn match gtkDefineColor "@define-color" nextgroup=gtkColorName skipwhite
syn match gtkColorName   "\w\+" contained nextgroup=gtkColorValue skipwhite
syn match gtkColorValue  "#[0-9a-fA-F]\{3,8\}\|rgb(.\{-})\|rgba(.\{-})" contained

" Also highlight @color-name references used as values
syn match gtkColorRef    "@[a-zA-Z_][a-zA-Z0-9_-]*"

hi def link gtkDefineColor  Keyword
hi def link gtkColorName    Identifier
hi def link gtkColorValue   Number
hi def link gtkColorRef     Type
