describe AttrEncryptor::Config do
  describe "instance" do
    let(:hash) { { :key => 'secret', :foo => { :bar => :baz } } }
    subject    { AttrEncryptor::Config.new(hash) }

    it { should respond_to :key }
    its(:key) { should == 'secret' }

    it "should support nested config objects" do
      subject.foo.bar.should == :baz
    end
  end
end
