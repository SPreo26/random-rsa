#modular exponentiation by right-to-left binary method
def mod_pow(base, power, mod)
  result = 1
  while power > 0
    result = (result * base) % mod if power & 1 == 1
    base = (base * base) % mod
    power >>= 1;
  end
  result
end


def str_to_bignum(s)
  n = 0
  s.each_byte{|b|n=n*256+b}
  n
end

def bignum_to_str(n)
  s=""
  while n>0
    s = (n&0xff).chr + s
    n >>= 8
  end
  s
end

#NOTE! For demo purposes, using the Miller-Rabin primality test - quicker than the native ruby prime? method (though not 100% accurate)
class Integer
  def prime?n = self.abs()
    return true if n == 2
    return false if n == 1 || n & 1 == 0
    return false if n > 3 && n % 6 != 1 && n % 6 != 5
    d = n-1
    d >>= 1 while d & 1 == 0
    1000.times do #k = 1000 (accuracy factor)
      a = rand(n-2) + 1
      t = d
      y = mod_pow(a,t,n)
        while t != n-1 && y != 1 && y != n-1
          y = (y * y) % n
          t <<= 1
        end
      return false if y != n-1 && t & 1 == 0
    end
    return true
  end
end

#generate random numbers until a prime is found
def create_random_prime(prime_size, num_blocks)
  block_size = prime_size-3 #see exanation where str is assigned a value below
  while true
    counter = 0

    while counter<=API_CALL_LIMIT
      rand_int_string = Unirest.get("https://www.random.org/integers/?num=#{(block_size)*num_blocks}&min=0&max=1&col=1&base=2&format=plain&rnd=new").body
      rand_int_arrays = rand_int_string.split("\n").each_slice(block_size).to_a

      rand_int_arrays.each_with_index do |rand_int_array,index|
        str = "11" + rand_int_array.join("") + "1"
        #set the highest 2 bits to satisfy bit that n, the product of p and q, will be sufficiently large; 
        #set lowest bit to make p or q always an odd number (to increase the likelyhood of finding a prime by trial and error)
        val = str.to_i(2)
        #puts "counter #{counter}"
        #puts "index #{index}"
        #p rand_int_array
        return val if val.prime?
      end
      counter += 1
      puts "Sleeping for #{SLEEP_SECODNS_BETWEEN_API_CALLS} seconds between each API call..."
      sleep SLEEP_SECODNS_BETWEEN_API_CALLS    
    end

    if SLEEP_AFTER_API_LIMIT
      puts "Sleeping for #{SLEEP_SECONDS_ON_API_LIMIT} seconds: only #{API_CALL_LIMIT} API calls at a time will be made..."
      sleep SLEEP_SECONDS_ON_API_LIMIT
    else
      raise "Exiting after #{API_CALL_LIMIT*num_blocks} unsuccessful attempts to generate a prime number"
    end
  end
  
end

# def create_random_bignum(bits)
#   middle = (1..bits-3).map{rand()>0.5 ? '1':'0'}.join
#   str = "11" + middle + "1"
#   str.to_i(2)
# end

# #Create random numbers until it finds a prime
# def create_random_prime(bits, num_blocks)
#   counter = 0
#   while true
#     val = create_random_bignum(bits)
#     counter+=1
#     puts "attempt #{counter}"
#     return val if val.prime?
#   end
# end

#Solve the extended euclidean algorithm: ax + by = gcd(a,b)
def extended_gcd(a, b)
  return [0,1] if a % b == 0
  x,y = extended_gcd(b, a % b)
  [y, x-y*(a / b)]
end

#Get the modular multiplicative inverse of a modulo b: a^-1 equiv x (mod m)
def get_d(p,q,e)
  phi = (p-1)*(q-1)
  x,y = extended_gcd(e,phi)
  x += phi if x<0
  x
end