#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Prendo da excel tutti i dati di input
  class IterateHours
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises excel [WIN32OLE]
    promises :hour
    expects :params, :callback

    # @!method ConnecWIN32OLEtExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
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
