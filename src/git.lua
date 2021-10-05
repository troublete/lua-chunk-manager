local git = {}

function git.clone(repository_url, target_directory)
	if os.execute('git clone ' .. repository_url .. ' ' .. target_directory) then
		return true
	else
		return false
	end
end

return git