#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Compila in il file Forecast,xlsm con la mia previsone
  #   @expects previsone [Hash] Risultato del forecast per ogni stazione e per ogni ora
  #   @expects previsione_up [Hash] Limite superiore del mio forecast
  #   @expects previsione_down [Hash] Limite inferiore del mio forecast
  #   @expects previsione_down [Hash] Dispersione di tutte le curve forecast che hanno contribuito a fare il forecast
  #   @expects workbook [WIN32OLE] File Excel del mio forecast
  class CompilaForecastExcel
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    expects \
      :previsione,
      :previsione_up,
      :previsione_down,
      :dispersione,
      :workbook

    # @!method CompilaForecastExcel
    #   @yield Compila in il file Forecast,xlsm con la mia previsone
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      compila(ctx.previsione, "Previsione")
      compila(ctx.previsione_down, "Previsione_Down")
      compila(ctx.previsione_up, "Previsione_UP")
      compila_dispersione
    end

    def self.compila(previsione, sheet)
      previsione.each do |ps, v|
        column = column(ps)
        ctx.workbook.Worksheets(sheet).Range("#{column}3:#{column}26").value = v.each_slice(1).to_a
      end
    end

    def self.compila_dispersione
      ctx.workbook.Worksheets("Previsione_Dispersione").Range("B3:I10000").ClearContents
      # ctx.workbook.Worksheets("Previsione_Dispersione").Range("B3:B#{ctx.dispersione["anno"].size + 2}").value = ctx.dispersione["anno"]
      # ctx.workbook.Worksheets("Previsione_Dispersione").Range("B3:B#{ctx.dispersione[2015].size + 2}").value = ctx.dispersione[2015]
      first_cell = 3
      last_cell = 0
      ctx.dispersione.each do |k, v|
        if k == "anno"
          ctx.workbook.Worksheets("Previsione_Dispersione").Range("B3:B#{ctx.dispersione["anno"].size + 2}").value = ctx.dispersione["anno"]
        else
          first_cell = last_cell == 0 ? 3 : last_cell + 1
          last_cell += last_cell == 0 ? ctx.dispersione[k].size + 2 : ctx.dispersione[k].size
          column = case k
                   when 2015 then "C"
                   when 2016 then "D"
                   when 2017 then "E"
                   when 2018 then "F"
                   when 2019 then "G"
                   when 2020 then "H"
                   when 2021 then "I"
                   when 2022 then "J"
                   when 2023 then "K"
                   when 2024 then "L"
                   when 2025 then "M"
          end
          ctx.workbook.Worksheets("Previsione_Dispersione").Range("#{column}#{first_cell}:#{column}#{last_cell}").value = ctx.dispersione[k]
        end
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

    private_class_method \
      :column,
      :compila,
      :compila_dispersione
  end
end
