#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Calcolo la dispersione delle curve
  class Dispersione

    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects hour [Hash] Ora di cui fare il forecast
    # @expects csv [Array<Hash>] Consuntivi di Steg letti dal DB
    # @expects params [Hamster::Hash] parametri letti da excel
    expects \
      :filtered_data_group_by_hour,
      :previsione_up,
      :previsione_down

    promises \
      :dispersione,
      :totale_num_curve,
      :down_limit,
      :upper_limit,
      :num_curve_upper_limit,
      :num_curve_down_limit

    # @!method Dispersione
    #   @yield Calcolo la dispersione delle curve
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      ctx.upper_limit = totale(ctx.previsione_up)
      ctx.down_limit = totale(ctx.previsione_down)
      ctx.totale_num_curve = ctx.filtered_data_group_by_hour[8].size
      ctx.num_curve_upper_limit = ctx.filtered_data_group_by_hour[8].count { |x| x["Flow_Totale"] * 1000 > ctx.upper_limit }
      ctx.num_curve_down_limit = ctx.filtered_data_group_by_hour[8].count { |x| x["Flow_Totale"] * 1000 < ctx.down_limit }
      anno = ctx.filtered_data_group_by_hour[8].map { |w| w["Anno"] }.each_slice(1).to_a

      group_by_year = ctx.filtered_data_group_by_hour[8].group_by { |h| h["Anno"] }
      ctx.dispersione = {"anno" => anno}

      group_by_year.each do |k, v|
        ctx.dispersione[k] = v.map do |w|
          w["Flow_Totale"] * 1000
        end.each_slice(1).to_a
      end
      # ctx.dispersione = ctx.filtered_data_group_by_hour[8].group_by { |h| h["Flow_Totale"].round(-2) }.map { |k, v| [k, v.size] }.to_h.sort
    end

    def self.totale(prv)
      prv.reduce(0) do |sum, num|
        sum + num[1].sum
      end
    end

    private_class_method \
      :totale
  end
end
