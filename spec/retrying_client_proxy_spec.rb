require "spec_helper"

describe "ClientProxy::RetryingClient" do
  before do
    @client_factory = stub("ClientFactory")
    @host1          = stub("Client::Host1")
    @host2          = stub("Client::Host2")
    @client_factory.stubs(:create).with("host1:5432").returns(@host1)
    @client_factory.stubs(:create).with("host2:5432").returns(@host2)
  end
end
