# encoding: UTF-8

require 'yaml'
require 'attr_encryptor/config'
require 'attr_encryptor/aes'

module AttrEncryptor
  YAML_CONFIG_FILE = '../config/attr_encryptor.yaml'

  class << self
    def included(klass)
      klass.extend ClassMethods
    end

    def aes
      @aes ||= AES.new(config.key)
    end

    def config= hash
      @hash_config = hash
    end

    def config
      @config ||= initialize_config
    end

    def initialize_config
      unless @hash_config
        puts "No configuration provided. Using defaults."
        @hash_config = { :key => 'secret' }
      end
      Config.new(@hash_config)
    end
  end

  module ClassMethods
    def attr_encryptor *attrs
      attrs.each do |attr|
        define_method("#{attr}=") do |v|
          serialized = YAML::dump(v)
          self.send "#{attr}_encrypted=", [AttrEncryptor.aes.encrypt(serialized)].pack('m')
        end
        define_method(attr) do
          return nil unless self.send("#{attr}_encrypted").is_a?(String)
          YAML::load(AttrEncryptor.aes.decrypt(self.send("#{attr}_encrypted").unpack('m')[0]))
        end
      end
    end
  end
end
