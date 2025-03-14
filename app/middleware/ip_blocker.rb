class IpBlocker
  def initialize(app)
    @app = app
    @redis = Redis.new(url: ENV.fetch('REDIS_IP_BLOCKER_URL', 'redis://localhost:6379/3'))
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    ip = request.remote_ip

    return @app.call(env) if websocket?(request)
    return blocked_response if blocked?(ip)

    status, headers, response = @app.call(env)

    track_failed_request(ip, status) if failed_request?(status)

    [status, headers, response]
  end

  private

  attr_accessor :app, :redis

  def websocket?(request)
    request.env['HTTP_UPGRADE'] == 'websocket' || request.path.start_with?('/cable')
  end

  def blocked?(ip)
    @redis.exists?("blocked_ips:#{ip}")
  end

  def failed_request?(status)
    [401, 404].include?(status)
  end

  def track_failed_request(ip, _status)
    key = "failed_attempts:#{ip}"
    @redis.incr(key)
    @redis.expire(key, 1.hour)

    @redis.setex("blocked_ips:#{ip}", 24.hours, 1) if @redis.get(key).to_i >= 3
  end

  def blocked_response
    [403, { 'Content-Type' => 'text/plain' }, ['Your IP has been blocked.']]
  end
end
