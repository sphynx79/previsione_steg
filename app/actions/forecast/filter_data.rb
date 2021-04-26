#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
  class FilterData
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects hour [Hash] Ora di cui fare il forecast
    # @expects csv [Array<Hash>] Consuntivi di Steg letti dal DB
    # @expects params [Hamster::Hash] parametri letti da excel
    expects :hour, :consuntivi, :params
    # @promises forecast [FunctionalLightService::Result] Se finisce con successo forecast [Array<Hash>]
    # @promises forecast2 [FunctionalLightService::Result] Se finisce con successo forecast2 [Array<Hash>]
    promises :forecast, :forecast_v1
    

    # @!method ForecastActions
    #   @yield Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      ctx.forecast_v1 ||= []
      ctx.forecast = Success(ctx.consuntivi) \
                     >> method(:filter_ora) \
                     >> method(:filter_giorno) \
                     >> method(:filter_festivo) \
                     >> method(:filter_festivita)
      ctx.forecast_v1 << ctx.forecast.value
      # ctx.forecast2 = ctx.params[:applica_somiglianza] == "SI" ? Success(forecast2(ctx.forecast.value)) : Success(nil)
    end

    def self.filter_ora(consuntivi)
      Success(consuntivi.select { |row| row["Ora"] == ctx.hour["Ora"] })
    end

    def self.filter_giorno(consuntivi)
      Success(ctx.params[:giorno_settimana] == "SI" ? consuntivi.select { |row| row["Giorno_Sett_Num"] == ctx.hour["Giorno_Sett_Num"] } : consuntivi)
    end

    def self.filter_festivo(consuntivi)
      case ctx.params[:festivo]
      when "SI"
        Success(consuntivi.select { |row| row["Festivo"] == non_festivo? })
      when "NO"
        Success(consuntivi.select { |row| row["Festivo"] == festivo? })
      else
        Success(consuntivi)
      end
    end

    def self.filter_festivita(consuntivi)
      case ctx.params[:festivita]
      when "SI"
        Success(consuntivi.select { |row| row["Festivita"] == "Y" })
      when "NO"
        Success(consuntivi.select { |row| row["Festivita"] == "N" })
      else
        Success(consuntivi)
      end
    end

    def self.festivo?
      ctx.hour["Giorno_Sett_Num"] == 6 && ctx.hour["Ora"].between?(0, 7) ? "Y" : "N"
    end

    def self.non_festivo?
      ctx.hour["Giorno_Sett_Num"] == 1 && ctx.hour["Ora"].between?(0, 7) ? "N" : "Y"
    end

    def self.forecast2(fcs)
      fcs.select do |row|
        flow_rate = row["Flow_Totale"]
        flow_rate.between?(soglia_down(flow_rate), soglia_up(flow_rate))
      end
    end

    def self.soglia_up(flow_rate)
      return flow_rate if ctx.params[:nomina_steg] < flow_rate
      200000
      # (ctx.params[:nomina_steg] * (1 + ctx.params[:soglia_sensibilita] + step)) / 1000
    end

    def self.soglia_down(flow_rate)
      return flow_rate if ctx.params[:nomina_steg] > flow_rate
      0
      # (ctx.params[:nomina_steg] * (1 - ctx.params[:soglia_sensibilita] + step)) / 1000
    end

    private_class_method \
      :filter_ora,
      :filter_giorno,
      :filter_ora,
      :filter_festivo,
      :festivo?,
      :non_festivo?,
      :filter_festivita,
      :forecast2,
      :soglia_up,
      :soglia_down
  end
end
