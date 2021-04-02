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
      ctx.consuntivi = (parse_csv.reject { |row| row["Exclude"] == "Y" }).freeze
    end
  end
end
