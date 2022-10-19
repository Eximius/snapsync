#! /bin/sh -ex

target=`mktemp -d --suffix _snapsync-install`
cd $target
echo "$target"
cat > Gemfile <<GEMFILE
source "https://rubygems.org"
gem 'snapsync'
GEMFILE

bundler install --standalone --binstubs
if test -d /opt/snapsync; then
    sudo rm -rf /opt/snapsync
fi
sudo cp -r . /opt/snapsync
sudo chmod go+rX /opt/snapsync

if test -d /lib/systemd/system; then
    snapsync_gem=`bundler show snapsync`
    sudo ln -s $snapsync_gem/snapsync.service $snapsync_gem/snapsync.timer /lib/systemd/system
    ( sudo systemctl stop snapsync.timer
      sudo systemctl enable snapsync.timer
      sudo systemctl start snapsync.timer )
fi

rm -rf $target
