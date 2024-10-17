# nvim-dap-kotlin

An extension for [nvim-dap][1] providing configurations for launching kotlin debugger ([kotlin-debug-adapter][7]) and debugging individual tests.

## Features

- Auto launch kotlin-debug-adapter. No configuration needed. You just have to have `kotlin-debug-adapter` in your path.
- Run just the closest test from the cursor in debug mode (uses treesitter). See [debugging tests](#debugging-tests) section below for more details.
- Configuration to start a debug session in the main function.
- Configuration to start a debug session in the latest cached main function.
- Configuration to run tests in a debug session.

## Pre-reqs

- Neovim
- [nvim-dap][1]
- [kotlin-debug-adapter][7] >= 0.4.3

This plugin extension make usage of treesitter to find the nearest test to debug.
Make sure you have the Kotlin treesitter parser installed.
If using [nvim-treesitter][3] plugin you can install with `:TSInstall kotlin`.

## Installation

### Plugin
#### using [vim-plug][4]: 
```
Plug 'Mgenuit/nvim-dap-kotlin'
```
#### using [packer.nvim][5]: 
```
use 'Mgenuit/nvim-dap-kotlin'
```
#### using [Lazy][8]:
```
{ "Mgenuit/nvim-dap-kotlin", config = true }
 ```
### Debug adapter

#### Using Mason

In neovim
```
:MasonInstall kotlin-debug-adapter
```

#### Using Brew 

```bash
brew install kotlin-debug-adapter
```

## Usage

### Register the plugin

Call the setup function in your `init.vim` to register the go adapter and the configurations to debug go tests:

```vimL
lua require('dap-kotlin').setup()
```

> NOTE: When installing with Lazy this step is done by the plugin manager automatically.

### Configuring

It is possible to customize nvim-dap-kotlin by passing a config table in the setup function.

The example below shows all the possible configurations:

```lua
lua require('nvim-dap-kotlin').setup {
    dap_command = "kotlin-debug-adapter",
    project_root = "${workspaceFolder}",
    enable_logging = false,
    log_file_path = "",
}
```

### Use nvim-dap as usual

- Call `:lua require('dap').continue()` to start debugging.
- All pre-configured debuggers will be displayed for you to choose from.
- See `:help dap-mappings` and `:help dap-api`.

### Debugging tests

To debug the closest test method above the cursor use you can select the `Closest Test` configuration.
This support both normal and backtick enclosed method names.

## Acknowledgement

Thanks to [nvim-dap-go][6] for the inspiration.

[1]: https://github.com/mfussenegger/nvim-dap
[3]: https://github.com/nvim-treesitter/nvim-treesitter
[4]: https://github.com/junegunn/vim-plug
[5]: https://github.com/wbthomason/packer.nvim
[6]: https://github.com/leoluz/nvim-dap-go
[7]: https://github.com/fwcd/kotlin-debug-adapter
[8]: https://github.com/folke/lazy.nvim
[9]: https://github.com/fwcd/kotlin-debug-adapter/pull/68
