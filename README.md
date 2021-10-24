# LCM

> The Lua Chunk Manager 

## About

The Lua Chunk Manager aims to be a simpler toolkit for reusing lua code chunks
(as dependencies/libs) and distributing lua code (as executable scripts,
libs, ...).

I created this toolkit because i wanted to have a simpler tooling for my own
lua and love2d projects, which is not really dependent on the fact that some
piece of code is published somewhere. For the start i added two simple
strategies to fetch requirements `github` and local `symlink` (read more
about it in the `chunkfile` section).

I am fully aware that there is a thing called **luarocks**, but i personally
prefer not to use it. The reasons for this are quite simple: i don't want to
depend on a registry and it is too lavish to create and publish new rocks for
simple purposes like sharing a chunk written in 5 minutes or quickly
distributing a lua script across a few machines.

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
were installed 'globally', including itself.

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
