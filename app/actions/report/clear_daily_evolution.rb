#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ReportActions
  ##
  # Pulisco la tabella daily evolution del forecast
  #
  class ClearDailyEvolution
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    # @!method ClearDailyEvolution(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        clear_daily_evolution
      end.map_err do |err|
        ctx.fail_and_return!(
          {message: "Non riesco a pulire la tabella daily evolution del file #{Ikigai::Config.file.excel_forecast}",
           detail: err.message,
           location: "#{__FILE__}:#{__LINE__}"}
        )
      end
    end
  end
end
