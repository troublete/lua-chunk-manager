# LCM

> The Lua Chunk Manager 

## About

The Lua Chunk Manager aims to be a simpler toolkit for reusing lua code chunks
(as dependencies) and distributing lua code (as executable scripts,
libs, ...).

I created this toolkit because i wanted to have simpler tooling for my own lua
and love2d project for managing requirements which does not depend on a
registry by default, since a lot of libs are simply on Github. So initially
there are two strategies for adding requirements: `github` and `symlink`.

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
all, the 'autoloader' will find your requirement.

Some more info:

- Requirements are installed 'recursively', so requirements requirements are
  loaded aswell; unless they are already available.

- Uniqueness of requirements is defined by their respective `namespaces`, so
  multiple versions or even instances of the same lib can be used, when named
  differently.

- `namespaces` can contain `/` (to create nested directories) and will be
  converted to `.`-notation to be loadable.

- LCM allows relative paths inside of libs; lets assume there is a lib with
  namespace `simple_lib`. Lets say for a file that is located in
  `*simple_lib_path*/src/main.lua`, the require would be on root level `require
  ('src.main')`; this is remapped to `lib.simple_lib.src.main` by the
  autoloader when used in scope of the project containing the `chunkfile.lua`
  and will resolve correctly.

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
location; you setting a new location beforehand
(`LCM_HOME=*your/path/of/chosing*`). 

The `LCM_HOME` contains all system wide available scripts and libraries that
were installed 'globally' (see flag `--global`), including itself.

After installing it you shoud be able to run `lcm --help` and see the help
screen.

## Uninstall

To uninstall the toolkit run `rm -rf $LCM_HOME` and remove the lines below the
`# lcm-config` in `/etc/profile` (the instructions to load `sh-config`).












## Chunkfiles

A `chunkfile.lua` is the essential part of defining exports and dependencies,
but they are optional if you want to require an existing library which simply
does not have a `chunkfile.lua` the loader will still find it by the handle
provided.

Every `chunkfile.lua` is execute in a sandbox-ed environment; and only the
exposed LCM functionality is available. So there should be little
security problems.

### Using a chunk/library/repo/...

- handle in strategy is converted to '.'-notation
- require `lib.load`; then require everything you want
- github
	- public/private
	- named => multiversion
- explain add (also PWD install (lcm add symlink:namespace,$PWD))

### Exposing a chunk/library/repo/...

- export without chunkfile
- single export with `export{file_path}`
- multi export with `export{file_path,name}`

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

## How to create a `chunkfile.lua`


## Todo

- implement runtime cache
- clean up
- docs
- make windows able
- rebuild fs to use src.log
- make failure tolerant (install try every step, don't exit)
- allow "build" step in chunkfile, to allow creation of `*.so` libs
