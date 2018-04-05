#!/bin/sh
# Generate a diceware passphrase using /dev/urandom as source
# of random numbers, a posix shell, curl, od and grep.
#
# Use as "diceware-urandom.sh n" for a passphrase of n words.
# No error handling implemented.
#
# Credit to https://serverfault.com/a/718202 for the idea of 
# using the 'od' util to format bytes from /dev/urandom.


###################################################
# Rolls a 6-sided die n times and prints a list of 
# number of dots "shown". Cryptographically secure 
# because it uses /dev/urandom unbiased to obtain
# integers for the rolls.
# 
# Arguments: 
#   $1, n, number of rolls to perform
# Returns:
#   Prints the number of dots for each role
#   on seperate lines.
###################################################
roll()
{
    # Number of rolls to return
    n=$1

    # Number of rolls produced so far
    m=0

    # Draw random numbers in batches until n have been printed
    while [ $m -lt $n ]; do

        # Draw n-m random integers from /dev/urandom
        # These are uniformly distributed over [0,255]
        xs=$(od -v -A n -N $(($n-$m)) -t u1 < /dev/urandom)
   
        # Process each random integer
        for x in $xs; do

            # Only x in [4,255] should be used since (255-3)%6 eq 0.
            # This ensures an unbiased mapping to [1,6].
            if [ $x -gt 3 ]; then

                # Increment the number of rolls produced
                m=$(($m+1))

                # Map to [1,6] and output
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

# Argument: number of words in passphrase 
num_words=$1

# Get num_words*5 integers (5 dice rolls per word)
n=$(($num_words*5))
rs=$(roll $n)

# Obtain a wordlist to choose words from
# Use any you like, as long as it has format
# 11111    apple 
# 11112    pear
# Here I've used EFF's from 2016 which I much prefer
wordlist_url="https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt"
words=$(curl --silent $wordlist_url)

# Number of dice rolls processed so far
m=0 

# String holding number of dots shown for five rolls, 
# e.g. 33246, used for lookup in the wordlist.
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

       # Print the word (and five-roll-lookup-string)
       echo $word

       # Reset s to an empty string
       s=""
    fi
done
