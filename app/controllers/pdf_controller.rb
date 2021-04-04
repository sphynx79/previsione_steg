#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class PdfController < Ikigai::BaseController
  extend FunctionalLightService::Organizer
  include PdfActions
  # include ShareActions # include Log
  # attr_accessor :log

  def self.call(env:)
    @log = Yell["cli"]
    result = with(env: env).reduce(steps)
    check_result(result)
  end

  def self.steps
    [
      GetPath
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
      @log.info "Creazione PDF eseguita correttamente"
    end
  end
end
