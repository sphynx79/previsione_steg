#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Prendo da excel tutti i dati di input
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
      ctx.params = Hamster::Hash[day_hours: get_day_hours,
                                 giorno_settimana: get_giorno_settimana,
                                 festivo: get_festivo,
                                 festivita: get_festivita,
                                 applica_somiglianza: get_applica_somiglianza,
                                 nomina_steg: get_nomina_steg,
                                 soglia_sensibilita: get_soglia_sensibilita]
    end

    def self.get_day_hours
      ctx.fail_and_return!("Controllare che nel file Forecast.xlsm ci sia il foglio Day con presenta la tabella Day") if day_hours.size != 24
      day_hours
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

    def self.get_applica_somiglianza
      unless ["SI", "NO"].include? applica_somiglianza
        ctx.fail_and_return!(
          <<~HEREDOC
            Controllare che nel file: Forecast.xlsm 
            Foglio: "Forecast V2"
            Ranking somiglianza: ci sia "SI" o "NO"
          HEREDOC
        )
      end
      applica_somiglianza
    end

    def self.get_nomina_steg
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

    def self.get_soglia_sensibilita
      unless soglia_sensibilita.is_a?(Float)
        ctx.fail_and_return!(
          <<~HEREDOC
            Controllare che nel file: Forecast.xlsm 
            Foglio: "Forecast V2"
            Ranking somiglianza cella N4: ci sia la percentuale del ranking di somiglianza
          HEREDOC
        )
      end
      soglia_sensibilita
    end

    private_class_method \
      :get_day_hours,
      :get_giorno_settimana,
      :get_festivo,
      :get_festivita,
      :get_applica_somiglianza,
      :get_nomina_steg,
      :get_soglia_sensibilita
  end
end
