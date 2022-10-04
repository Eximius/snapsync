require_relative '../Notification'

module Snapsync
  # Tasks extending this should implement `_run`, `_task_name`
  #
  # All messages should be sent through `info`, `warn`, `error`
  # All sub-tasks should be executed by `task` or appropriately adding parent to <Task>.new
  # Progress (if the task implements it) should be notified by `set_progress`
  class Task

    def info(msg)
      Snapsync.info msg
      if Snapsync.NOTIFY
        @notification.update({:body => msg})
      end
    end

    def warn(msg)
      Snapsync.warn msg
      if Snapsync.NOTIFY
        @notification.update({:body => msg, :urgency => :critical})
      end
    end

    def error(msg)
      Snapsync.error msg
      if Snapsync.NOTIFY
        @notification.update({:body => msg, :urgency => :critical})
      end
    end

    # @param [Integer] percent
    def set_progress(percent)
      if Snapsync.NOTIFY
        @notification.update({:body => "[#{'#'*(percent / 10)}]"})
      end
    end

    # @param [Task, nil] parent
    def initialize(parent: nil)
      @parent = parent
    end

    def set_status(status)
      if Snapsync.NOTIFY
        @notification.update({ :summary => "#{_task_name} #{status}" })
      end
    end


    def run
      if Snapsync.NOTIFY
        @notification = Notification.new({
          :app_name => "Snapsync"+(Snapsync.SYSTEMD ? ' [systemd service]' : ''),
          :body => "Starting...", :summary => "#{_task_name} Running",
          :urgency => :normal, :append => false, :transient => false, :timeout => 15.0,
          :icon_path => "/usr/share/icons/gnome/scalable/emblems/emblem-default.svg"})
      end

      begin
        _run
      rescue Exception => e
        set_status "Failed"
        error e.message
        raise e
      end

      set_status "Finished"
    end

    def _task_name
      raise NotImplementedError
    end

    def _run
      raise NotImplementedError
    end
  end
end
