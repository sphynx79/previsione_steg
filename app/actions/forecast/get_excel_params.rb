#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  ##
  # Prendo da excel tutti i dati di input per eseguire il Forecast
  #
  # <div class="lsp">
  #   <h2>Promises:</h2>
  #   - params ('Hash')<br>
  # </div>
  #
  # @promises params [Hash]
  #
   #
  class GetExcelParams
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    promises :params

    # @!method GetExcelParams(ctx)
    #   Prendo da excel tutti i dati di input per eseguire il Forecast
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @promises params [Hash]
    #
    #   @return [FunctionalLightService::Context]
    executed do |ctx|
      ctx.params = Hamster::Hash[day: get_day,
        giorno_settimana: get_giorno_settimana,
        festivo: get_festivo,
        festivita: get_festivita,
      ]
      ctx.params
    end

    # Prendo da "Forecast.xlsm" foglio "Day" la tabella con nome Day, che contiene il giorno di cui devo fare il forecast
    #
    # @return [Array]
    #  Contiene le caratteristiceh del giorno che devo fare il forecast, tipo il giorno settimana, se è un festivo, ecc..
    def self.get_day
      try! do
        day
      end.map_err { ctx.fail_and_return!("Controllare che nel file Forecast.xlsm ci sia il foglio Day con presenta la tabella Day") }
    end

    # Prendo da "Forecast.xlsm" foglio "Forecast V1" se devo prendere un giorno della settima esatto
    #
    # @return [String] Se è un giorno della settimana esatto ["SI", "NO"]
    def self.get_giorno_settimana
      unless ["SI", "NO"].include? giorno_settimana
        ctx.fail_and_return!(
          <<~HEREDOC
            Controllare che nel file: Forecast.xlsm 
            Foglio: "Forecast V1"
            Giorno Settimana esatto: ci sia "SI" o "NO"
          HEREDOC
        )
      end
      giorno_settimana
    end

    # Prendo da "Forecast.xlsm" foglio "Forecast V1" se è un giorno festivo
    #
    # @return [String] Se è un giorno festivo ["SI", "NO", "ALL"]
    def self.get_festivo
      unless ["SI", "NO", "ALL"].include? festivo
        ctx.fail_and_return!(
          <<~HEREDOC
            Controllare che nel file: Forecast.xlsm 
            Foglio: "Forecast V1"
            Festivo: ci sia "SI" o "NO" o "ALL"
          HEREDOC
        )
      end
      festivo
    end

    # Prendo da "Forecast.xlsm" foglio "Forecast V1" se è un festività
    #
    # @return [String] Se è una festività ["SI", "NO", "ALL"]
    def self.get_festivita
      unless ["SI", "NO", "ALL"].include? festivita
        ctx.fail_and_return!(
          <<~HEREDOC
            Controllare che nel file: Forecast.xlsm 
            Foglio: "Forecast V1"
            Festivita: ci sia "SI" o "NO" o "ALL"
          HEREDOC
        )
      end
      festivita
    end

    private_class_method \
      :get_day,
      :get_giorno_settimana,
      :get_festivo,
      :get_festivita
  end
end
