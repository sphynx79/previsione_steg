#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require "rufus-scheduler"
require "logger"
require "open3"
require "pastel"
require "pry"

# ENV["TZ"] = "Africa/Algiers"

class Handler
  attr_reader :actions, :logger, :env

  def initialize(actions: nil)
    @actions = actions
    init_env
    init_logger
  end

  def init_env
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
      sleep 5
    end
  end

  def process_is_ok(action)
    exit_status, _err, out = start_process(action)

    print out.strip if !out.nil? && out != ""
    return false if exit_status == 2
    return false if exit_status != 0

    # if exit_status != 0
    #   # p "Invio email"
    #   # Email.send(err, action, controparte)
    #   # else
    #   #   # $logger.info " nessun file da archiviare"
    #   # end
    #   return false
    # end
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

scheduler = Rufus::Scheduler.new(frequency: "30s")

def scheduler.on_error(job, error)
  pp ["error in scheduled job", job.class, job.original, error.message]
rescue
  p $!
end

consuntivo = Handler.new(actions: ["consuntivi", "report_consuntivo"])
scheduler.cron("49 8 * * *", consuntivo, first_in: "2m", timeout: "5m", tag: "consuntivo")

forecast = Handler.new(actions: ["consuntivi", "forecast", "report_forecast"])
scheduler.cron("09 9,11,12,13,14,15,16,17,18,19,20,21 * * *", forecast, timeout: "5m", tag: "forecast")

puts "Start Scheduler"

scheduler.join
