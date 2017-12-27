#! /bin/bash

## Bash is learning a new language
## What is a computer?
## What differentiates a server from your laptop?
## What are computers good at?
## What are they not good at?
## How does that play into the ubiquity of command line tools?

## Log into the server:
## If you were making a program to log people onto a remote server
## what would you need to know to do that?

ssh username@ron.sr.unh.edu

## Anatomy of a command
## command - ssh
## argument - username@ron.sr.unh.edu

## Sometimes commands don't need arguments.
cal
pwd
echo
## And most of the time the arguments are optional
echo Hello World!

## What does echo do?
## How many arguments?
## what will the output of:
echo Hello                  World!
## look like?  Why?

cal
cal -3j
cal -j3

#What is weird about 1752?  How can you tell?
man cal
whatis cal
## google "bash cal"

## Let's talk about paths!
## Folders and files
## What is the structure like?  Tree analogy
## root, relative vs absolute paths
## When should you use which?
tree
## Where are we?
## . .. ~ -
pwd

cd
cd example_assembly
## Where are you know?
## What are some ways you could get back to your home directory?
## How about to the example reads directory?

ls -lah
## what are the options?  What does ls do?

## Move copy and delete:
cd
mkdir sandbox
cd sandbox
cp -r ~/example_assembly .
cd example_assembly
ls -lh
mv quast_report/report.txt .
less report.txt
## That's lame, let's spruce those results up a bit!
nano report.txt
head report.txt
## What's the opposite of head?
tail report.txt
tail -20 report.txt
## What advantages does less have over editors like nano?
grep l report.txt
grep -i l report.txt
grep -v l report.txt
cd ../prokka_report
grep -v hypothetical *.faa
grep -v hypothetical *.faa | grep ">" | less  ## quotes are very important!!!
## anyone got a favorite protein?

## Rant about scripting and reproducibility of results...

## That was generic and "relatively" unchanged since the dawn of time (1980s)
## The rest is not, and will probably change lots.
