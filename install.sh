if [ -z $LCM_HOME ]; then
	LCM_HOME=$HOME/.lcm/
fi

echo "running for $LCM_HOME"

mkdir -p $LCM_HOME/current/

echo 'fetching latest lcm'
curl -sL 'https://github.com/troublete/lua-chunk-manager/tarball/master' > $LCM_HOME/current.tar

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
	sudo bash -c "echo $'\n# lcm-config\nLCM_HOME=$LCM_HOME\nif [ -f $LCM_HOME/sh-config ]; then\nsource $LCM_HOME/sh-config # load lcm config\nfi' >> /etc/profile"
fi

source $LCM_HOME/sh-config
echo 'setting up lcm for usage...'
cd $LCM_HOME && lua lcm.lua init && lua lcm.lua install
cd $LCM_HOME && cp bin/lcm.tpl.txt bin/lcm && sed -i '' "s/%runtime%/lua/;s#%path%#$PWD#;s#%file%#$PWD/lcm.lua#" bin/lcm
chmod +x $LCM_HOME/bin/lcm

echo $'done.\nYou might have to restart your terminal.'
