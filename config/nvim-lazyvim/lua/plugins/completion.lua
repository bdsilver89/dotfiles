return {
  {
    "hrsh7th/nvim-cmp",
    opts = {
      window = {
        completion = {
          scrollbar = false,
          side_padding = 1,
          winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder",
          border = "rounded",
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
        },
      },
    },
  },
}
