class ClientProxy
  def initialize(client_factory, hosts, recoverable_errors, max_retries, randomize_order = true)
    @client_factory     = client_factory
    @hosts              = hosts
    @recoverable_errors = recoverable_errors
    @max_retries        = max_retries
    @host_pointer       = randomize_order ? rand(hosts.length) : -1
  end

  def method_missing(method, *args, &block)
    attempt(0, method, *args, &block)
  end

  def attempt(try, method, *args, &block)
    begin
      current_client.__send__(method, *args, &block)
    rescue *@recoverable_errors => e
      @current_client = nil
      raise e if try == (@max_retries - 1)
      attempt(try + 1, method, *args, &block)
    end
  end

  private
    def current_client
      @current_client ||= next_client
    end

    def next_client
      @client_factory.create(next_host)
    end

    def next_host
      @host_pointer += 1
      @host_pointer  = 0 if @host_pointer == @hosts.length
      @current_host = @hosts[@host_pointer]
    end
end
