#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module PdfActions
  # Salvo i file Forecast.xlsm | Db.xlsm | DB2.xlsm
  class SaveAllFile
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @!method SaveAllFile
    #   @yield Salvo i file Forecast.xlsm | Db.xlsm | DB2.xlsm
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      save("DB.xlsm")
      save("DB2.xlsm")
      save("Forecast.xlsm")
    end

    def self.save(workbook_name)
      try! do
        save_workbook(workbook_name)
      end.map_err { ctx.fail_and_return!("Non riesco a salvare il file #{workbook_name}") }
    end

    private_class_method :save
  end
end
