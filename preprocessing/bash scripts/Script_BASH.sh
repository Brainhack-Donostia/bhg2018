#!/usr/bin/env bash

# This is not a real script. It is saved as such so that text editors (e.g. sublimetext) will highlight bash sintax
# If you copy/paste (ctrl+shift+C, ctrl+shift+V) things from here to the terminal, delete the indentation

##############################################
###       BASH Survival Crash Course       ###
##############################################
# Author: Stefano Moia

# Add a comment
# Yes, this is a comment. Maybe obvious, but still.


# move between folders
cd /path/to/fld
# move one level above
cd ..
# go home
cd ~
# move to Desktop (or language equivalent)
cd Desktop

# create a folder for the dataset and move in
mkdir Brainhack_fMRI

cd Brainhack_fMRI

# ask for HELP! (most of the commands will use this sintax for help)
cp --help #same as cp -h

# consult the manual (if you really need to...)
man cp

# copy one file from source to dest
cp /path/to/sourcefile.ext /path/to/dest.ext
# copy recursively from a source folder to "here"
cp -r /path/to/fld .
# copy all the non-folder content to here
cp /path/to/fld/* .

# move a file from source to dest
mv /path/to/sourcefile.ext /path/to/dest.ext
# move all the content (even folers) to here
mv /path/to/fld .

# create soft/symbolic links (useful to save space!)
ln -s /path/to/sourcefile.ext /path/to/softlink.ext # same with folders

# list files and folders
ls
# list files and folders, and save the output in a text file
# !!! really useful to create subjects' lists
ls > subjlist.txt
# list files and folders in readable format, also the hidden ones
ls -lah #same as ls -l -a -h
# list recursively (folder by folder)
ls -R




# create a variable
subjname=Brainhack

# create a variable with the output of a command
workdir=`pwd`

# create an array
anat_files=(uni inv1 inv2 T2w)

# create an array with the output of a command
folderlist=(`ls`)

# printing messages and variables
echo "Hello ${subjname}!"

echo ${workdir}

echo ${anat_files[@]}

echo ${folderlist[@]}

#### now some coding

echo "Here's where the fun starts"

# create a loop with numerical array
# it's not really "numerical": variables are all the same in BASH
for i in {1..5}
do
	echo ${i}
done

# create a loop with an array
for anat in ${anat_files[@]}
do
	# and an if instruction to match two strings
	if [ "${anat}" == "T2w" ]
		then
		echo "${anat} is a T2 weighted volume"
	else
		echo "${anat} is part of mp2rage"
	fi
done

# create a loop with a declared array
for i in this is another way to create loop arrays
do
	echo ${i}
done

# create a loop using a text file
# !! useful for subject loops !!
for subj in `cat subjlist.txt`
do
	echo ${subj}
done