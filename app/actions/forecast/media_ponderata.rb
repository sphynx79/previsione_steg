#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Esegue la media ponderata dei dati filtrati nelo step precedente e li aggiundo alla mia previsione
  class MediaPonderata
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects forecast [FunctionalLightService::Result] Consuntivi filtrati nello Step precedente per il forecast
    # @expects forecast2 [FunctionalLightService::Result] Consuntivi filtrati nello Step precedente per il forecast2
    expects :forecast
    # @promises previsione [Hash] In questa variabile inserisco il risultato del forecast per ogni stazione e per ogni ora
    # @promises previsione2 [Hash] In questa variabile inserisco il risultato del forecast per ogni stazione e per ogni ora
    #
    # previsone = {"feriana"=>[28513.707674943573, 30426.730663741077],
    #              "kasserine"=>[5293.154627539503, 5158.996160175534],
    #              "zriba"=>[236252.539503386, 251786.7526055952],
    #              "nabeul"=>[79220.02257336344, 87046.02303894682],
    #              "korba"=>[5760.112866817157, 6106.385079539223]}
    promises :previsione

    # @!method MediaPonderata
    #   @yield Faccio il parser del Csv per leggere i consuntivi
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      ctx.previsione ||= PS.to_h { |s| [s, []] }
      # ctx.previsione2 ||= PS.to_h { |s| [s, []] }
      PS.each do |ps|
        ctx.previsione[ps] << media_ponderata(ps, ctx.forecast) * 1000
        # ctx.previsione2[ps] << (ctx.forecast2.value.nil? ? ctx.previsione[ps].last : media_ponderata(ps, ctx.forecast2) * 1000)
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
