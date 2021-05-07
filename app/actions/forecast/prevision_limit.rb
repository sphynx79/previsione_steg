#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Genero gli estremi superiore e inferiore del mio forecast
  class PrevisionLimit
    attr_accessor :totale

    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects hour [Hash] Ora di cui fare il forecast
    # @expects csv [Array<Hash>] Consuntivi di Steg letti dal DB
    # @expects params [Hamster::Hash] parametri letti da excel
    expects :previsione, :filtered_data_group_by_hour, :params
    # @promises forecast [FunctionalLightService::Result] Se finisce con successo forecast [Array<Hash>]
    # @promises forecast2 [FunctionalLightService::Result] Se finisce con successo forecast2 [Array<Hash>]
    promises :previsione_up, :previsione_down

    # @!method ForecastActionsV2
    #   @yield Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      # ctx.filtered_data.value.select { |x| x["Ora"] == 8 }.group_by{|h| h["Flow_Totale"].round(-3)}.map{|k,v| [k, v.size]}.to_h.sort;
      # ctx.filtered_data.value.count / 24 => totale curve
      curve_up, curve_down = limit
      ctx.previsione_up = previsione(curve_up)
      ctx.previsione_down = previsione(curve_down)
    end

    def self.limit
      limit_up = {}
      limit_down = {}
      ctx.filtered_data_group_by_hour.each do |k, v|
        limit_up[k] = v.select do |row|
          (row["Flow_Totale"] * 1000) >= totale
        end
        limit_down[k] = v.select do |row|
          (row["Flow_Totale"] * 1000) < totale
        end
      end
      [limit_up, limit_down]
    end

    def self.previsione(fcs)
      previsione = PS.to_h { |s| [s, []] }
      fcs.each_value do |value|
        PS.each do |ps|
          previsione[ps] << media_ponderata(ps, value) * 1000
        end
      end
      previsione
    end

    def self.totale
      @totale ||= ctx.previsione.reduce(0) do |sum, num|
        sum + num[1].sum
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
      :limit,
      :previsione,
      :totale,
      :media_ponderata
  end
end
