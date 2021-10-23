mkdir -p ~/.lcm/current/

echo 'fetching latest lcm'
curl -u 'troublete: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' -sL 'https://github.com/troublete/lua-chunk-manager/tarball/master' > ~/.lcm/current.tar

echo 'extracting...'
tar -xzf ~/.lcm/current.tar -C ~/.lcm/current/
extracted=`ls ~/.lcm/current/ | head -1`

echo 'moving...'
cp -r ~/.lcm/current/$extracted/* ~/.lcm

echo 'cleaning...'
rm ~/.lcm/current.tar
rm -rf ~/.lcm/current

echo 'configuring shell...'
if ! cat /etc/profile | grep '# load lcm config'; then
	sudo bash -c "echo $'if [ -f ~/.lcm/sh-config ]; then\nsource ~/.lcm/sh-config # load lcm config\nfi' >> /etc/profile"
fi

source ~/.lcm/sh-config
echo 'setting up lcm for usage...'
cd ~/.lcm && lua lcm.lua init -g && lua lcm.lua install -g

echo $'done.\nYou might have to restart your terminal.'
