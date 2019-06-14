require 'pg'

module AMS
  class PostgresVacuumService
    attr_reader :conn_opts

    def initialize(opts={})
      @conn_opts = default_conn_opts.merge opts.slice(:dbname, :port, :user, :host, :password)
      self.logger = opts[:logger] if opts[:logger]
    end

    def run_vacuum_full
      return false if current_vacuum_full
      pid = fork do
        # Don't use #conn. Use a new db connection for forked process, and
        # exit when done. This ensures the connection will terminate when
        # finished
        new_connection.exec('VACUUM FULL;')
        logger.info "VACUUM FULL finished."
        exit
      end
      Process.detach(pid)
      logger.info "VACUUM FULL started in detached forked process (pid=#{pid})"
    end

    def current_vacuum_full
      begin
        conn.exec(current_vacuum_full_query).first
      rescue PG::UnableToSend => e
        logger.info "Couldnt contact PG #{e.inspect}"
        return nil
      end
    end

    # TODO: make private before commit
    # private

      def conn
        @conn ||= new_connection
      end

      def default_conn_opts
        {
          dbname: ENV.fetch('FCREPO_PG_DBNAME', nil),
          port: ENV.fetch('FCREPO_PG_PORT', '5432'),
          user: ENV.fetch('FCREPO_PG_USER', nil),
          host: ENV.fetch('FCREPO_PG_HOST', nil),
          password: ENV.fetch('FCREPO_PG_PASSWORD', nil)
        }
      end

      def new_connection
        PG::Connection.open(conn_opts[:host], conn_opts[:port], nil, nil, conn_opts[:dbname], conn_opts[:user], conn_opts[:password])
      end

      def current_vacuum_full_query
        <<-EOS
          SELECT pid, xact_start, current_timestamp - xact_start AS xact_runtime, state, query
          FROM pg_stat_activity
          WHERE datname='fcrepo'
          AND query LIKE '%VACUUM FULL%'
          AND query NOT LIKE '%dont return this query%';
        EOS
      end

      def logger=(logger)
        raise ArgumentError, "Logger object expected but #{logger.class} was given" unless logger.is_a? Logger
        @logger = logger
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
  end
end
