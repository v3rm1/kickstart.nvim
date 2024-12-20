-- nvim Ultra Folding based on LSP
return {
    {
        "kevinhwang91/nvim-ufo",
       -- event = { "LspAttach" },
        dependencies = {
            "kevinhwang91/promise-async",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            local handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, { chunkText, hlGroup })
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        -- str width returned from truncate() may less than 2nd argument, need padding
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, { suffix, "MoreMsg" })
                return newVirtText
            end
            local ftMap = {
                vim = "indent",
                python = { "indent" },
                git = "",
            }
            local function customizeSelector(bufnr)
                local function handleFallbackException(err, providerName)
                    if type(err) == "string" and err:match("UfoFallbackException") then
                        return require("ufo").getFolds(bufnr, providerName)
                    else
                        return require("promise").reject(err)
                    end
                end

                return require("ufo")
                    .getFolds(bufnr, "lsp")
                    :catch(function(err)
                        return handleFallbackException(err, "treesitter")
                    end)
                    :catch(function(err)
                        return handleFallbackException(err, "indent")
                    end)
            end
            require("ufo").setup({
                provider_selector = function(bufnr, filetype, buftype)
                    return ftMap[filetype] or customizeSelector
                end,
                fold_virt_text_handler = handler,
            })

            vim.keymap.set("n", "zR", require("ufo").openAllFolds)
            vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
            vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
            vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
            vim.keymap.set('n', 'K', function()
                local winid = require('ufo').peekFoldedLinesUnderCursor()
                if not winid then
                    vim.lsp.buf.hover()
                end
            end)
        end,
        keys = {
            "zR", "zM", "zr", "zm"
        },
    },
}
