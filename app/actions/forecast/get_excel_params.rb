#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Prendo da excel tutti i dati di input per eseguire il Forecast
  class GetExcelParams
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises params [Hash]
    promises :params

    # @!method ConnectExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      ctx.params = Hamster::Hash[day: get_day,
                                 giorno_settimana: get_giorno_settimana,
                                 festivo: get_festivo,
                                 festivita: get_festivita,
                                 nomina_steg: get_nomina_steg,
                                 ]
      ctx.params
    end

    # Prendo da "Forecast.xlsm" foglio "Day" la tabella con nome Day, che contiene il giorno di cui devo fare il forecast
    #
    # @return [Array] Ogni elemento dell'Array è un'ora del forecast che devo fare
    def self.get_day
      try! do
        day
      end.map_err { ctx.fail_and_return!("Controllare che nel file Forecast.xlsm ci sia il foglio Day con presenta la tabella Day") }
    end

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

    def self.get_nomina_steg
      # binding.pry
      unless nomina_steg.is_a?(Float)
        ctx.fail_and_return!(
          <<~HEREDOC
            Controllare che nel file: Forecast.xlsm 
            Foglio: "Forecast V1"
            Nomina STEG cella K32: ci sia la sommatoria delle PS nella nomina di STEG 
          HEREDOC
        )
      end
      nomina_steg
    end

    private_class_method \
      :get_day,
      :get_giorno_settimana,
      :get_festivo,
      :get_festivita,
      :get_nomina_steg
  end
end
