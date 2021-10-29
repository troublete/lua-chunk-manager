## 1. define requirement in chunkfile

```lua
-- chunkfile.lua
local lrandom = tar(
  {
    'lrandom',
    'http://webserver2.tecgraf.puc-rio.br/~lhf/ftp/lua/ar/lrandom-100.tar.gz',
    include_path=true -- include the lib directory in the search path; so the extension can be loaded with simple module name
  }
)

-- run post install; run make in lib directory
lrandom:post_install(function(exec, path)
  exec('cd ' .. path .. ' && make')
end)
```

## 2. run `lcm install`
```bash
lcm i 
```

## 3. use lib

```lua
-- test.lua

require('lib.load') -- this is necessary so the +include_path+ param takes effect
local random = require('random') -- this loads the extension

...
```