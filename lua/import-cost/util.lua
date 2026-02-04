local M = {}

---@param msg string
---@param level? integer
function M.log(msg, level)
  vim.notify('[import-cost.nvim]: ' .. msg, level or vim.log.levels.INFO)
end

---@param string string
---@return boolean
function M.is_import_string(string)
  return string:sub(1, 6) == 'import' or string:sub(1, 5) == 'const'
end

---@param raw_string string
---@return string
function M.normalize_string(raw_string)
  local string = raw_string

  -- pad with semicolon
  if string:sub(-1, -1) ~= ';' then
    string = string .. ';'
  end

    -- stylua: ignore
    string = string
        :match('.-;') -- extract first statement
        :gsub(' as %S+', '') -- remove aliases
        :gsub("'", '"') -- swap single for double quotes
        :gsub('%s+', '') -- remove whitespace

  return string
end

---@param chunk string
---@return table?
function M.parse_data(chunk)
  local ok, json = pcall(vim.fn.json_decode, chunk)

  if not ok or not json then
    return
  end

  return json.data
end

return M
