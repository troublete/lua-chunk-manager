# LCM

> The Lua Chunk Manager 

> General information
> As of now, this tooling is in 'beta' mode; the command API
> does not have any plans to be changed radically only additions are planned.
> As with everything though, faults and errors may arrise. The critical part
> though, being able to use loaded libraries, is stable and 'production ready'.
>
> In addition: The toolkit will not work on Windows, only if there is some kind
> of ?nix Environment available. This should change in the future though.

## About

The Lua Chunk Manager aims to be a simpler toolkit for reusing lua code as
dependencies and distributing lua code (as executable scripts, libs, ...).

I created this toolkit because i wanted to have simpler tooling for my own lua
and love2d project for managing requirements which does not depend on a
registry by default, since a lot of libs are just on Github. 

I am fully aware that there is a thing called **luarocks**, but i personally
prefer not to use it. The reasons for this are quite simple: i don't want to
depend on a registry and it is too lavish to create and publish new rocks for
simple purposes like sharing a chunk written in 5 minutes or quickly
distributing a lua script across a few machines.

## Demo

`chunkfile.lua` is the essential part that defines an projects exports,
requirements and executable exports. Therefore below an example with all of
them. But you only define what you need, no pressure to use all of them
always. And in fact if there is an `init.lua` you need no `chunkfile.lua` at
all, the loader will find your requirement.

Some more info:

- Requirements are installed 'recursively' so requirements requirements are
  loaded aswell

- Uniqueness of requirements is defined by their respective `namespaces` so
  multiple versions or even instances of the same lib can be used when named
  differently

- `namespaces` can contain `/` (to create nested directories) and will be
  converted to `.`-notation to be loadable

- LCM allows relative paths inside of libs; e.g. lets assume there is a lib
  with namespace `simple_lib`. For a file that is located in
  `*simple_lib_path*/src/main.lua` the require would be on lib root level
  `require('src.main')`. This is remapped to `lib.simple_lib.src.main` by the
  loader when used in scope of the project containing the `chunkfile.lua` and
  will resolve correctly

```lua
-- chunkfile.lua
-- for the demo assume that the library namespace is 'example'

-- EXPORTING --

-- for exposing some file as default export
-- but in reality there is no need for this export IF there is an `init.lua`.
export { 'relative_path/to/file.lua' }
-- will be the file returned when namespace is required: `require('example')`

-- for exposing some file as named export
export { 'relative/path/to/file.lua', 'additional'}
-- will be the file returned when namespace is required: `require('example.additional')`

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

-- adding requirement (applies to `symlink` aswell) with 'custom' namespace
-- (e.g. to allow multiple versions)
github { 'user/repo', namespace='other_name'}
-- can be loaded with: `require('other_name')`

-- adding requirement (applies to `github` aswell) with 'custom' env
-- (will only be installed with `lcm install` or `lcm install --env='dev'`)
symlink { 'simple_lib', '/local/path', env='dev' }

-- EXECUTABLES -- 

-- adding a executable in `bin` directory
bin { 'relative/file/path.lua' }
-- can be used when installed globally as `path`
-- can be used when installed locally as `./bin/path

-- adding a named executable in `bin` directory
bin { 'relative/file/path.lua', 'fancy_name' }
-- can be used when installed globally as `fancy_name`
-- can be used when installed locally as `./bin/fancy_name
```

```lua
-- example: test.lua
-- after running `lcm install` with the `chunkfile.lua` above
-- your project needs to require the 'autoloader' (located
-- in the `lib` directory, alongside the requirements)
-- then all requirements can be used

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
were installed 'globally' (see flag `--global`), including itself.

After installing it you shoud be able to run `lcm --help` and see the help
screen.

## Uninstall

To uninstall the toolkit run `rm -rf $LCM_HOME` and remove the lines below the
`# lcm-config` in `/etc/profile` (the instructions to load `sh-config`).

## Usage

If you want to use locally and globally installed dependencies you NEED to run
`require('lib.load')` in your entrypoint before requiring any library, except
the lua std lib. (see `lcm init` for info how to create a `lib/load.lua`)

There are several commands available to be run. Below a quick overview with
some common use-cases. For more info about flags etc. consult the
`lcm --help` screen.

All commands can be applied on the `LCM_HOME` (in global scope) when run with
flag `--global` or `-g`.

### `lcm init`

The `init` command initializes a new chunk. It runs idempotent. Without flags
it creates following structure.

```
.
├── chunkfile.lua # the chunk config, contains requirements; and exports
└── lib
    ├── load.lua # the loader, must be required before requiring anyting else; allows the usage of locally and globally installed dependencies
    └── map.lua # a helper map, which contains module load information after `lcm install`
```

If you only want to depend on globally installed libs, you can run `lcm
init --loader` and only create `/lib/load.lua`.

If you only want to create a chunk without a specific export file you do not
need to run init at all, as long as there is a `init.lua` your chunk will be
require-able.

If you want to create a named export and do not have any else requirements,
you can run `lcm init --chunkfile` and only create the chunkfile so you can
setup named exports.

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

### `lcm install`

Runs idempotent.

Installs requirements and requirements requirements in `lib`.
Writes executables to `bin`.

### `lcm clean`

Removes everything (dependencies, bins, config files, ...) when run without
flags. 

When you want to remove only the installed libs run with `--deps` flag.

When you want to remove only the created executables run with `--bin` flag.

### `lcm fix`

This command is a utility tool to fix your chunk setup. 

If run without flags it does nothing, so there is no default fix. 

If run with `--lib` flag, it cleans up `lib` directory and the `lib/map.lua`
file. It removes any library that is not listed in the `chunkfile.lua`
anymore. And rebuilds the `lib/map.lua` to include only available libraries.

### `lcm list`

List all installed modules. 

If you want to display all additional exports run with `--with-load`.

If you only want to display additional exports run with `--only-load`.

## Chunkfiles

As stated multiple times the `chunkfile.lua` is your basic chunk config.

Every `chunkfile.lua` is execute in a sandbox-ed environment; and only the
exposed LCM functionality is available. So there should be little
security problems.

It is quite tolerant though if there is any instruction added that the LCM
sandbox doesn't know it just ignores it.

## On exports

A lib can export one or multiple exports via the `chunkfile.lua`.

Every lib that should be requireable must have at least one default export.

No `chunkfile.lua` is needed though when an `init.lua` is available, which
will then serve as default export.

Provided `export` instructions must use a relative path.

Multiple exports must be defined via naming (hence named exports).
The name to load them is then the module namespace followed by `.export_name`.

e.g. `some_lib.export_name`

Single/default exports are for libs that have a single entrypoint other than
`init.lua`. They are require-able by using the lib namespace. 

e.g. `export { 'file/other/than/init' }`

Named exports are for libs that want to expose several files like monorepos
with multiple utils in several files.

e.g. `export { 'file/other/than/init', 'export one' }`

It is possible to require any file of a module by using the fully qualified
module name (usually in the form of `lib.some_dependency.path.to.file`).

## Prerequisits

- *NIX-System (built-in functions)
	- `test`
	- `mkdir`
	- `ls`
	- `curl`
	- `touch`
	- `cp`
	- `rm`
	- `echo`
	- `tar`
	- `mv`
- Lua

## Todo

- implement runtime cache
- clean up
- docs
- make windows able
- rebuild fs to use src.log
- make failure tolerant (install try every step, don't exit)
- allow "build" step in chunkfile, to allow creation of `*.so` libs
