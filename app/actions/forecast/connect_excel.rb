#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  ##
  # Mi connetto al file Excel del forecast
  #
  # <div class="lsp">
  #   <h2>Promises:</h2>
  #   - excel ('WIN32OLE')<br>
  #   - workbook ('WIN32OLE')<br>
  # </div>
  #
  class ConnectExcel
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    promises :excel, :workbook

    # @!method ConnectExcel(ctx)
    #   Mi connetto al file Excel del forecast
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @promises excel [WIN32OLE]
    #   @promises workbook [WIN32OLE]
    #
    #   @return [FunctionalLightService::Context]
    executed do |ctx|
      try! do
        # @type ctx.excel [WIN32OLE]
        ctx.excel = conneti_excel.freeze
        # @type ctx.workbook [WIN32OLE]
        ctx.workbook = conneti_workbook(Ikigai::Config.file.excel_forecast).freeze
      end.map_err { ctx.fail_and_return!("Non riesco a connetermi al file #{Ikigai::Config.file.excel_forecast}, controllare che sia aperto") }
    end
  end
end
