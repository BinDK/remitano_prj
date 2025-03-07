module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.info "#{current_user == :guest ? 'Someone' : "User #{current_user.id}"} connected"
    end

    private

    def find_verified_user
      env['warden'].user.presence || :guest
    end
  end
end
