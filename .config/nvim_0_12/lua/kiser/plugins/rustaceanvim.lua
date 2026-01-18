vim.pack.add({
    { src = gh("mrcjkb/rustaceanvim"), version = vim.version.range("^6") }
})
vim.g.rustaceanvim = {
    server = {
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = true,
                check = {
                    command = "clippy",
                    allTargets = true
                },
                rustfmt = {
                    extraArgs = { "+nightly" }
                },
                cargo = {}
            }
        }
    }
}
