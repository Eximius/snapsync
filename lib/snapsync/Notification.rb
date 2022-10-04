require 'libnotify'

module Snapsync
  # This class abstracts notifying each user on the system
  # NOTE: Not multi-thread safe!
  class Notification
    # @return [Hash{Integer => Libnotify::API}]
    attr_reader :notified_users

    def initialize(config)
      @notified_users = {}


      Dir.each_child('/run/user') do |user_id|
        # seteuid _must_ be set for session dbus to accept the connection
        Process::Sys.seteuid(user_id.to_i)
        ENV['DBUS_SESSION_BUS_ADDRESS'] = "unix:path=/run/user/#{user_id}/bus"

        n = Libnotify.new(config)
        @notified_users[user_id.to_i] = n
        n.show!
      end
      # set euid back, so all commands works normally
      Process::Sys.seteuid Process::Sys.getuid
    end

    def update(config)
      each_raw_notification do |n|
        n.update(config)
      end
    end

    def close
      each_raw_notification do |n|
        n.close
      end
    end

    # @yieldparam [Libnotify::API] n
    private def each_raw_notification
      notified_users.each do |user_id, n|
        # seteuid _must_ be set for session dbus to accept the connection
        Process::Sys.seteuid(user_id)
        ENV['DBUS_SESSION_BUS_ADDRESS'] = "unix:path=/run/user/#{user_id}/bus"

        yield n
      end
      # set euid back, so all commands works normally
      Process::Sys.seteuid Process::Sys.getuid
    end
  end
end
