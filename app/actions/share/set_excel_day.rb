#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ShareActions
  # Setta nel file excel del Forecast la data
  class SetExcelDay
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises data [String] Contiene la data es. "09042021"
    promises :data

    # @!method GetExcelData
    #   @yield Prende dal file excel la data del report PDF
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      # data = get_data
      # @type data [String]
      data = ctx.dig(:env, :command_options, :day)
      set_day(data)
      ctx.data = data.delete("/").freeze
    end

    # @TODO: Vedere se rimuovere questa parte di codice
    # def self.get_data
    #   if data.nil? || !data[0..9].match?(/^([0-2][0-9]|(3)[0-1])(\/)(((0)[0-9])|((1)[0-2]))(\/)\d{4}$/)
    #     ctx.fail_and_return!(
    #       <<~HEREDOC
    #         Controllare che nel file: Forecast.xlsm
    #         Foglio: "Forecast V1"
    #         Nella cella Data (M3): sia presente una data
    #       HEREDOC
    #     )
    #   end
    #   data[0..9]
    # end

    # private_class_method :get_data
  end
end
