#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class ReportController < Ikigai::BaseController
  extend FunctionalLightService::Organizer
  include ShareActions # include Log
  include PdfActions
  # attr_accessor :log

  def self.call(env:)
    # @log = Yell["cli"]
    result = with(env: env).reduce(steps)
    check_result(result)
  end

  def self.steps
    [
      ConnectExcel, #=> [excel, workbook]
      SetExcelDay, #=> [data]
      GetPath, #=> [path]
      SetPdfPath, #=> [path_pdf_report]
      SavePdf,
      SendEmail
    ]
  end

  def self.check_result(result)
    # !result.warning.empty? && result.warning.each { |w| @log.warn w }
    if result.failure?
      log.error result.message
      # RemitLinee::Mail.call("Errore imprevisto nella lettura XML", msg) if env[:global_options][:mail]
    elsif !result.message.empty?
      log.info result.message
    else
      type = result.dig(:env, :command_options, :type)
      log.info { "Report #{type} inviato corretamente!" }
    end
  end
end
