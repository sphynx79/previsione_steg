#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Inserisce in Excel nel foglio Previsione e Previsione_2 il risultato dei forecast
  class CompilaForecastExcel
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects previsone [Hash] Risultato del forecast per ogni stazione e per ogni ora
    # @expects previsone2 [Hash] Risultato del forecast2 per ogni stazione e per ogni ora
    # @expects workbook [WIN32OLE] File Excel del mio forecast
    expects :previsione, :previsione2, :workbook

    # @!method CompilaForecastExcel
    #   @yield Inserisce in Excel nel foglio Previsione e Previsione_2 il risultato dei forecast
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      compila(ctx.previsione, "Previsione_2")
      compila(ctx.previsione2, "Previsione_2")
    end

    def self.compila(previsione, sheet)
      previsione.each do |k, v|
        column = column(k)
        ctx.workbook.Worksheets(sheet).Range("#{column}3:#{column}26").value = v.each_slice(1).to_a
      end
    end

    def self.column(ps)
      case ps
      when "feriana" then "C"
      when "kasserine" then "D"
      when "zriba" then "E"
      when "nabeul" then "F"
      when "korba" then "G"
      end
    end

    private_class_method :column
  end
end
