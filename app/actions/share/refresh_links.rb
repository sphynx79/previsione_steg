#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ShareActions
  ##
  # Refresha i collegamenti del file Excel forecast
  #
  class RefreshLinks
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    # @!method RefreshLinks(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        refresh_links
      end.map_err { ctx.fail_and_return!("Non riesco ad aggiornare i link del #{Ikigai::Config.file.excel_forecast} | #{__FILE__}:#{__LINE__}") }
    end
  end
end
