#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

# Set your folder with the pics
defaultfolder=~/Pictures/wallpapers/
picsfolder=${1:-$defaultfolder}

#What is your current pic?
dconf read /org/cinnamon/desktop/background/picture-uri

#delete current pic
currentpic=$(dconf read /org/cinnamon/desktop/background/picture-uri | sed s+file://++ | sed "s/'//g")

echo "deleting $currentpic"

rm "$currentpic" || true

# Go to your folder with the pics
cd $picsfolder

# Create an array of the files
files=(./*)

# Get the size of the array
N=${#files[@]}

# Select a random number between this range
((N=RANDOM%N))

# Get the name of this file
# a bit overly complicated. basically it takes the Nth string from files ${files[$N]}, and then removes the first two letters which is the "./" at the beginning 
randomfile=`echo ${files[$N]} | cut --characters="1 2" --complement`

echo "Setting wallpaper to: file://$picsfolder$randomfile"

# set the desktop
dconf write "/org/cinnamon/desktop/background/picture-uri" "'file://$picsfolder$randomfile'"

echo `ls $picsfolder | wc -l` wallpapers left.

