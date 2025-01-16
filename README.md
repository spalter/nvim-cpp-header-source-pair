# nvim-cpp-header-source-pair

A simple plugin to always open header files along side source files for C/C++ projects.

## Lazy

```lua
require("lazy").setup({
    {
        "spalter/nvim-cpp-header-source-pair",
        config = function()
            require("cpp_header_source_pair").setup({
                open_header_sources = true, -- Enable pairing
                fixed_order = true,         -- Always open headers on the left, sources on the right
            })
        end,
        event = { "BufReadPost" }, -- Load the plugin only when reading a file
    },
})

```

## License

Check [LICENSE](LICENSE) for more information.
