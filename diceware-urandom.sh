#!/bin/sh
# Generate a passphrase using the diceware method but with 
# /dev/urandom as source of random numbers.
#
# Use as "./diceware-urandom.sh n" for a passphrase of n words.
# No error handling implemented.
#
# http://world.std.com/~reinhold/diceware.html


###################################################################### 
# Rolls a 6-sided die n times and prints the rolls. Cryptographically 
# secure since it relies on /dev/urandom for random bytes.
# 
# Arguments: $1, n, number of rolls to perform
# Returns: Prints the result of one roll per line
###################################################
roll()
{
    # Number of rolls to return
    n=$1

    # Number of rolls produced so far
    m=0

    # Draw random numbers in batches until n have been printed
    while [ $m -lt $n ]; do

        # Draw n-m random integers from /dev/urandom. Uniform on [0,255].
        xs=$(od -v -A n -N $(($n-$m)) -t u1 < /dev/urandom)
   
        # Process each random integer
        for x in $xs; do

            # Only x in [4,255] should be used since (255-3)%6 eq 0.
            # This ensures an unbiased mapping to [1,6].
            if [ $x -gt 3 ]; then

                # Increment the number of rolls produced
                m=$(($m+1))

                # Map to [1,6] and print 
                echo $((x%6 + 1))
                
                # Break if n rolls have been produced 
                if [ $m -eq $n ]; then
                    break
                fi
            fi
        done
    done
}

##########################################
# Main task/flow
##########################################

# Command line argument
num_words=$1

# Get num_words*5 integers (5 dice rolls per word)
n=$(($num_words*5))
rs=$(roll $n)

# Obtain a wordlist to choose words from [1]. 
wordlist_url="https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt"
words=$(curl --silent $wordlist_url)

# Number of dice rolls processed
m=0 

# Result of five rolls, e.g. 33246
s="" 

# Use rolls in sets of five to look up words
for r in $rs; do
    # Increment the number of rolls processed
    m=$(($m+1)) 

    # Append the current roll to five-roll-variable
    s=$s$r

    # (m%5)==0 indicate s holds 5 integers and a word can be looked up
    if [ $(($m%5)) -eq 0 ]; then

       # Look up the word
       word=$(echo "$words" | grep $s) 

       # Print the word (and five-roll-lookup-string also returned by grep)
       echo $word

       # Reset s to an empty string
       s=""
    fi
done


# [1] Use any wordlist you so desire, as long as 'grep 54356 your-list.txt'
# will obtain the word corresponding to rolling 5, 4, 3, 5, 6.
# Other choices could be:
# Diceware wordlist: http://world.std.com/%7Ereinhold/diceware.wordlist.asc
# Beale's list: http://world.std.com/%7Ereinhold/beale.wordlist.asc
