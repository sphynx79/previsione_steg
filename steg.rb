#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

$LOAD_PATH.unshift "."

require "gli"
require "pry"
require "gli"
require "steg"

# faccio il parse del paramentro enviroment per vedere quale gemme da caricare
# parsed_env = ARGV.join(' ')[/(-e\s|--enviroment=)(production|development)/]
env = if parsed_env.nil?
        :production
      else
        parsed_env.split(/(\s|=)/).last == 'production' ? :production : :development
      end

# SOLUZIONE 1 REQUIRE
require 'bundler/setup'
Bundler.require(:default, env.to_sym)

require 'lib/muletto'
APP_ROOT = Pathname.new(File.expand_path(".", __dir__))
APP_NAME = APP_ROOT.parent.basename.to_s
APP_VERSION = File.read("./VERSION").strip

CONFIG = File.join(__dir__, 'config.yml')

module PrevisioneSteg
  class App
    extend GLI::App
    extend self

    program_desc "Programma per fare la previsione del consumo gas di Steg"
    version APP_VERSION
    subcommand_option_handling :normal
    arguments :strict
    sort_help :manually
    wrap_help_text :one_line
    
    desc 'Log level [debug, info, warn, error, fatal]'
    default_value 'info'
    flag %i[l log], required: false
    
    desc 'Enviroment da usare [production, development production_local]'
    default_value 'production'
    flag %i[e enviroment], required: false, must_match: %w[production development production_local]
    
    desc 'Databse da utilizzare [sqlite, access, csv]'
    default_value 'csv'
    flag %i[db database], required: false, must_match: %w[sqlite access csv]
    
    desc 'Abilita email in caso di errore imprevisto'
    default_value false
    switch :mail


    desc 'Avvio forecast STEG'
    long_desc 'Legge dal file Excel Forecast.xlsm i parametri di input e avvia il forecast'
    command :forecast do |c|
      c.action do
        Ikigai::Application.call(@env)
      end
    end

    pre do |global, command, options, args|
      ENV['GLI_DEBUG'] = global[:enviroment] == 'development' ? 'true' : 'false'
      set_env(command, global, options)
      init_log(global[:log])
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
          puts '    -e           [production, development, production_local]'
          puts '    --enviroment [production, development, production_local]'
        end
        false # use GLI's default error handling
      else
        true
      end
    end

    def self.set_env(command, global, options)
      if global[:enviroment] == 'development'
        Hirb.enable
        FunctionalLightService::Configuration.logger =
          global[:log] == 'debug' ? Logger.new(STDOUT) : nil
      else
        FunctionalLightService::Configuration.logger = nil
      end
      ENV['APP_ENV'] = global[:enviroment]
      action = 'call'
      controller = command.name.to_s
      @env = {
        controller: controller,
        action: action,
        command_options: options,
        global_options: global
      }
    end

    def self.init_log(level)
      # Log.logger = Logger.new( 'logfile.log')
      Log.level = level.upcase
      pastel = Pastel.new
      Log.formatter = proc do |severity, datetime, _progname, msg|
        string = if severity != 'FATAL'
                   "#{datetime.strftime('%d-%m-%Y %X')} --[#{severity}]-- : #{msg}\n"
                 else
                   "#{msg}\n"
                 end

        case severity
        when 'DEBUG'
          pastel.cyan.bold(string)
        when 'WARN'
          pastel.magenta.bold(string)
        when 'INFO'
          pastel.green.bold(string)
        when 'ERROR'
          pastel.red.bold(string)
        when 'FATAL'
          pastel.yellow.bold(string)
        else
          pastel.blue(string)
        end
      end
      Object.send :include, Log
    end

  end
end

# oppure il file e' stato usato come require
exit PrevisioneSteg::App.run(ARGV) if $PROGRAM_NAME == __FILE__

# @todo:  1) Vedere quale logger utilizzare il mio oppure yell oppure lit
#         2) Vedere se usare pretty_backtrace, prendere esempio da Remit_linee_new
#         3) Vedere se usare bundle oppure il require semplice
