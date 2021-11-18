#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Esegue la media ponderata dei dati filtrati nelo step precedente e crea la mia previsione
  #
  # @expects filtered_data_group_by_hour [FunctionalLightService::Result]
  #   Se finisce con successo forecast [Array<Hash>]
  #
  # @promises previsione [<Hash>]
  #   Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione
  #
  # @example promises [previsone]
  #   previsone = {"feriana"=>[28513.707674943573, 30426.730663741077],
  #                "kasserine"=>[5293.154627539503, 5158.996160175534],
  #                "zriba"=>[236252.539503386, 251786.7526055952],
  #                "nabeul"=>[79220.02257336344, 87046.02303894682],
  #                "korba"=>[5760.112866817157, 6106.385079539223]}
  class Previsione
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    expects :filtered_data_group_by_hour
    promises :previsione

    # @!method Previsione
    #
    #   @yield
    #     Esegue la media ponderata dei dati filtrati nello step precedente e crea la mia previsione
    #
    #   @yieldparam ctx [FunctionalLightService::Context]
    #     Input contest
    #
    #   @yieldreturn [FunctionalLightService::Context]
    #     Output contest
    executed do |ctx|
      # @type ctx.previsione [Hash]
      ctx.previsione ||= PS.to_h { |s| [s, []] }
      ctx.filtered_data_group_by_hour.each_value do |fcs_hour|
        PS.each do |ps|
          ctx.previsione[ps] << media_ponderata(ps, fcs_hour) * 1000
        end
      end
    end

    # Esegue la media ponderata pesata per la stazione passata come parametro, di tutti i consuntivi filtrati
    #
    # @param ps [String]
    #   Ps di cui devo fare la media ponderata
    #
    # @param fcs_hour [Array]
    #   Contiene tutti i dati filtrati per una specifica ora
    #
    # @return [Float]
    def self.media_ponderata(ps, fcs_hour)
      fcs_hour.then do |forecast|
        forecast.map { |h| [h["Flow_#{ps.capitalize}"], h["Peso"]] }
      end
        .then do |tmp|
        tmp.reduce(0) { |sum, num| sum + num[0] * num[1] } / tmp.reduce(0) { |sum, num| sum + num[1] }
      end
    end

    private_class_method :media_ponderata
  end
end
