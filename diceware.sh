#!/bin/sh
# Generate a passphrase using the diceware method but with 
# https://random.org/integers as source of random numbers.
#
# Use as "./diceware.sh n" for a passphrase of n words.
# No error handling implemented.
#
# http://world.std.com/~reinhold/diceware.html

# Command line argument
num_words=$1

# Number of integers (dice throws) to request 
n=$(($num_words*5))

# Get integers from random.org, note the use of https/ssl (no leaking here)
rolls=$(curl --silent "https://www.random.org/integers/?num=$n&min=1&max=6&col=1&base=10&format=plain&rnd=new") 

# Obtain a wordlist to choose words from [1]. 
wordlist_url="https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt"
words=$(curl --silent $wordlist_url)

# Number of dice rolls processed
m=0 

# Result of five rolls, e.g. 33246
s="" 

# Use rolls in sets of five to look up words
for r in $rolls; do
    # Increment the number of rolls processed
    m=$(($m+1)) 

    # Append the current roll to five-roll-result
    s=$s$r 

    # (m%5)==0 indicate s holds 5 integers and a word can be looked up
    if [ $(($m%5)) -eq 0 ]; then

       # Look up the word
       word=$(echo "$words" | grep $s) 

       # Reset s to an empty string
       s=""

       # Print the word (and five-roll-lookup-string also returned by grep)
       echo $word
    fi

done


# [1] Use any wordlist you so desire, as long as 'grep 54356 your-list.txt'
# will obtain the word corresponding to rolling 5, 4, 3, 5, 6.
# Other choices could be:
# Diceware wordlist: http://world.std.com/%7Ereinhold/diceware.wordlist.asc
# Beale's list: http://world.std.com/%7Ereinhold/beale.wordlist.asc
