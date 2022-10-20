#! /bin/sh -ex

target=`mktemp -d --suffix _snapsync-install`
cd $target
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
    sed -i /opt/snapsync/systemd/snapsync-check-is-connection-unmetered.service \
        -e 's:/usr/lib/snapsync/:/opt/snapsync/usrlib/:'
    sudo cp /opt/snapsync/systemd/* /lib/systemd/system
    ( sudo systemctl enable snapsync-local.timer
      sudo systemctl enable snapsync-remote.timer)
fi

rm -rf $target
