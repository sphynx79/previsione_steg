#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  ##
  # Prendo i valori della previsione corrente per copiarli nella tabella daily evolution del forecast
  #
  # <div class="lsp">
  #   <h2>Expects:</h2>
  #   - workbook (WIN32OLE)<br>
  #   <h2>Promises:</h2>
  #   - daily_evolution (Hash) Previsione corrente<br>
  # </div>
  #
  #
  class DailyEvolution
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    expects :workbook
    promises :daily_evolution

    # @!method DailyEvolution(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @expects workbook [WIN32OLE]
    #
    #   @promises daily_evolution [Hash] Previsione corrente
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        ctx.workbook.sheets("Forecast").Activate
        daily_evolution = {}
        daily_evolution[:previsione_v1] = ctx.workbook.sheets("Forecast").Range("$T$6").value.to_i
        daily_evolution[:previsione_v2] = ctx.workbook.sheets("Forecast").Range("$T$8").value.to_i
        daily_evolution[:previsione_v3] = ctx.workbook.sheets("Forecast").Range("$T$10").value.to_i
        daily_evolution[:nomina] = ctx.workbook.sheets("Forecast").Range("$T$12").value.to_i
        daily_evolution[:progressivo] = ctx.workbook.sheets("Forecast").Range("$T$14").value.to_i
        daily_evolution[:consuntivo] = ctx.workbook.sheets("Forecast").Range("$T$16").value.to_i
        daily_evolution[:peso_previsione_nomina] = ctx.workbook.sheets("Forecast").Range("$AF$11").value
        daily_evolution[:correzione_cons_parziale] = ctx.workbook.sheets("Forecast").Range("$AF$13").value
        ctx.daily_evolution = daily_evolution.freeze
      end.map_err do |err|
        ctx.fail_and_return!(
          {message: "Non riesco a prendere i valori della previsione corrente per copiarli nella tabella daily evolution del file #{Ikigai::Config.file.excel_forecast}",
           detail: err.message,
           location: "#{__FILE__}:#{__LINE__}"}
        )
      end
    end
  end
end
