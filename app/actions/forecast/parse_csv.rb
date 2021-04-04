#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Prendo dal file csv tutti i dati consintivi
  class ParseCsv
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises csv [Array<Hash>] Consuntivi di Steg
    promises :consuntivi

    # @!method ParseCsv
    #   @yield Faccio il parser del Csv per leggere i consuntivi
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      try! do
        # ctx.consuntivi = (parse_csv.reject { |row| row["Exclude"] == "Y" }).freeze
        # ctx.consuntivi = Hamster::Vector.new(parse_csv.reject { |row| row["Exclude"] == "Y" })
        ctx.consuntivi = IceNine.deep_freeze!(parse_csv.reject { |row| row["Exclude"] == "Y" })
        # @todo: inserire nel config il path del file csv e qui nel messaggio di errore
      end.map_err { ctx.fail_and_return!("Non riesco a leggere il file DB2.csv controllare di avere fatto l'esportazione del database") }
      ctx.fail_and_return!("Controllare che nel file DB2.csv siano presenti i dati esportortati dal DB") if ctx.consuntivi.nil?
    end
  end
end
