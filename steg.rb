#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

$LOAD_PATH.unshift "."

# faccio il parse del paramentro enviroment per vedere quale gemme da caricare
parsed_env = ARGV.join(" ")[/(-e\s|--enviroment=)(production|development)/]
env = parsed_env.nil? || parsed_env.split(/(\s|=)/).last != "production" ? :development : :production

require "bundler/setup"

Bundler.require(:default, env.to_sym)
require "win32ole"
require "open3"
require "lib/ikigai"

ENV["TZ"] = "Africa/Tunis"

APP_ROOT = Pathname.new(File.expand_path(".", __dir__))

APP_NAME = APP_ROOT.parent.basename.to_s
APP_VERSION = File.read("./VERSION").strip

module PrevisioneSteg
  include GLI::App
  extend self

  program_desc "Programma per fare la previsione del consumo gas di Steg"
  version APP_VERSION
  subcommand_option_handling :normal
  arguments :strict
  sort_help :manually
  wrap_help_text :verbatim

  desc "Setto il livello di verbose [0, 1, 2] 0 è disabilitato 2 è il massimo"
  default_value "0"
  flag %i[v verbose], required: false, must_match: %w[0 1 2]

  desc "Log level [debug, info, warn, error, fatal]"
  default_value "info"
  flag %i[l log], required: false

  desc "Interfaccia da usare [cli, scheduler]"
  default_value "cli"
  flag %i[i interface], required: false

  desc "Enviroment da usare [production, development production_local]"
  default_value "production"
  flag %i[e enviroment], required: false, must_match: %w[production development production_local]

  desc "Databse da utilizzare [sqlite, access, csv]"
  default_value "csv"
  flag %i[db database], required: false, must_match: %w[sqlite access csv]

  desc "Abilita email in caso di errore imprevisto"
  default_value false
  switch :mail

  desc "Avvio forecast STEG"
  long_desc "Legge dal file Excel Forecast.xlsm i parametri di input e avvia il forecast"
  command :forecast do |c|
    c.desc "day prevision [dd/mm/aaaa]"
    c.flag %i[dt day], required: false, type: String
    c.desc "hour prevision [dd/mm/aaaa]"

    # @TODO: vedere se devo fare un check sulla ora come faccio per la data
    c.flag %i[H hour], required: true, type: String

    c.example "ruby steg.rb --log=info --interface=cli --enviroment=production forecast --dt 10/04/2021 --H 10", desc: "Avvio del forecast"

    c.action do
      Ikigai::Application.call(@env)
    end
  end

  desc "Send Report"
  long_desc "Salva la previsione o il consuntivo su file PDF e invia via email il report"
  command :report do |c|
    c.desc "Setto la tipologia di report [consuntivo forecast]"
    c.flag %i[t type], required: false, default_value: "forecast", must_match: %w[consuntivo forecast]

    c.desc "day report [dd/mm/aaaa]"
    c.flag %i[dt day], required: false, type: String

    # @TODO: vedere se devo fare un check sulla ora come faccio per la data
    c.flag %i[H hour], required: true, type: String

    c.example "ruby steg.rb --log=info --interface=cli --enviroment=production report --type=forecast --dt 10/04/2021 -H 08", \
      desc: "Creo il Report PDF per il forecast"
    c.example "ruby steg.rb --log=info --interface=cli --enviroment=production report --type=consuntivo --dt 10/04/2021 -H 08", \
      desc: "Creo il Report PDF per il consuntivo"

    c.action do
      # prima = Time.now
      Ikigai::Application.call(@env)
      # p Time.now - prima
    end
  end

  desc "Leggi Consuntivo"
  long_desc "Avvio lo scaricamento e lettura dal FTP di Scada dei consuntivi"
  command :consuntivi do |c|
    c.example "ruby steg.rb --log=info --interface=cli --enviroment=production consuntivi", \
      desc: "Avvio lo scaricamento FTP dei consuntivi e inserimento a DB"

    c.action do
      # prima = Time.now
      Ikigai::Application.call(@env)
      # p Time.now - prima
    end
  end

  pre do |global, command, options, args|
    ENV["GLI_DEBUG"] = global[:enviroment] == "development" ? "true" : "false"
    set_env(command, global, options)
    check_date(options[:day]) if [:report, :forecast].include? command.name
    init_log(global[:log], global[:interface])
    set_trace_point if global[:verbose] == "2"

    Ikigai::Initialization.call
    true
  end

  post do |global, command, options, args|
    # Post logic here
    # Use skips_post before a command to skip this
    # block on that command only
  end

  on_error do |exception|
    msg = exception.message
    case exception
    when GLI::UnknownGlobalArgument
      if /-e\s|-enviroment/.match?(msg)
        puts "Devi specificare l'enviroment:"
        puts "    -e           [production, development, production_local]"
        puts "    --enviroment [production, development, production_local]"
      end
      false # use GLI"s default error handling
    else
      true
    end
  end

  def set_env(command, global, options)
    if global[:enviroment] == "development"
      Hirb.enable
      FunctionalLightService::Configuration.logger =
        global[:log] == "debug" ? Logger.new($stdout) : Logger.new(null_device)
    else
      FunctionalLightService::Configuration.logger = Logger.new(null_device)
    end
    ENV["APP_ENV"] = global[:enviroment]
    action = "call"
    controller = command.name.to_s
    @env = {
      controller: controller,
      action: action,
      command_options: options,
      global_options: global
    }
  end

  def null_device
    if /cygwin|mswin|mingw|bccwin|wince|emx/.match? RUBY_PLATFORM
      "NUL:"
    else
      "/dev/null"
    end
  end

  def init_log(level, interface)
    Ikigai::Log.level = level.upcase
    pastel = Pastel.new
    Ikigai::Log.formatter = proc do |severity, datetime, _progname, msg|
      string = if severity != "FATAL"
        "#{datetime.strftime("%d-%m-%Y %X")} --[#{severity}]-- : #{msg}\n"
      else
        "#{msg}\n"
      end

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
    # binding.pry
    # Object.send :include, Log
  end

  def set_trace_point
    # vedere se usare la gemma https://github.com/st0012/object_tracer
    trace = TracePoint.new(:call) do |tp|
      tp.disable
      path = tp.path
      pastel = Pastel.new
      if (path =~ /Steg/) && (path !~ /rblcl/i) && (path !~ /ruby/i)
        parameters = eval <<-RUBY, tp.binding, __FILE__, __LINE__ + 1
          method(:#{tp.method_id}).parameters
        RUBY

        # eval("method(:#{tp.method_id}).parameters", tp.binding)
        parameters.map! do |_, arg|
          if tp.binding.local_variable_defined?(arg)
            arg_content = tp.binding.local_variable_get(arg)
            if arg_content.is_a?(Array) && arg_content.size > 20
              "#{arg} = #{arg_content[0..5]}"
            elsif arg_content.is_a?(Hash)
              "#{arg} = #{arg_content.first}"
            else
              "#{arg} = #{tp.binding.local_variable_get(arg)}"
            end
          end
        end.join(", ")
        puts pastel.blue("#{"*" * 40}CALL#{"*" * 40}")
        puts pastel.green("File: #{tp.path.split("/")[-3..].join("/")}:#{tp.lineno}")
        puts pastel.green("Class: #{tp.defined_class}")
        puts pastel.green("Method: #{tp.method_id}")
        puts pastel.green("Params:\n#{parameters * "\n\n"}") unless parameters.empty?
      end
      tp.enable
    end
    trace.enable
  end

  def check_date(date)
    if date.nil? || !date.match(%r{^\d{2}/\d{2}/\d{4}$})
      print "\nDevi inserire una data nella forma --day=dd/mm/yyyy\n"
      print "Es: ruby steg.rb report --type=consuntivo --day=20/08/2020\n"
      print "\n"
      exit!
    end
  end
  # Controllo se lo sto lanciandi come programma
  # oppure il file e" stato usato come require
  exit run(ARGV) if $PROGRAM_NAME == __FILE__
end

# @TODO:  1) Vedere quale logger utilizzare il mio oppure yell oppure lit o semantic_logger
#         2) Vedere se usare pretty_backtrace, prendere esempio da Remit_linee_new
#         3) Vedere se usare bundle oppure il require semplice
#         4) Abilitare FunctionalLightService nel set_env
#         5) mettere env di default production riga 1
