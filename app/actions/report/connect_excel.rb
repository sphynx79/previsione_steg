#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  ##
  # Mi connetto al file Excel del forecast
  #
  # <div class="lsp">
  #   <h2>Promises:</h2>
  #   - excel (WIN32OLE)<br>
  #   - workbook (WIN32OLE)<br>
  # </div>
  #
  class ConnectExcel
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    promises :excel, :workbook

    # @!method ConnectExcel(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @promises excel [WIN32OLE]
    #   @promises workbook [WIN32OLE]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        ctx.excel = conneti_excel.freeze
        ctx.workbook = conneti_workbook(Ikigai::Config.file.excel_forecast).freeze
      end.map_err do |err|
        ctx.fail_and_return!(
          {message: "Non riesco a connetermi al file #{Ikigai::Config.file.excel_forecast}, controllare che sia aperto",
           detail: err.message,
           location: "#{__FILE__}:#{__LINE__}"}
        )
      end
    end
  end
end
