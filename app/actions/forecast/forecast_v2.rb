#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
  class ForecastV2
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects hour [Hash] Ora di cui fare il forecast
    # @expects csv [Array<Hash>] Consuntivi di Steg letti dal DB
    # @expects params [Hamster::Hash] parametri letti da excel
    expects :previsione, :forecast, :forecast_v1, :params
    # @promises forecast [FunctionalLightService::Result] Se finisce con successo forecast [Array<Hash>]
    # @promises forecast2 [FunctionalLightService::Result] Se finisce con successo forecast2 [Array<Hash>]
    promises :previsione2

    # @!method ForecastActions
    #   @yield Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      if ctx.params[:applica_somiglianza] == "NO"
        ctx.previsione2 = ctx.previsione
      else
        ctx.previsione2 ||= PS.to_h { |s| [s, []] }
        totale_prev1 = totale
        ctx.forecast_v1.each do |fcs_hour|
          fcs = forecast2(fcs_hour, totale_prev1)
          PS.each do |ps|
            ctx.previsione2[ps] << media_ponderata(ps, fcs) * 1000
          end
        end
      end
    end

    def self.totale
      ctx.previsione.reduce(0) do |sum, num|
        sum + num[1].sum
      end
    end

    def self.forecast2(fcs, totale_prev1)
      fcs.select do |row|
        flow_rate = row["Flow_Totale"] * 1000
        if totale_prev1 < ctx.params[:nomina_steg]
          flow_rate > totale_prev1
        else
          flow_rate < totale_prev1
        end
      end
    end

    def self.media_ponderata(ps, fcs)
      fcs.then do |forecast|
        forecast.map { |h| [h["Flow_#{ps.capitalize}"], h["Peso"]] }
      end
        .then do |tmp|
        tmp.reduce(0) { |sum, num| sum + num[0] * num[1] } / tmp.reduce(0) { |sum, num| sum + num[1] }
      end
    end

    private_class_method \
      :totale,
      :forecast2,
      :media_ponderata
  end
end
