#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ShareActions
  # Setta nel file excel del Forecast la data
  # @promises data [String] Contiene la data es. "09042021"
  class SetExcelDay
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    promises :data

    # @!method SetExcelDay
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
  end
end
