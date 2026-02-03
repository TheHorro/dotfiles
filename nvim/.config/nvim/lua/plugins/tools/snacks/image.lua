local M = {} 

M.image = {
  enabled = true,
  formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif", "mp4", "mov", "avi", "mkv", "webm", "pdf", "icns" },
  force_render = false,
  doc = {
    enabled = true,
    inline = false,
    float = true,
    max_width = 80,
    max_height = 40,
    render_patterns = {
      latex = {
        "\\\\includegraphics%s*%[[^%]]*%]%s*{([^}]*)}",
        "\\\\includegraphics%s*{([^}]*)}",
      },
    },
    conceal = function(lang, type)
      return type == "math"
    end,
  },
  icons = { math = "󰪚 ", chart = "󰄧 ", image = " " },
  math = {
    enabled = true,
    typst = {
      tpl = [[
      #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
      #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
      #set text(size: 12pt, fill: rgb("${color}"))
      ${header}
      ${content}]],
    },
  },
}

return M
