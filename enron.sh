#!/bin/bash
#
# file: enron.sh
#
# description: trains a simple one-word naive bayes spam
# filter using enron email data
#
# usage: ./enron.sh <word>
#
# requirements:
#   wget
#
# author: jake hofman (gmail: jhofman)
# modified by everet
#

# how to use the code
if [[ $# -eq 1 ]]
    then
    word=$1
else
    echo "usage: enron.sh <word>"
    exit
fi

# if the file doesn't exist, download from web
if ! [[ -e enron1.tar.gz ]]
    then
    wget 'http://www.aueb.gr/users/ion/data/enron-spam/preprocessed/enron1.tar.gz'
fi

#if the directory doesn't exist, uncompress the .tar.gz
if ! [[ -d enron1 ]]
    then
    tar zxvf enron1.tar.gz
fi

# change into enron1
cd enron1

# get counts of total spam, ham, and overall msgs
Nspam=$(ls -l spam/*.txt | wc -l)
Nham=$(ls -l ham/*.txt | wc -l)
let Ntot=$Nspam+$Nham # holy crap! dds has an annoying typo: 'let ' omitted.

echo $Nspam spam examples
echo $Nham ham examples

# get counts containing word in spam and ham classes
Nword_spam=$(grep -il $word spam/*.txt | wc -l)
Nword_ham=$(grep -il $word ham/*.txt | wc -l)

echo $Nword_spam "spam examples containing $word"
echo $Nword_ham "ham examples containing $word"

# calculate probabilities using bash calculator "bc"
Pspam=$(echo "scale=4; $Nspam / $Ntot" | bc)
Pham=$(echo "scale=4; 1 - $Pspam" | bc)
echo
echo "estimated P(spam) =" $Pspam
echo "estimated P(ham) =" $Pham

Pspam_word=$(echo "scale=4; $Nword_spam * $Pspam" | bc)
Pham_word=$(echo "scale=4; $Nword_ham * $Pham" | bc)
Pword=$(echo "scale=4; $Pspam_word + $Pham_word" | bc)
Pspam_word=$(echo "scale=4; $Pspam_word / $Pword" | bc)
echo
echo "P(spam|$word) =" $Pspam_word

# return original directory
cd ..
