-- A new chunkfile.
-- Thank you for choosing LCM! 
-- 
-- to expose a chunk use following syntax:
--
--		export { 'chunk/handle', 'relative/path/to/module.lua' }
--
-- to require your chunk use following built-in strategies (or create a PR with a new one):
--
-- GITHUB (public)
--
-- 		github { 'troublete/chunk' }
--
-- GITHUB (private)
--
-- 		github_private { 'troublete/chunk', 'username:access_token' }
-- 
-- SYMLINK
--
-- 		symlink { 'name', '/path/to/local/lib' }