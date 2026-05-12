local M = {}
<* for name, value in colors *>
M.{{name}} = 0x{{value.dark.hex_stripped}}
M.{{name}}_hex = "{{value.dark.hex}}"
<* endfor *>

return M

