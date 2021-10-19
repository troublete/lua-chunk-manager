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

A `chunkfile.lua` is the essential part of any piece of code which shall be
importable. It is a configuration which defines in easy commands what the
chunk requires and what it exposes. 

Every `chunkfile.lua` is execute in a sandbox-ed environment; and only the
exposed functions by the LCM are available. So there should be little
security problems.

The minimum content of a `chunkfile.lua`; is one `expose` definition.

```lua
-- `expose` defines an module export of the chunk; exports are crucial – without any exports,
-- the library can not be used in any way, shape or form

expose { 'my/library', 'relative/path/to/entrypoint.lua' }

-- it is also possible to omit the path; then this happens it is assumed that an `init.lua` file is present
-- in the directory root (which is consistent with the workings of the lua searchers)

expose { 'my/other/lib' }

-- when your piece of code depends on several other chunks it is possible
-- to require them by using the following commands as much as needed
--
-- with `github` it is possible to require a library from github; only the handle is required

github { 'troublete/lua-chunk-manager' }

-- with `github_private` it is possible to require a private repo from github; handle and user are required

github_private { 'troublete/lua-chunk-manager', 'username:api_token' }

-- if u have a local lib or want to test you lib locally use `symlink`; handle and absolute path are required
-- it is to be noted, that all FILES are symlinked not the directory set

symlink { 'local/lib', '/absolute/path/to/lib/' }
```

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

- allow pathless exports
- implement toolkit for +register_strategy+ to use (e.g. check if directory
  exists, create dir, execute download)
- implement "bin" install
- implement "global" install and reuse