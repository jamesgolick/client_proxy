require "spec_helper"

describe "ClientProxy" do
  before do
    @client_factory = stub("ClientFactory")
    @host1          = stub("Client(host1)", :do_something => true)
    @host2          = stub("Client(host2)", :do_something => true)
    @client_factory.stubs(:create).with("host1:6379").returns(@host1)
    @client_factory.stubs(:create).with("host2:6379").returns(@host2)
    @client_proxy   = ClientProxy.new(@client_factory,
                                      ["host1:6379", "host2:6379"],
                                      [RuntimeError],
                                      3)
  end

  describe "when a request succeeds" do
    it "tries the first host" do
      @client_proxy.do_something.should == true
      @host1.should have_received(:do_something)
    end
  end

  describe "when a request fails with a recoverable exception" do
    it "recovers and attempts the next host" do
      @host1.stubs(:do_something).raises(RuntimeError, "Fuck!")
      @client_proxy.do_something.should == true
      @host1.should have_received(:do_something)
      @host2.should have_received(:do_something)
    end
  end

  describe "when a request fails more than max_retries times" do
    it "the error bubbles up" do
      @host1.stubs(:do_something).raises(RuntimeError, "Fuck!")
      @host2.stubs(:do_something).raises(RuntimeError, "Fuck!")
      lambda {
        @client_proxy.do_something
      }.should raise_error(RuntimeError)
      @host1.should have_received(:do_something).twice
      @host2.should have_received(:do_something).once
    end
  end
end
