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

    def env
      defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : 'development'
    end

    def config
      @config ||= initialize_config
    end

    def initialize_config
      raise "#{YAML_CONFIG_FILE} should exist on production environment" if
        env == 'production' && !File.exist?(YAML_CONFIG_FILE)
      hash = YAML.load_file(YAML_CONFIG_FILE) rescue { :key => 'secret' }
      Config.new(hash)
    end
  end

  module ClassMethods
    def attr_encryptor *attrs
      attrs.each do |attr|
        define_method("#{attr}=") { |v| self.send "#{attr}_encrypted=", AttrEncryptor.aes.encrypt(v) }
        define_method(attr) { AttrEncryptor.aes.decrypt(self.send "#{attr}_encrypted") }
      end
    end
  end
end
