module Snapsync
  class SSHPopenExe
    # @return [IO]
    attr_reader :ssh_proc

    class NonZeroExitCode < RuntimeError
    end
    class ExitSignal < RuntimeError
    end

    # @return [IO]
    attr_reader :read_buffer

    # @return [IO]
    attr_reader :write_buffer

    # @param machine [RemotePathname]
    # @param [Array] command
    # @param options [Hash]
    def initialize(machine, command, **options)
      # @type [IO,IO]
      @err_r, err_w = IO.pipe
      full_cmd = ['ssh', machine.uri.host, *command]
      Snapsync.debug "Opening SSH Tunnel: #{full_cmd}"
      @ssh_proc = IO.popen(full_cmd, err: err_w, mode: 'r+')
    end

    def sync=(sync)
      # ignore
    end

    def read(nbytes = nil)
      begin
        return ssh_proc.read nbytes
      rescue Errno::EWOULDBLOCK
        return ''
      end
    end

    def write(data)
      ssh_proc.write data
    end

    def close
      ssh_proc.close_write
    end

    def err
      @err_r.read
    end
  end
end
