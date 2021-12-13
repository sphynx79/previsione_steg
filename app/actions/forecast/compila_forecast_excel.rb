#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  ##
  # Compila in il file Forecast,xlsm con la mia previsone
  #
  # <div class="lsp">
  #   <h2>Expects:</h2>
  #   - previsione (Hash(Array)) Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione<br>
  #   - previsione_up (Hash(Array)) Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione<br>
  #   - previsione_down (Hash(Array)) Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione<br>
  #   - dispersione (Hash(Array)) Mette in un hash la mia disperzione, nel quale ogni chiave e un anno, e i valoru sono un array con tutti le curve relative a quell'anno<br>
  #   - workbook (WIN32OLE)<br>
  # </div>
  #
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

    # @!method CompilaForecastExcel(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @expects previsione [Hash<Array>] la mia previsione ogni chiave dell'Hash è una stazione
    #   @expects previsione_up [Hash<Array>] contiene tutte le curve suddivise per stazione che sono sopra la mia previsione
    #   @expects previsione_down [Hash<Array>] contiene tutte le curve suddivise per stazione che sono sotto la mia previsione
    #   @expects dispersione [Hash<Array>] hash della disperzione, nel quale ogni chiave e un anno, e i valori sono un array con tutti le curve relative a quell'anno
    #   @expects workbook [WIN32OLE] file excel del mio forecast
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      compila(ctx.previsione, "Previsione")
      compila(ctx.previsione_down, "Previsione_Down")
      compila(ctx.previsione_up, "Previsione_UP")
      compila_dispersione
    end

    # compila il relativo foglio del file forecast con la previsione passata come parametro
    #
    # @param previsione [Hash<Array>] previsione
    # @param sheet [String] foglio da selezionare
    #
    # @return [Void]
    def self.compila(previsione, sheet)
      try! do
        previsione.each do |ps, v|
          column = column(ps)
          ctx.workbook.Worksheets(sheet).Range("#{column}3:#{column}26").alue = v.each_slice(1).to_a
        end
      end.map_err { Failure("Non riesco a compilare la #{previsione} | #{__FILE__}:#{__LINE__}") }
    end

    # compila il foglio della dispersione del file forecast
    #
    # @return [Void]
    def self.compila_dispersione
      try! do
        ctx.workbook.Worksheets("Previsione_Dispersione").Range("B3:I10000").ClearContents
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
      end.map_err { Failure("Non riesco a compilare la disperzione delle curve | #{__FILE__}:#{__LINE__}") }
    end

    # seleziona la colonna relativa alla ps
    #
    # @param ps [String]
    #
    # @return [String]
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
