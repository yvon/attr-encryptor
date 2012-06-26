module AttrEncryptor
  class Config
    def initialize(hash)
      hash.each do |k, v|
        v = Config.new(v) if v.is_a?(Hash)
        self.define_singleton_method(k) { v }
      end
    end
  end
end
