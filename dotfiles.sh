#!/usr/bin/env bash

# files to exclude
excluded=". .. .git .gitignore .gitmodules"

# update submodules
echo "updating external dependencies"
git submodule update --init
echo "...done"

# do special symlinks
if [ -f ./specialdotfiles ]; then
    echo "creating special symlinks"
    . ./specialdotfiles
    echo "...done"
else
    echo "no special symlinks to create"
fi

# do symlinks
echo "creating symlinks"
for file in .*
do
    for ex in $excluded
    do
        if [ "$file" = "$ex" ]
        then
            continue 2
        fi
    done
    echo "Creating symlink to $file in $HOME"
    ln -f -n -s $PWD/$file $HOME/$file
done
echo "...done"
