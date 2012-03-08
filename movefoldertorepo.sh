#!/bin/bash
# Created by: markusn
# Based on: http://stackoverflow.com/a/6638058
set -e

move_with_rename()
{
    echo "Using rename commit: $commit"
    echo "Using old folder name: $oldname"
    echo "....Press any key to start"
    read
    echo "Making a temporary rename branch from $commit"
    git branch rename "$commit"
    echo "Making a temporary pre-rename branch from rename~"
    git branch pre-rename rename~
    echo "Filter all commits up to rename, but not rename itself"
    git filter-branch --subdirectory-filter "$oldname" pre-rename
    echo "Add a graft, so our rename rev comes after the processed pre-rename revs"
    echo `git rev-parse rename` `git rev-parse pre-rename` >> .git/info/grafts
    echo "The first filter-branch left a refs backup directory. Move it away so the next filter-branch doesn't complain"
    mv .git/refs/original .git/refs/original0
    echo "Filter the rest"
    git filter-branch --subdirectory-filter "$name" "$branch" ^pre-rename
    echo "The graft is now baked into the branch, so we don't need it anymore"
    rm .git/info/grafts
}

move_wo_rename()
{
# needed: directory, branch
    echo "Doing a move without any renames due to insufficient info"
    echo "....Press any key to start"
    read
    git filter-branch --subdirectory-filter "$name" "$branch"
}

help()
{
    echo "help me daddy"
    exit
}

while getopts ":c:n:" opt;
do
    case "$opt" in
        c)  commit="$OPTARG";;
        n)  oldname="$OPTARG";;
        \?)# unknown flag
            echo >&2 \
                "usage: $0 [-c rename_commit_id] [-n old_name] [new_name]"
            exit 1;;
    esac
done
shift `expr $OPTIND - 1`

branch=`git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3`
name=$@

if [ -z "$branch" ] ; then
    echo "Does not seem to be a git repo... Exiting"
    exit 1
fi


if [ -z "$name" ] ; then
    echo "Need to specify a name"
    exit 1
fi

echo "Using branch: $branch"
echo "Using folder name: $name"

if ! [ -z "$commit" ] && ! [ -z "$oldname" ]; then
    move_with_rename
else
    move_wo_rename
fi;
echo "Done!"
echo "Don't forget to change your git remotes..."
exit 0