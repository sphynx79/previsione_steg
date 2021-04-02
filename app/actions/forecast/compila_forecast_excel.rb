#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Prendo dal file csv tutti i dati consintivi
  class CompilaForecastExcel
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises csv [Array<Hash>] Consuntivi di Steg
    expects :previsione, :previsione2, :workbook

    # @!method ParseCsv
    #   @yield Faccio il parser del Csv per leggere i consuntivi
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      # previsione = sheet == 'Previsione' ? @previsione : @previsione2
      compila(ctx.previsione, "Previsione")
      compila(ctx.previsione2, "Previsione_2")
    end


    def self.compila(previsione, sheet)
      previsione.each do |k, v|
        previsione[k] = v.each_slice(1).to_a
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
