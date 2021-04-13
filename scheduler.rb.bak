#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require "rufus-scheduler"
require "logger"
require "open3"
require "pastel"
require "pry"

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
    pastel = Pastel.new
    @logger.formatter = proc do |severity, datetime, _progname, msg|
      string = "#{datetime.strftime("%d-%m-%Y %X")} --[#{severity}]-- : #{msg}\n"
      case severity
      when "DEBUG"
        pastel.cyan.bold(string)
      when "WARN"
        pastel.magenta.bold(string)
      when "INFO"
        pastel.green.bold(string)
      when "ERROR"
        pastel.red.bold(string)
      when "FATAL"
        pastel.yellow.bold(string)
      else
        pastel.blue(string)
      end
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
      @logger.debug "Task #{action} start:"
      break unless process_is_ok(action)
      @logger.debug "Task #{action} end"
    end
  end

  def process_is_ok(action)
    exit_status, err, out = start_process(action)

    if !out.nil? && out != ""
      print out.strip
    end
    return false if exit_status == 2

    if exit_status != 0
      # p "Invio email"
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
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=production consuntivi"
          when "report_consuntivo"
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=production report --type=consuntivo --dt #{(Date.today - 1).strftime("%d/%m/%Y")}"
          when "report_forecast"
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=production report --type=forecast --dt #{(Date.today).strftime("%d/%m/%Y")}"
          when "forecast"
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=production forecast --dt #{(Date.today).strftime("%d/%m/%Y")}"
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
scheduler.cron("50 10 * * *", consuntivo, first_in: "5s", timeout: "1m", tag: "consuntivo")

forecast = Handler.new(actions: ["consuntivi", "forecast", "report_forecast"])
scheduler.cron("0 11,13,14,15,16,17,18,19 * * *", forecast, first_in: "1m", timeout: "1m", tag: "forecast")

puts "Start Scheduler"

scheduler.join
