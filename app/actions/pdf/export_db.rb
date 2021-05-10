#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module PdfActions
  # Esporto il DB2.xlsm nel file DB2.csv
  class ExportDB
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @!method ExportDB
    #   @yield Esporto il DB2.xlsm nel file DB2.csv
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      try! do
        export_db
      end.map_err { ctx.fail_and_return!("Non riesco ad esportare il DB nel file #{Ikigai::Config.file.db_csv}") }
    end
  end
end
