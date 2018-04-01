#!/bin/sh
# Generate a diceware passphrase using https://random.org/integers
# as source of random numbers, a posix shell, curl, and grep.
#
# Use as "diceware.sh n" for a passphrase of n words.
# No error handling implemented.

# Only argument is number of words (no error checking)
num_words=$1

# Number of integers (dice throws) to request 
n=$(($num_words*5))

# Get integers from random.org (note https / ssl)
# Note the use of https/ssl, no leaking here
throws=$(curl --silent "https://www.random.org/integers/?num=$n&min=1&max=6&col=1&base=10&format=plain&rnd=new") 

# Get the wordlist
words=$(curl --silent "http://world.std.com/%7Ereinhold/beale.wordlist.asc")


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

