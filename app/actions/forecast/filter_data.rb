#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
  #   @expects consuntivi [Array<Hash>] Consuntivi di Steg letti dal DB
  #   @expects params [Hamster::Hash] parametri letti da excel
  #   @promises filtered_data [FunctionalLightService::Result] Se finisce con successo forecast [Array<Hash>]
  class FilterData
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    expects :consuntivi, :params
    promises :filtered_data

    # @!method FilterData
    #   @yield Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
    #   @yieldparam ctx [FunctionalLightService::Context] Input contest
    #   @yieldreturn [FunctionalLightService::Context] Output contest
    executed do |ctx|
      ctx.filtered_data = Success(ctx.consuntivi) \
                     >> method(:filter_giorno) \
                     >> method(:filter_festivo) \
                     >> method(:filter_festivita)
    end

    # Applico questo filtro se nei miei filtri ho impostato che devo selezionare il giorno esatto della settimana
    #
    # @param consuntivi [Array<Hash>] Consuntivi di Steg letti dal DB
    #
    # @return [FunctionalLightService::Result::Success]
    # @TODO: Gestire glie errori del filtro giorno della settimana estatto
    def self.filter_giorno(consuntivi)
      Success(ctx.params[:giorno_settimana] == "SI" ? consuntivi.select { |row| row["Giorno_Sett_Num"] == ctx.params[:day].value.first["Giorno_Sett_Num"] } : consuntivi)
    end

    # Applico il filtro che mi seleziona se è un festivo o un settimanale
    #
    # @param consuntivi [Array<Hash>] Consuntivi di Steg letti dal DB
    #
    # @return [FunctionalLightService::Result::Success]
    # @TODO: Gestire glie errori del filtro festivo
    def self.filter_festivo(consuntivi)
      case ctx.params[:festivo]
      when "SI"
        Success(consuntivi.select { |row| row["Festivo"] == "Y" })
      when "NO"
        Success(consuntivi.select { |row| row["Festivo"] == "N" })
      else
        Success(consuntivi)
      end
    end

    # Applico il filtro che mi seleziona se è una festivvità
    #
    # @param consuntivi [Array<Hash>] Consuntivi di Steg letti dal DB
    #
    # @return [FunctionalLightService::Result::Success]
    # @TODO: Gestire glie errori del filtro festività
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

    private_class_method \
      :filter_giorno,
      :filter_festivo,
      :filter_festivita
  end
end
