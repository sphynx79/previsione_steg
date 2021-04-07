#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require "rufus-scheduler"
require "logger"
require "open3"

# @todo: eliminare questa parte di codice
# $logger = Logger.new(STDOUT)
# $logger.level = Logger::DEBUG
# # $logger.level = Logger::WARN
# # STDOUT.sync = true
# # STDERR.sync = true

# $logger.formatter = proc do |severity, datetime, _progname, msg|
#       "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
# end

ENV["TZ"] = "UTC"

class Handler
  attr_reader :actions, :logger

  def initialize(actions: nil)
    @actions = actions
    init_logger
  end

  def init_logger
    @logger = Logger.new($stdout)
    @logger.level = Logger::DEBUG
    @logger.formatter = proc do |severity, datetime, _progname, msg|
      "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}] #{severity}: #{msg}\n"
    end
  end

  def call(job)
    # $logger.info "#{job} at #{Time.now}"
    start_task
  rescue Rufus::Scheduler::TimeoutError
    @logger.warn "Sono andato in Timeout"
  end

  def start_task
    @actions.each do |action|
      @logger.debug " - Start task #{action}:"
      break unless process_is_ok(action)
      @logger.debug " - finito corretamente"
    end
  end

  def process_is_ok(action)
    exit_status, err, out = start_process(action)

    if !out.nil? && out != ""
      @logger.info "  - #{out.strip}"
    end

    if exit_status != 0
      @logger.warn err.chomp
      p "Invio email"
      # Email.send(err, action, controparte)
      # else
      #   # $logger.info " nessun file da archiviare"
      # end
      return false
    end
    true
  end

  def start_process(action)
    cmd = case action
          when "consuntivi"
            "#{RbConfig.ruby} steg.rb --interface=scheduler --enviroment=production consuntivi"
          when "report_consuntivo"
            "#{RbConfig.ruby} steg.rb --interface=scheduler --enviroment=production report --type=consuntivo --dt #{(Date.today - 1).strftime("%d/%m/%Y")}"
          when "report_forecast"
            "#{RbConfig.ruby} steg.rb --interface=scheduler --enviroment=production report --type=forecast --dt #{(Date.today).strftime("%d/%m/%Y")}"
          when "forecast"
            "#{RbConfig.ruby} steg.rb --interface=scheduler --enviroment=production forecast --dt #{(Date.today).strftime("%d/%m/%Y")}"
          end

    stdout, stderr, wait_thr = Open3.capture3(cmd)
    [wait_thr.exitstatus, stderr, stdout]
  end
end

# @todo diminuire la frequenza di rufus-scheduler
scheduler = Rufus::Scheduler.new(frequency: "3s")

def scheduler.on_error(job, error)
  p ["error in scheduled job", job.class, job.original, error.message]
rescue
  p $!
end

consuntivo = Handler.new(actions: ["consuntivi", "report_consuntivo"])
scheduler.every("30s", consuntivo, timeout: "1m", tag: "consuntivo")

# forecast = Handler.new(actions: ["consuntivi", "forecast", "report_forecast"])
# scheduler.every("30s", forecast, timeout: "1m", tag: "forecast")

puts "Start Scheduler"

scheduler.join
