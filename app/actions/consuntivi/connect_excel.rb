#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ConsuntiviActions
  # Mi connetto al file Excel del forecast
  class ConnectExcel
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises excel [WIN32OLE]
    # @promises workbook [WIN32OLE]
    promises :excel, :workbook

    # @!method ConnectExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      try! do
        ctx.excel = conneti_excel.freeze
        ctx.workbook = conneti_workbook(Ikigai::Config.file.db_xls).freeze
      end.map_err { ctx.fail_and_return!("Non riesco a connetermi al file #{Ikigai::Config.file.db_xls}, controllare che sia aperto") }
    end
  end
end
