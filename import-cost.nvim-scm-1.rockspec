rockspec_format = '3.0'
package = 'import-cost.nvim'
version = 'scm-1'

source = {
  url = 'git+https://git.barrettruth.com/barrettruth/import-cost.nvim.git',
}

description = {
  summary = 'Display JavaScript import costs inside Neovim',
  homepage = 'https://git.barrettruth.com/barrettruth/import-cost.nvim',
  license = 'GPL-3.0',
}

dependencies = {
  'lua >= 5.1',
}

build = { type = 'builtin' }
