local M = {}

local ic = require('import-cost')

---@type table<integer, integer>
local job_cache = {}

---@param bytes number
---@return string
local format_bytes = function(bytes)
  local format = ic.config.format
  if bytes < 1024 then
    return string.format(format.byte_format, bytes)
  end

  return string.format(format.kb_format, 0.0009765625 * bytes)
end

---@param bufnr integer
---@param data table
---@param extmark_id? integer
---@return integer
function M.render_extmark(bufnr, data, extmark_id)
  local format = ic.config.format
  local line, size, gzip = data.line - 1, format_bytes(data.size), format_bytes(data.gzip)

  local virt_text = string.format(format.virtual_text, size, gzip)

  return vim.api.nvim_buf_set_extmark(bufnr, ic.ns_id, line, -1, {
    id = extmark_id,
    virt_text = {
      {
        virt_text,
        'ImportCostVirtualText',
      },
    },
    hl_mode = 'combine',
  })
end

---@param job_id integer
---@param bufnr integer
function M.send_buf_contents(job_id, bufnr)
  local contents = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

  vim.fn.chansend(job_id, contents)
  vim.fn.chanclose(job_id, 'stdin')
end

---@param job_id integer
---@param bufnr integer
function M.stop_prev_job(job_id, bufnr)
  if job_cache[bufnr] then
    vim.fn.jobstop(job_cache[bufnr])
  end

  job_cache[bufnr] = job_id
end

return M
