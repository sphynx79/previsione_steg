#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Prendo dal file csv tutti i dati consintivi
  class MediaPonderata
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises csv [Array<Hash>] Consuntivi di Steg
    expects :forecast, :forecast2
    promises :previsione, :previsione2

    # @!method ParseCsv
    #   @yield Faccio il parser del Csv per leggere i consuntivi
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      ctx.previsione ||= PS.to_h { |s| [s, []] }
      ctx.previsione2 ||= PS.to_h { |s| [s, []] }
      PS.each do |ps|
        ctx.previsione[ps] << media_ponderata(ps, ctx.forecast) * 1000
        ctx.previsione2[ps] << (ctx.forecast2.value.nil? ? ctx.previsione[ps].last : media_ponderata(ps, ctx.forecast2) * 1000)
      end
    end

    def self.media_ponderata(ps, fcs)
      fcs.value
        .then do |forecast|
          forecast.map { |h| [h["Flow_#{ps.capitalize}"], h["Peso"]] }
        end
        .then do |tmp|
          tmp.reduce(0) { |sum, num| sum + num[0] * num[1] } / tmp.reduce(0) { |sum, num| sum + num[1] }
        end
    end

    private_class_method :media_ponderata

    
  end
end