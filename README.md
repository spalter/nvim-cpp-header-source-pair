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
                fixed_order = true,         -- Headers on the left, sources on the right
            })
        end
    },
})
```

## License

Check [LICENSE](LICENSE) for more information.
