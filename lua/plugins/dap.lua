-- Debug Adapter Protocol settings
return {
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {
                    virt_text_pos = "eol",
                },
            },
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup({
                controls = {
                    element = "repl",
                    enabled = true,
                    icons = {
                        disconnect = "",
                        pause = "",
                        play = "",
                        run_last = "",
                        step_back = "",
                        step_into = "",
                        step_out = "",
                        step_over = "",
                        terminate = "",
                    },
                },
                element_mappings = {},
                expand_lines = true,
                floating = {
                    border = "single",
                    mappings = {
                        close = { "q", "<Esc>" },
                    },
                },
                force_buffers = true,
                icons = {
                    collapsed = "",
                    current_frame = "",
                    expanded = "",
                },
                layouts = {
                    {
                        elements = {
                            {
                                id = "scopes",
                                size = 0.50,
                            },
                            {
                                id = "watches",
                                size = 0.25,
                            },
                            {
                                id = "breakpoints",
                                size = 0.15,
                            },
                            {
                                id = "stacks",
                                size = 0.10,
                            },
                        },
                        position = "left",
                        size = 0.2,
                    },
                    {
                        elements = {
                            {
                                id = "repl",
                                size = 1,
                            },
                        },
                        position = "right",
                        size = 0.3,
                    },
                    {
                        elements = {
                            {
                                id = "console",
                                size = 1,
                            },
                        },
                        position = "bottom",
                        size = 0.3,
                    },
                },
                mappings = {
                    edit = "e",
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    repl = "r",
                    toggle = "t",
                },
                render = {
                    indent = 4,
                    max_type_length = 25,
                    max_value_lines = 50,
                },
            })
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "DiffDelete" })
            vim.api.nvim_set_hl(0, "DapBreakpointCursorline", { default = true, bg = "#311d26" })

            local sign = vim.fn.sign_define

            sign("DapBreakpoint", {
                text = "●",
                texthl = "DiagnosticError",
                linehl = "DapBreakpointCursorline",
                numhl = "DiagnosticError",
            })
            sign("DapBreakpointCondition", {
                text = "●",
                texthl = "DiagnosticError",
                linehl = "DapBreakpointCursorline",
                numhl = "DiagnosticError",
            })
            sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" })
            sign(
                "DapStopped",
                { text = "󰁕 ", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DiagnosticWarn" }
            )
            sign("DapBreakpointRejected", {
                text = " ",
                texthl = "DiagnosticError",
                linehl = "DapBreakpointCursorline",
                numhl = "DiagnosticError",
            })

            vim.keymap.set("n", "<localleader>du", dapui.toggle, { desc = "DAP: UI Toggle" })
            vim.keymap.set({ "n", "v" }, "<localleader>de", dapui.eval, { desc = "DAP: UI Eval" })
        end,
        keys = {
            "<localleader>du",
        },
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "williamboman/mason.nvim",
            { "mfussenegger/nvim-dap-python", lazy = true },
            "rcarriga/cmp-dap",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local dap = require("dap")
            local dap_py = require("dap-python")

            require("cmp").setup({
                enabled = function()
                    return vim.api.nvim_get_option_value("buftype", {}) ~= "prompt"
                        or require("cmp_dap").is_dap_buffer()
                end,
            })

            require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
                sources = {
                    { name = "dap" },
                },
            })

            local path = require("mason-registry").get_package("debugpy"):get_install_path()
            dap_py.setup(path .. "/venv/bin/python")
            table.insert(dap.configurations.python, {
                console = "integratedTerminal",
                name = "Launch file -nojustMyCode",
                program = "${file}",
                request = "launch",
                type = "python",
                justMyCode = "false",
            })
            table.insert(dap.configurations.python, {
                console = "integratedTerminal",
                name = "Launch file with arguments -nojustMyCode",
                program = "${file}",
                args = function()
                    local args_string = vim.fn.input("Arguments: ")
                    return vim.split(args_string, " +")
                end,
                request = "launch",
                type = "python",
                justMyCode = "false",
            })

            if not dap.adapters["codelldb"] then
                require("dap").adapters["codelldb"] = {
                    type = "server",
                    host = "localhost",
                    port = "${port}",
                    executable = {
                        command = "codelldb",
                        args = {
                            "--port",
                            "${port}",
                        },
                    },
                }
            end
            for _, lang in ipairs({ "c", "cpp" }) do
                dap.configurations[lang] = {
                    {
                        type = "codelldb",
                        request = "launch",
                        name = "Launch file",
                        program = function()
                            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                        end,
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "codelldb",
                        request = "attach",
                        name = "Attach to process",
                        processId = require("dap.utils").pick_process,
                        cwd = "${workspaceFolder}",
                    },
                }
            end

            vim.keymap.set("n", "<localleader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<localleader>dB", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "DAP: Set Breakpoint" })
            vim.keymap.set("n", "<localleader>dc", dap.continue, { desc = "DAP: Continue/Start" })
            vim.keymap.set("n", "<localleader>di", dap.step_into, { desc = "DAP: Step into" })
            vim.keymap.set("n", "<localleader>do", dap.step_over, { desc = "DAP: Step over" })
            vim.keymap.set("n", "<localleader>dO", dap.step_out, { desc = "DAP: Step out" })
            vim.keymap.set("n", "<localleader>dp", dap.pause, { desc = "DAP: Pause" })
            vim.keymap.set("n", "<localleader>dt", dap.terminate, { desc = "DAP: Terminate" })
            vim.keymap.set("n", "<localleader>dC", dap.run_to_cursor, { desc = "DAP: Run to Cursor" })
            vim.keymap.set("n", "<localleader>ds", dap.session, { desc = "DAP: Session" })

            vim.keymap.set("n", "<F6>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
            vim.keymap.set("n", "<F7>", dap.step_out, { desc = "DAP: Step out" })
            vim.keymap.set("n", "<F8>", dap.continue, { desc = "DAP: Continue/Start" })
            vim.keymap.set("n", "<F9>", dap.step_over, { desc = "DAP: Step over" })
            vim.keymap.set("n", "<F10>", dap.step_into, { desc = "DAP: Step into" })
            vim.keymap.set("n", "<F12>", dap.terminate, { desc = "DAP: Terminate" })

            require("which-key").add({
                "<localleader>d",
                group = "+[d]ebug",
            })
        end,
        keys = {
            "<localleader>db",
            "<localleader>dB",
            "<localleader>dc",
            "<localleader>di",
            "<localleader>do",
            "<localleader>dO",
            "<localleader>dp",
            "<localleader>dt",
            "<localleader>dC",
            "<localleader>ds",
            "<F6>",
            "<F7>",
            "<F8>",
            "<F9>",
            "<F10>",
            "<F12>",
        },
    },
}
