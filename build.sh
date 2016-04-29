#!/bin/bash

export BUILDROOT=`pwd`/build
mkdir -p $BUILDROOT
LOG=$BUILDROOT/build.log
rm -f $LOG
set -e  # Abort on error

# Install node_modules
if [ ! -d node_modules ]
then
    echo "installing modules ..." && (cd src && npm install) >> $LOG || (echo "module install FAILED" && exit 2)
fi

# Create soft-link: node_modules
if [ ! -L src/node_modules ]
then
    (cd src && ln -s ../node_modules node_modules)
fi

# Create soft-link: package.json
if [ ! -L src/package.json ]
then
    (cd src && ln -s ../package.json package.json)
fi

echo "building src ..." && (cd src && grunt) >> $LOG || (echo "build failed" && exit 1)
echo "build complete !!!"
exit 0
# END
