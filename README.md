# Generate passphrases using the Diceware method from the shell
(Don't know what Diceware is? Read here: http://world.std.com/%7Ereinhold/diceware.html)

I was tired of rolling physical dice and doing manual lookups
to generate my passphrases using the diceware method,
but also reluctant to use third party (mostly web) services. 

The original diceware idea by A. Reinhold is so simple 
it feels like overkill to use 100+ lines of a modern
high-level language to replicate. 
Also, such implementations are often quite convoluted
(or opaque if open-source software can said to be opaque);
what is the source of the random integers
and which wordlist is used?
Especially if the implementation
is spread across multiple files.

The following two shell scripts are short,
explicit about the source of random numbers
and wordlists.


## diceware.sh
Relies on a POSIX compliant shell,
and utilities grep and curl.

No error-handling, 
https://random.org/integers for random integers,
and a hardcoded wordlist URL
(i.e. to change wordlist or wordlist language edit the script).

Relatively slow because it relies on a webservice for random numbers,
exec. time ~1s for 4-10 word passphrases.

### Usage:
`diceware.sh n`

where `n` is the number of words you want in your passphrase.

## diceware-urandom.sh
The same as diceware.sh except it uses `od` to obtain
random integers from `/dev/urandom` instead of relying on
https://random.org/integers.

Still no error-handling and still hardcoded wordlist URL.

Quicker because of the elimated http request to get random integers,
exec. time ~0.2s for 4-10 word passphrases.

Cooler because the random integers are generated from
random bytes from your own private source (`/dev/urandom`) 
with `od` utility and a modulo operation.

### Usage:
`diceware-urandom.sh n`

where `n` is the number of words you want in your passphrase.

## TODO / Other notes
### Error handling
Maybe handle a few errors and show usage message on wrong invocation.

### Local wordlist
Elimate the http request to obtain a wordlist by using a local 
list, maybe a signed one which can be authenticated.
Of course then the script needs to be signed as well to avoid
tampering ...

