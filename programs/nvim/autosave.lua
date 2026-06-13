-- autosave
require("auto-save").setup({
  enabled = true,
  trigger_events = {
    immediate_save = { "BufLeave", "FocusLost" },
    defer_save = { "InsertLeave", "TextChanged" },
    cancel_deferred_save = { "InsertEnter" },
  },
  conditions = {
    exists = true,
    filename_is_not = {},
    filetype_is_not = {},
    modifiable = true,
  },
  write_all_buffers = false,
  noautocmd = false,
  lockmarks = false,
  debounce_delay = 135,
})
