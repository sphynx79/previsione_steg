#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Prendo da excel tutti i dati di input
  class FilterData
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises excel [WIN32OLE]
    # @promises workbook [WIN32OLE]
    # promises :excel
    expects :hour, :consuntivi, :params
    promises :forecast, :forecast2

    # @!method ConnecWIN32OLEtExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      # filter_giorno
      ctx.forecast = Success(ctx.consuntivi) \
                     >> method(:filter_ora) \
                     >> method(:filter_giorno) \
                     >> method(:filter_festivo) \
                     >> method(:filter_festivita)
      ctx.forecast2 = ctx.params[:applica_somiglianza] == "SI" ? Success(forecast2(ctx.forecast.value)) : Success(nil)
    end

    def self.filter_ora(consuntivi)
      # binding.pry
      Success(consuntivi.select { |row| row["Ora"] == ctx.hour["Ora"] })
    end

    def self.filter_giorno(consuntivi)
      # binding.pry
      Success(ctx.params[:giorno_settimana] == "SI" ? consuntivi.select { |row| row["Giorno_Sett_Num"] == ctx.hour["Giorno_Sett_Num"] } : consuntivi)
    end

    def self.filter_festivo(consuntivi)
      # binding.pry
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
      # binding.pry
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
      curve_simili = []
      step = 0.0
      while curve_simili.empty?
        curve_simili = fcs.select { |row| row["Flow_Totale"].between?(soglia_down(step), soglia_up(step)) }
        step += 0.01
      end
      curve_simili
    end

    def self.soglia_up(step)
      (ctx.params[:nomina_steg] * (1 + ctx.params[:soglia_sensibilita] + step)) / 1000
    end

    def self.soglia_down(step)
      (ctx.params[:nomina_steg] * (1 - ctx.params[:soglia_sensibilita] + step)) / 1000
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
