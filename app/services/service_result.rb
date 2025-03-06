class ServiceResult
  attr_reader :success, :message

  def initialize(success, message = nil)
    @success = success
    @message = message
  end

  def success?
    @success
  end

  def self.success(message = nil)
    new(true, message)
  end

  def self.failure(message)
    new(false, message)
  end
end
