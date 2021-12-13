#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  ##
  # Prendo dal file csv tutti i dati consuntivi
  #
  # <div class="lsp">
  #   <h2>Promises:</h2>
  #   - consuntivi (Array(Hash)) Consuntivi di Steg<br>
  # </div>
  #
  class ParseCsv
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Csv
    extend FunctionalLightService::Action

    promises :consuntivi

    # @!method ParseCsv(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @promises consuntivi [Array<Hash>] Consuntivi di Steg
    #
    #   @example promises consuntivi value
    #       [
    #          [0] {
    #           "Date"            => #<DateTime: 2015-10-20T08:00:00+00:00 ((2457316j,28800s,0n),+0s,2299161j)>,
    #           "Giorno"          => 20,
    #           "Mese"            => 10,
    #           "Anno"            => 2015,
    #           "Ora"             => 8,
    #           "Giorno_Sett_Num" => 2,
    #           "Festivo"         => "N",
    #           "Festivita"       => "N",
    #           "Stagione"        => "autunno",
    #           "Exclude"         => "N",
    #           "Peso"            => 1.0,
    #           "Flow_Feriana"    => 70.0,
    #           "Flow_Kasserine"  => 1.0,
    #           "Flow_Zriba"      => 256.0,
    #           "Flow_Nabeul"     => 49.0,
    #           "Flow_Korba"      => 7.0,
    #           "Flow_Totale"     => 9235.0
    #         }
    #       ]
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        ctx.consuntivi = IceNine.deep_freeze!(parse_csv.reject { |row| row["Exclude"] == "Y" })
      end.map_err { ctx.fail_and_return!("Non riesco a leggere il file DB2.csv controllare di avere fatto l'esportazione del database") }
      ctx.fail_and_return!("Controllare che nel file DB2.csv siano presenti i dati esportortati dal DB") if ctx.consuntivi.nil?
    end
  end
end
