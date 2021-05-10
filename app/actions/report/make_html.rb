#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  # Crea l'HTML da inserire nel body dell'email
  class MakeHtml
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects forecast [FunctionalLightService::Result] Consuntivi filtrati nello Step precedente per il forecast
    # @expects forecast2 [FunctionalLightService::Result] Consuntivi filtrati nello Step precedente per il forecast2
    # expects :forecast
    # @promises previsione [Hash] In questa variabile inserisco il risultato del forecast per ogni stazione e per ogni ora
    # @promises previsione2 [Hash] In questa variabile inserisco il risultato del forecast per ogni stazione e per ogni ora
    #
    # previsone = {"feriana"=>[28513.707674943573, 30426.730663741077],
    #              "kasserine"=>[5293.154627539503, 5158.996160175534],
    #              "zriba"=>[236252.539503386, 251786.7526055952],
    #              "nabeul"=>[79220.02257336344, 87046.02303894682],
    #              "korba"=>[5760.112866817157, 6106.385079539223]}
    promises :html

    # @!method MediaPonderata
    #   @yield Faccio il parser del Csv per leggere i consuntivi
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      # rubocop:disable Layout/ExtraSpacing
      prv_1        = number_with_delimiter(previsione_v1)
      prv_2        = number_with_delimiter(previsione_v2) + " (#{(previsione_v2_delta * 100).round(2)}%)"
      prv_3        = number_with_delimiter(previsione_v3) + " (#{(previsione_v3_delta * 100).round(2)}%)"
      prv_nom_steg = number_with_delimiter(previsione_nomina_steg)
      prv_consunto = number_with_delimiter(previsione_consuntivi)
      html = ERB.new(File.read("./template/report.html.erb"), trim_mode: "-").result(binding)
      ctx.html = html.freeze
      # rubocop:enable Layout/ExtraSpacing
    end

    def self.number_with_delimiter(number)
      number.to_s.gsub!(/(\d)(?=(\d\d\d)+(?!\d))/) do |digit_to_delimit|
        "#{digit_to_delimit}."
      end
    end

    private_class_method :number_with_delimiter
  end
end
