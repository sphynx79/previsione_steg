#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Itero sulle ore del giorno del Forecast che devo fare
  # ed eseguo [FilterData, MediaPonderata]
  class IterateHours
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects params [Hamster::Hash] parametri letti da excel
    # @expects callback [Proc] le azioni da eseguire per ogni ora
    expects :params, :callback
    # @promises hour [Hash]
    promises :hour

    # @!method IterateHours
    #   @yield Itero sulle ore del giorno ed eseguo [FilterData, MediaPonderata]
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      ctx.params[:day_hours].each do |hour|
        ctx.hour = hour
        ctx.callback.call(ctx)
      end
    end
  end
end
