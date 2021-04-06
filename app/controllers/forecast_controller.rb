#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

PS = %w[feriana kasserine zriba nabeul korba].freeze

class ForecastController < Ikigai::BaseController
  extend FunctionalLightService::Organizer
  include ForecastActions
  # include ShareActions # include Log
  # attr_accessor :log

  def self.call(env:)
    @log = Yell["cli"]

    result = with(env).reduce(steps)
    # exit
    check_result(result)
  # rescue => e
  #   msg = e.message + "\n"
  #   e.backtrace.each { |x| msg += x + "\n" if x.include? APP_NAME } # msg += x + "\n"
  #   # @log.error msg # RemitLinee::Mail.call("Errore imprevisto nella lettura XML", msg) if env[:global_options][:mail]
  #   ap msg # RemitLinee::Mail.call("Errore imprevisto nella lettura XML", msg) if env[:global_options][:mail]
  #   exit! 1
  end

  def self.steps
    [
      ConnectExcel,
      GetExcelParams,
      ParseCsv,
      with_callback(IterateHours, [FilterData, MediaPonderata]),
      CompilaForecastExcel
    ]
  end

  def self.check_result(result)
    # !result.warning.empty? && result.warning.each { |w| @log.warn w }
    if result.failure?
      @log.error result.message
      # RemitLinee::Mail.call("Errore imprevisto nella lettura XML", msg) if env[:global_options][:mail]
    elsif !result.message.empty?
      @log.info result.message
    else
      print "\n"
      @log.info { "Forecast eseguito corretamente" }
    end
  end
end
