if [ -z $LCM_HOME ]; then
	LCM_HOME=$HOME/.lcm/
fi

mkdir -p $LCM_HOME/current/

echo 'fetching latest lcm'
curl -u 'troublete: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' -sL 'https://github.com/troublete/lua-chunk-manager/tarball/master' > $LCM_HOME/current.tar



echo 'extracting...'
tar -xzf $LCM_HOME/current.tar -C $LCM_HOME/current/
extracted=`ls $LCM_HOME/current/ | head -1`

echo 'moving...'
cp -r $LCM_HOME/current/$extracted/* $LCM_HOME

echo 'cleaning...'
rm $LCM_HOME/current.tar
rm -rf $LCM_HOME/current

echo 'configuring shell...'
if ! cat /etc/profile | grep '# load lcm config'; then
	sudo bash -c "echo $'\nLCM_HOME=$LCM_HOME\nif [ -f $LCM_HOME/sh-config ]; then\nsource $LCM_HOME/sh-config # load lcm config\nfi' >> /etc/profile"
fi

source $LCM_HOME/sh-config
echo 'setting up lcm for usage...'
lua $LCM_HOME/lcm.lua init -g && lua $LCM_Home/lcm.lua install -g

echo $'done.\nYou might have to restart your terminal.'
