require 'sequel/database/logging'
require 'active_support/notifications'

module ROM
  module SQL
    module ActiveSupportInstrumentation
      if Sequel::MAJOR == 4 && Sequel::MINOR < 35
        def log_yield(sql, args = nil)
          ActiveSupport::Notifications.instrument(
            'sql.rom',
            sql: sql,
            name: instrumentation_name,
            binds: args
          ) { super }
        end
      else
        def log_connection_yield(sql, _conn, args = nil)
          ActiveSupport::Notifications.instrument(
            'sql.rom',
            sql: sql,
            name: instrumentation_name,
            binds: args
          ) { super }
        end
      end

      private

      def instrumentation_name
        "ROM[#{database_type}]"
      end
    end
  end
end

Sequel::Database.send(:prepend, ROM::SQL::ActiveSupportInstrumentation)
