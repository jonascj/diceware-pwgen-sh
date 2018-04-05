#!/bin/sh
# Generate a diceware passphrase using https://random.org/integers
# as source of random numbers, a posix shell, curl, and grep.
#
# Use as "diceware.sh n" for a passphrase of n words.
# No error handling implemented.

num_words=$1

# Number of integers (dice throws) to request 
n=$(($num_words*5))

# Get integers from random.org (note https / ssl)
# Note the use of https/ssl, no leaking here
throws=$(curl --silent "https://www.random.org/integers/?num=$n&min=1&max=6&col=1&base=10&format=plain&rnd=new") 

# Obtain a wordlist to choose words from
# Use any you like, as long as it has format
# 11111    apple 
# 11112    pear
# Here I've used EFF's from 2016 which I much prefer
wordlist_url="https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt"
words=$(curl --silent $wordlist_url)

# Number of dice rolls processed
m=0 

# Variable for holding five dice rolls, e.g. 33246
s="" 

for t in $throws; do
    # One more roll processed
    m=$(($m+1)) 

    # Append the current roll to five-roll-variable
    s=$s$t 

    # (m mod 5) equal to zero indicate s holds 5 integers
    # and a word can be looked up
    if [ $(($m%5)) -eq 0 ]; then

       # Look up the word
       word=$(echo "$words" | grep $s) 

       # Reset s to an empty string
       s=""

       # Print the word
       echo $word
    fi

done
