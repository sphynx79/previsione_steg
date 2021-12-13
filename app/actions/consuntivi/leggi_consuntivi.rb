#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ConsuntiviActions
  ##
  # Avvio la macro nel file DB.xlsm che legge i file consuntivi, e li mette nel file stesso
  #
  class LeggiConsuntivi
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    # @!method LeggiConsuntivi(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        raise "Errore imprevisto esecuzione macro" unless leggi_consuntivi
      end.map_err { |err| ctx.fail_and_return!("Errore macro \"LeggiConsuntivi\" file  #{Ikigai::Config.file.db_xls}:\n#{err} | #{__FILE__}:#{__LINE__}") }
    end
  end
end
