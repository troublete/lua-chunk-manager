# LCM

> The Lua Chunk Manager 

> The toolkit does not yet work on Windows, only if there is some kind
> of ?nix Environment available. This might change in the future though.

## About

The Lua Chunk Manager aims to be a simpler toolkit for reusing lua code as
dependencies and distributing lua code (as executable scripts, libs, ...).

I created this toolkit because i wanted to have simpler tooling for my own lua
and love2d project for managing requirements which does not depend on a
registry by default, since a lot of libs are just on Github.

## Requirements

* Lua
* built-in functions:
	- `bash`
	- `test`
	- `mkdir`
	- `curl`
	- `rm`
	- `tar`
	- `mv`
	- `wget`

## Demo

`chunkfile.lua` is the essential part that defines an projects' exports,
requirements and executable exports. Therefore below an example with all of
them. But you define what you need, you don't have to use all of them always.
And in fact if there is an `init.lua` you do not need a `chunkfile.lua` at
all, `init.lua` will be the default export for your library namespace.

Some more info:

- Requirements are installed 'recursively' so requirements' requirements are
  loaded aswell

- LCM resolves dependencies flat, so no nesting within libs

- Uniqueness of requirements is defined by their respective `namespaces` so
  multiple versions or even instances of the same lib can be used when named
  differently

- `namespaces` can contain `/` (to create nested directories) and will be
  converted to `.`-notation to be loadable

- LCM allows relative paths inside of libs; e.g. lets assume there is a lib
  with namespace `simple_lib`. For a file that is located in
  `*simple_lib_path*/src/main.lua` the require would be on lib root level:
  `require('src.main')`. This is remapped to `lib.simple_lib.src.main` by the
  loader when used in scope of the project containing the `chunkfile.lua` and
  will resolve correctly

```lua
-- chunkfile.lua

-- EXPORTING --

-- lets assume the library is imported with namespace `example`

-- for exposing some file as default export
-- (there is no need for this export if there is an `init.lua`)
export { 'relative_path/to/file.lua' }
-- this will be the file returned when the library
-- namespace is required: e.g. `require('example')`

-- for exposing some file as named export
export { 'relative/path/to/file.lua', 'additional'}
-- this will be the file returned when namespace is
-- required: `require('example.additional')`

-- REQUIRING --

-- adding local directory as requirement
symlink { 'namespace', '/local/absolute/path' }
-- can be loaded with: `require('namespace')`

-- adding public github repo as requirement
github { 'user/repo' }
-- can be loaded with: `require('user.repo')`

-- adding private github repo as requirement
github { 'user/repo', user='user:api_token' }
-- can be loaded with: `require('user.repo')`

-- adding github repo with different version then master (which is default)
github { 'user/repo', at='v1.0.0' }
-- can be loaded with: `require('user.repo')`

-- adding requirement with custom namespace
-- (e.g. to allow multiple versions)
github { 'user/repo', namespace='other_name'}
-- can be loaded with: `require('other_name')`

-- adding requirement with custom env
-- (will only be installed with `lcm install` or `lcm install --env='dev'`)
symlink { 'simple_lib', '/local/path', env='dev' }

-- `env`, `namespace` apply on any strategy
-- `at`, `user` apply only on the github strategy

-- EXECUTABLES -- 

-- adding a executable in `bin` directory
bin { 'relative/file/path.lua' }
-- can be used when installed globally (-g) as `path`
-- can be used when installed locally as `./bin/path

-- adding a named executable in `bin` directory
bin { 'relative/file/path.lua', 'fancy_name' }
-- can be used when installed globally (-g) as `fancy_name`
-- can be used when installed locally as `./bin/fancy_name
```

```lua
-- example: test.lua
-- after running `lcm install` in the directory with the `chunkfile.lua`
-- above your project needs to require the 'loader' (located
-- in the `lib` directory, alongside the requirements).
-- After that, all requirements can be used.
-- (checkout 'tpl/load.lua' for details)

require('lib.load')
local repo = require('user.repo')
local other = require('other_name')

...
```

## Install

To simply install the toolkit on your machine run following command
(requires `wget` and `bash`):

```bash
wget -O - https://raw.githubusercontent.com/troublete/lua-chunk-manager/master/install.sh | bash
```

This will install the toolkit into `~/.lcm` which is the default 'global'
location; you can choose a new location if you like.
(`export LCM_HOME=*your/path/of/chosing*`)

The `LCM_HOME` contains all system wide available scripts and libraries that
were installed 'globally' (see flag `--global`), including LCM itself.

After installing it you shoud be able to run `lcm --help` and see the help
screen.

## Uninstall

To uninstall the toolkit run `rm -rf $LCM_HOME` and remove the lines below the
`# lcm-config` in `/etc/profile` (the instructions to load `sh-config`).

## Usage

If you want to use locally and globally installed dependencies you need to run
`require('lib.load')` in your entrypoint before requiring any required
library. (see `lcm init` for info how to create a `lib/load.lua`)

There are several commands available to be run. Below a quick overview with
some common use-cases. For more info about flags etc. read through the
`lcm --help` contents.

All commands can be applied on the `LCM_HOME` (in global scope) when run with
flag `--global` or `-g`.

### `lcm init`

The `init` command initializes a new chunk. It runs idempotent. Without flags
it creates following structure.

```
.
├── chunkfile.lua # the chunk config, contains requirements and exports
└── lib
    ├── load.lua # the loader, must be required before requiring anyting else; allows the usage of locally and globally installed dependencies
    └── map.lua # a helper map, which contains module load information after `lcm install`
```

If you only want to depend on globally installed libs you can run `lcm
init --loader` and only create `/lib/load.lua`.

If you only want to create a chunk without a specific export file you do not
need to run init at all, as long as there is a `init.lua` your chunk will be
require-able.

If you want to create a custom default or named export and don't have
dependencies, you can run `lcm init --chunkfile` and only create the
chunkfile so you can setup the exports.

### `lcm add`

The `add` command adds a new instruction to the `chunkfile.lua`. This can be
used to add a new requirement to the chunkfile.

`lua add github:user/handle --namespace=some_lib` adds for example a
`github { 'user/handle', namespace='some_lib' }` instruction.

You can add as many instructions as you like with one call. So `lua add
github:user/handle github:user/other_handle
symlink:name,/Path/to/lib --user=user:some_api_token` will create

```
github { 'user/handle', user = 'user:some_api_token' }
github { 'user/other_handle', user = 'user:some_api_token' }
symlink { 'name', '/Path/to/lib', user = 'user:some_api_token' }
```

To register a local lib as globally available lib you can run
`lcm add -g symlink:name,$PWD`.

Runs `lcm install` after adding instructions, if not wanted run with
`--no-install`.

There is no `lcm remove` command. If you want to remove a dependency, just
remove it from the `chunkfile.lua` (and run `lcm fix --lib` to clean the lib
directory).

### `lcm install`

Runs idempotent.

Installs requirements and requirements' requirements in `lib`.
Writes executables to `bin`.

### `lcm clean`

Removes everything (dependencies, bins, config files, ...) when run without
flags. 

When you want to remove only the installed libs run with `--lib` flag.

When you want to remove only the created executables run with `--bin` flag.

### `lcm fix`

This command is a utility tool to fix your chunk setup. 

If run without flags it does nothing, so there is no default fix. 

If run with `--lib` flag, it cleans up `lib` directory and the `lib/map.lua`
file. It removes any library that is not listed in the `chunkfile.lua`
anymore. And rebuilds the `lib/map.lua` to include only available libraries.

### `lcm list`

List all installed modules. 

If you want to display all additional exports (also called load statements)
run with `--with-load`.

If you only want to display additional exports run with `--only-load`.

## Chunkfiles

As stated multiple times the `chunkfile.lua` is your obilgatory chunk config.

Every `chunkfile.lua` is execute in a sandbox-ed environment; and only the
exposed LCM functionality is available. So there should be little
security problems.

It is quite tolerant though if there is any instruction added that the LCM
sandbox doesn't know it just ignores it. So it can be used as container for
more than just LCM config. 

## On exports

A lib can export one or multiple exports via the `chunkfile.lua`.

Every lib that should be requireable must have at least one default export.

No `chunkfile.lua` is needed when an `init.lua` is available, which will then
serve as default export.

Provided `export` instructions must use a relative path.

Multiple exports must be defined via naming (hence named exports).
The name to load them is then the module namespace followed by `.export_name`.

e.g. `some_lib.export_name`

Single/default exports are for libs that have a single entrypoint other than
`init.lua`. They are require-able by using the lib namespace. 

e.g. `export { 'file/other/than/init' }`

Named exports are for libs that want to expose several files like monorepos
with multiple utils in several files.

It is possible to require any file of a module by using the fully qualified
module name (usually in the form of `lib.some_dependency.path.to.file`).

## License

MIT © 2021 Willi Eßer 