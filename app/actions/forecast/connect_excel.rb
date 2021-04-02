#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Prendo da excel tutti i dati di input
  class ConnectExcel
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises excel [WIN32OLE]
    # @promises workbook [WIN32OLE]
    promises :excel, :workbook

    # @!method ConnecWIN32OLEtExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      ctx.excel = conneti_excel.freeze
      ctx.workbook = conneti_workbook.freeze
    end
  end
end
