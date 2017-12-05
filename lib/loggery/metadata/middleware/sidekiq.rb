# frozen_string_literal: true

# Sidekiq middleware that adds basic sidekiq metadata to all log lines.

module Loggery
  module Metadata
    module Middleware
      class Sidekiq
        include Loggery::Util

        # Clients can provide their own error handler
        class << self
          attr_accessor(:error_handler) { ->(e) { Sidekiq::Logging.logger.error(e) } }
        end

        def call(_worker, message, queue)
          Loggery::Metadata::Store.with_metadata(build_metadata(message, queue)) do
            log_job_runtime(:sidekiq_job, "#{message['class']} (#{message['args']})") do
              begin
                yield
              rescue StandardError => e
                # Log exceptions here, otherwise they won't have the metadata available anymore by
                # the time they reach the Sidekiq default error handler.
                self.class.error_handler&.call(e)
                raise e
              end
            end
          end
        end

        private

        def build_metadata(message, queue)
          {
            jid:         message["jid"],
            thread_id:   Thread.current.object_id.to_s(36),
            worker:      message["class"],
            args:        message["args"].inspect,
            queue:       queue,
            retry_count: message["retry_count"],
            worker_type: "sidekiq"
          }
        end
      end
    end
  end
end