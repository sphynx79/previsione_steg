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
  attr_reader :actions, :logger, :env

  def initialize(actions: nil)
    @actions = actions
    init_env
    init_logger
  end

  def ini1gt
    parsed_env = ARGV.join(" ")[/(-e\s|--enviroment=)(production|development)/]
    @env = parsed_env.nil? || parsed_env.split(/(\s|=)/).last == "production" ? "production" : "development"
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
    exit_status, _err, out = start_process(action)

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
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=#{@env} consuntivi"
          when "report_consuntivo"
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=#{@env} report --type=consuntivo --dt #{(Date.today - 1).strftime("%d/%m/%Y")}"
          when "report_forecast"
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=#{@env} report --type=forecast --dt #{(Date.today).strftime("%d/%m/%Y")}"
          when "forecast"
            "#{RbConfig.ruby} steg.rb --log=info --interface=scheduler --enviroment=#{@env} forecast --dt #{(Date.today).strftime("%d/%m/%Y")}"
    end

    stdout, stderr, wait_thr = Open3.capture3(cmd)
    [wait_thr.exitstatus, stderr, stdout]
  end
end

# @todo diminuire la frequenza di rufus-scheduler
scheduler = Rufus::Scheduler.new(frequency: "5s")

def scheduler.on_error(job, error)
  pp ["error in scheduled job", job.class, job.original, error.message]
rescue
  p $!
end

consuntivo = Handler.new(actions: ["consuntivi", "report_consuntivo"])
scheduler.cron("50 8 * * *", consuntivo, first_in: "5s", timeout: "5m", tag: "consuntivo")

forecast = Handler.new(actions: ["consuntivi", "forecast", "report_forecast"])
scheduler.cron("20 10,12,13,14,15,16,17,18,19,20 * * *", forecast, first_in: "3m", timeout: "5m", tag: "forecast")

puts "Start Scheduler"

scheduler.join
