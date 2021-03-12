#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class ForecastController < Ikigai::BaseController
  # extend FunctionalLightService::Organizer
  # include ShareActions # include Log
  # attr_accessor :log

  def self.call(env:)
    p env
    # @log = env[:interface].to_sym == :gui ? Yell['gui'] : Yell['cli']

    # steps = env.dig(:command_options, :societa) == 'ttpc' ? steps_ttpc : steps_steg
    # result = with(env).reduce(steps)
    # check_result(result)
  # rescue StandardError => e
    # msg = e.message + "\n"
    # e.backtrace.each { |x| msg += x + "\n" if x.include? APP_NAME } # msg += x + "\n"
    # @log.error msg # RemitLinee::Mail.call('Errore imprevisto nella lettura XML', msg) if env[:global_options][:mail]
    # exit! 1
  end

  # def self.steps_ttpc
  #   include ReadTtpcActions
  #   [
  #     SetLogger,
  #     GetListFile,
  #     ConnectDb,
  #     CreateTable,
  #     iterate(
  #       :files,
  #       [
  #         ReadFile,
  #         ParseMatchLinee,
  #         CheckMissingHour,
  #         InsertDataToDb,
  #         ArchiviaFile
  #       ]
  #     )
  #   ]
  # end

  # def self.steps_steg
  #   include ReadStegActions
  #   [
  #     SetLogger,
  #     GetListFile,
  #     ConnectDb,
  #     CreateTable,
  #     iterate(
  #       :files,
  #       [
  #         SplitDays,
  #         ExtractData,
  #         # CheckMissingHour,
  #         InsertDataToDb,
  #         ArchiviaFile
  #       ]
  #     )
  #   ]
  # end

  # def self.check_result(result)
  #   binding.pry
  #   !result.warning.empty? && result.warning.each { |w| @log.warn w }
  #   if result.failure?
  #     @log.error result.message
  #     # RemitLinee::Mail.call('Errore imprevisto nella lettura XML', msg) if env[:global_options][:mail]
  #   elsif !result.message.empty?
  #     @log.info result.message
  #   else
  #     print "\n"
  #     @log.info 'File letti corretamente'
  #   end
  # end
end
