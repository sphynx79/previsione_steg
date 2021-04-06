#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ConsuntiviActions
  # Mi connetto al file Excel del forecast
  class LeggiConsuntivi
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises excel [WIN32OLE]
    # @promises workbook [WIN32OLE]
    # promises :excel, :workbook

    # @!method ConnectExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      try! do
        raise "Errore imprvisto esecuzione macro" unless leggi_consuntivi
      end.map_err { |err| ctx.fail_and_return!("Errore macro \"LeggiConsuntivi\" file  #{Ikigai::Config.file.db_xls}:\n#{err}") }
    end
  end
end
