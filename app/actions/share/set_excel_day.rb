#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ShareActions
  ##
  # Setta nel file excel la data e la salva nella variabile data
  #
  # <div class="lsp">
  #   <h2>Promises:</h2>
  #   - data (String)<br>
  # </div>
  #
  class SetExcelDay
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    promises :data

    # @!method SetExcelDay(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @promises data [String]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]<br>
    executed do |ctx|
      # @type [String]
      data = ctx.dig(:env, :command_options, :day)
      try! do
        set_day(data)
      end.map_err { ctx.fail_and_return!("#{self.to_s.split("::").last}: Non riesco a impostare la data in file #{Ikigai::Config.file.excel_forecast} Forecast V1 cella M3 | #{__FILE__}:#{__LINE__} ") }
      ctx.data = data.delete("/").freeze
    end
  end
end
