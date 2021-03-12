#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

# Per questo modulo ho preso spunto da questa gemma
# https://github.com/thisismydesign/easy_logging
module Log
  module Initializer
    # Initialize instance level logger at the time of instance creation
    def initialize(*params)
      super
      log
    end
  end

  class << self; attr_accessor :log_destination, :level, :formatter; end

  @log_destination = STDOUT
  @level = Logger::INFO
  @loggers = {}

  def self.log_destination=(dest)
    @log_destination = dest
  end

  def self.level=(level)
    @level = level
  end

  private_class_method

  # Executed when the module is included. See: https://stackoverflow.com/a/5160822/2771889
  def self.included(base)
    base.send :prepend, Initializer
    # Class level private logger method for includer class (base)
    class << base
      private

      def log
        @log ||= Log.logger_for(self)
      end
    end

    # Initialize class level logger at the time of including
    base.send :log
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger_for(classname)
    @loggers[classname] ||= configure_logger_for(classname)
  end

  def self.configure_logger_for(classname)
    log = Logger.new(log_destination)
    log.level = level
    log.progname = classname
    log.formatter = formatter unless formatter.nil?
    log
  end

  private

  def log
    @log ||= Log.logger_for(self.class.name)
  end
end
