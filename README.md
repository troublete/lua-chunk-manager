# LCM

> Lua Chunk Manager 

## About

The Lua Chunk Manager aims to be a simpler toolkit for reusing lua chunks
(as dependencies) and distributing lua code (as scripts, libs, ...).

I created this tool because i wanted to have a simpler tooling for my own lua
and love2d projects. I am fully aware that there is a thing
called **luarocks**; but i personally prefer not to use it. The reasons for
this are quite simple: i don't want to depend on a registry and it is too
lavish to create rocks for simple purposes like sharing a chunk written in 5
minutes or quickly distributing a lua script across a few computers.

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

- implement toolkit for +register_strategy+ to use (e.g. check if directory
  exists, create dir, execute download)
- implement runtime cache
- implement 'add' command
- implement direct install when within lib and hit lcm install
- implement 'init lib mode' (omit loader and map and lib)
- allow import with alias (to allow multi version, etc)
- clean up
- docs