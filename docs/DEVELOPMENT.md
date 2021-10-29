# Development 

> a general guidance for developing for LCM

## Strategies

see `src/strategies.lua`

Contains all the strategies available a chunkfile can contain to fetch
requirements. Methods which define what a package can export are to be found
in `cmd/install.lua`. 

For adding a strategy consider, that it must return the namespace of the
dependency installed. See other strategies for reference. In the most cases
this should be something like `/absolute/path/to/lib/*namespace*/`.