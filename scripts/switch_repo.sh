#!/bin/bash
cd $HOME/projects/
for i in *
do
  if [ -f "${i}/.git/config" ]; then
    perl -pi -e "s/irvsrddev4.flight/np145.wc1/g" "${i}/.git/config"
  fi
done
