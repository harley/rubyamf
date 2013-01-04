require 'logger'

module RubyAMF
  class Logger #:nodoc:
    # Log exceptions in rails-style, with cleaned backtrace if available
    def log_error e
      msg = "#{e.class} (#{e.message}):\n  "
      msg += clean_backtrace(e).join("\n  ")
      logger.fatal(msg)
    end

    # Send every other method call to internally wrapped logger
    def method_missing name, *args
      logger.send(name, args)
    end

    private
    # Use rails logger if available or create standard ruby logger to STDERR
    def logger
      unless @logger
        if defined?(Rails) && ::Rails.logger
          @logger = ::Rails.logger
        else
          @logger = ::Logger.new(STDERR)
        end
      end
      @logger
    end

    # Use Rails backtrace cleaner if it exists to clean
    def clean_backtrace e
      if defined?(Rails) && ::Rails.respond_to?(:backtrace_cleaner)
        ::Rails.backtrace_cleaner.remove_silencers!
        ::Rails.backtrace_cleaner.clean(e.backtrace)
      else
        e.backtrace
      end
    end
  end
end