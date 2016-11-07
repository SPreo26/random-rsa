require 'unirest' #IF UNIREST GEM IS NOT PRESENT on your machine: run $gem install unirest
require_relative 'random_rsa_helpers'

ENCRYPTION_BITS = 1024
NUM_BLOCKS = 19 #each Random.com API call will return this many blocks of random canditates for primes at a time
#this is done not to overload Random's API according to their guidelines
#each block is ENCRYPTION_BITS-3 long
#NOTE: maximum random number length for Random.com API is 10000; eg. ENCRYPTION_BITS = 1024 will result in NUM_BLOCKS being no more than 10000/(1024/2).floor == 19

SLEEP_SECODNS_BETWEEN_API_CALLS = 1 #sleep this long between each API call
API_CALL_LIMIT = 10 #must give up and try again later after this many calls to Random.com API not to violate their guidelines
SLEEP_AFTER_API_LIMIT = true #when API_CALL_LIMIT reached: if true, will sleep for SLEEP_SECONDS_ON_API_LIMIT; if false, then raise error
SLEEP_SECONDS_ON_API_LIMIT = 10 

e = 65537
puts "Generating primes..."
p_size = ENCRYPTION_BITS/2
p = create_random_prime(p_size,NUM_BLOCKS)
q = create_random_prime(p_size,NUM_BLOCKS)
n = p*q
d = get_d(p,q,e)
puts "n (public RSA key): #{n}"
puts "d (private RSA key): #{d}"
puts "e (public exponent): #{e}"

puts "\nDemonstrating RSA pair with message. \nNote: for this demo practical techniques like padding the message and digital signing are omitted."
message = "Never eat yellow snow!"
puts "\nmessage to encode is:\n#{message}\n"
m = str_to_bignum("Never eat yellow snow!")
c = mod_pow(m,e,n)
puts "\ncipher is:\n#{c}\n"
m = mod_pow(c,d,n)
message = bignum_to_str(m)
puts "\ndecoded message is:\n#{message}\n"
puts "Note: there's a small chance the message may not be decoded if the quicker Miller-Rabin primality test used returns a false positive"