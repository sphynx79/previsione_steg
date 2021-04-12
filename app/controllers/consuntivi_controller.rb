#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class ConsuntiviController < Ikigai::BaseController
  extend FunctionalLightService::Organizer
  extend FunctionalLightService::Prelude::Result
  include ConsuntiviActions
  # include ShareActions # include Log
  # attr_accessor :log

  def self.call(env:)
    # @log = Yell["cli"]
    result = with(env: env).reduce(steps)
    check_result(result)
  end

  def self.steps
    [
      DownloadConsuntivi,
      ConnectExcel, #=> [excel, workbook]
      LeggiConsuntivi
    ]
  end

  def self.check_result(result)
    # !result.warning.empty? && result.warning.each { |w| @log.warn w }
    if result.failure?
      # $stderr.puts("ABORTED! You forgot to BAR the BAZ")
      log.error { result.message }
      exit 1
    else
      log.info { "Download consuntivi avvenuto con successo!" }
    end
  end
end