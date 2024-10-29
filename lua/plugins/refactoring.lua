-- Code refactoring
return {
        "ThePrimeagen/refactoring.nvim",
        event = { "BufReadPost" },
        cmd = { "Refactor" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            local refactoring = require("refactoring")
            refactoring.setup({})
            vim.keymap.set({ "n", "x" }, "<leader>rm", function()
                refactoring.select_refactor({})
            end, { desc = "Refactoring Menu" })
            vim.keymap.set("n", "<leader>rd", function()
                require("refactoring").debug.printf({ below = false })
            end, { desc = "Refactoring debug print statement" })
            vim.keymap.set("n", "<leader>rv", function()
                require("refactoring").debug.print_var({})
            end, { desc = "Refactoring print var" })
            vim.keymap.set("n", "<leader>rc", function()
                require("refactoring").debug.cleanup({})
            end, { desc = "Refactoring print cleanup" })
            require("which-key").add({
                "<leader>r",
                group = "+[r]efactoring",
            })
        end,
        keys = {},
    }
