# Custom middlewares should be configured in an initializer because autoloading code does not work
# yet in application.rb

Rails.configuration.middleware.insert_after ActionDispatch::Executor, IpBlocker
