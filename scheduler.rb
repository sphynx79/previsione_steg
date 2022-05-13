#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

require "rufus-scheduler"
require "logger"
require "open3"
require "pastel"
require "pry"
require "win32ole"

# ENV["TZ"] = "Africa/Tunis"

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

  def call(job, time)
    # @logger.debug "#{job} at #{Time.now}"
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

    if exit_status != 0
      p "Invio email errore"
      subject = "Errore Forecast STEG #{DateTime.now.strftime("%d/%m/%Y %H:%M")}"
      outlook = WIN32OLE.new("Outlook.Application")
      message = outlook.CreateItem(0)
      message.Subject = subject
      message.Body = out.gsub(/\e\[([;\d]+)?m/, "")
      message.To = "michele.boscolo@ttpc.eni.com"
      message.Send
    end

    return false if exit_status == 2
    return false if exit_status != 0
    true
  end

  def start_process(action)
    cmd = case action
    when "consuntivi"
      "#{RbConfig.ruby} steg.rb --verbose=1 --log=info --interface=scheduler --enviroment=#{@env} consuntivi"
    when "report_consuntivo"
      "#{RbConfig.ruby} steg.rb --verbose=1 --log=info --interface=scheduler --enviroment=#{@env} report --type=consuntivo --dt #{(Date.today - 1).strftime("%d/%m/%Y")} -H 23"
    when "report_forecast"
      "#{RbConfig.ruby} steg.rb --verbose=1 --log=info --interface=scheduler --enviroment=#{@env} report --type=forecast --dt #{(Date.today).strftime("%d/%m/%Y")} -H #{(Time.now).strftime("%H")}"
    when "forecast"
      "#{RbConfig.ruby} steg.rb --verbose=1 --log=info --interface=scheduler --enviroment=#{@env} forecast --dt #{(Date.today).strftime("%d/%m/%Y")} -H #{(Time.now).strftime("%H")}"
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
scheduler.cron("20 9 * * *", consuntivo, first_in: "1m", timeout: "5m", tag: "consuntivo")
forecast = Handler.new(actions: ["consuntivi", "forecast", "report_forecast"])
# Quando ce il cambio ora devo spostare avanti o indietro di una ora la riga seguente
scheduler.cron("16 10,11,12,13,14,15,16,17,18,19,20,21,22,23 * * *", forecast, first_in: "5m", timeout: "8m", tag: "forecast")

puts "Start Scheduler"

scheduler.join
