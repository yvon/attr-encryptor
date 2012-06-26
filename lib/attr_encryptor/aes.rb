require 'digest/sha1'
require 'openssl'
require 'base64'

module AttrEncryptor
  class AES
    Type = "AES-256-CBC"

    def initialize(pass, cipher_type = Type)
      @aes = ::OpenSSL::Cipher::Cipher.new(cipher_type)
      @aes.padding = 1
      @key = Digest::SHA1.hexdigest(pass).unpack('a2' * 32).map{ |x| x.hex }.pack('c' * 32)
    end

    def encrypt(data)
      @aes.encrypt
      @aes.key = @key
      @aes.update(data) + @aes.final
    end

    def decrypt(data)
      @aes.decrypt
      @aes.key = @key
      @aes.update(data) + @aes.final
    end
  end
end
