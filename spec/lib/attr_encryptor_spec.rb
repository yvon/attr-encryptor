require "./lib/attr_encryptor"

describe AttrEncryptor do
  it { should respond_to :config }

  describe "#config" do
    subject { AttrEncryptor.method :config }
    before  { AttrEncryptor.instance_variable_set :@config, nil }

    it "should be initialized once and for all" do
      subject.call == subject.call
    end

    it "should return an AttrEncryptor::Config" do
      subject.call.should be_an AttrEncryptor::Config
    end

    it "should load yaml configuration file" do
      YAML.should_receive(:load_file).with(AttrEncryptor::YAML_CONFIG_FILE).and_return Hash.new
      subject.call
    end

    it "should raise on production environment if the YAML does not exist" do
      AttrEncryptor.stub(:env).and_return('production')
      expect { subject.call }.to raise_error
    end
  end

  describe "when included" do
    before do
      @class = Class.new do
        include AttrEncryptor
        attr_accessor :foo_encrypted, :bar_encrypted
        attr_encrypted :foo, :bar
      end
    end

    it "should encrypt and decrypt without data loss" do
      object_1, object_2 = @class.new, @class.new
      object_1.foo = plain = 'test'
      object_1.foo_encrypted.should_not == plain
      object_2.foo_encrypted = object_1.foo_encrypted
      object_2.foo.should == plain
    end
  end
end
