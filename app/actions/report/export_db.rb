#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ReportActions
  ##
  # Esporto il DB2.xlsm nel file DB2.csv
  #
  class ExportDB
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    # @!method ExportDB(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        export_db
      end.map_err do |err|
        ctx.fail_and_return!(
          {message: "Non riesco ad esportare il DB nel file #{Ikigai::Config.file.db_csv}",
           detail: err.message,
           location: "#{__FILE__}:#{__LINE__}"}
        )
      end
    end
  end
end
