#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

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
      ctx.params = {day_hours: day_hours,
                    giorno_settimana: giorno_settimana,
                    festivo: festivo,
                    festivita: festivita,
                    applica_somiglianza: applica_somiglianza,
                    nomina_steg: nomina_steg,
                    soglia_sensibilita: soglia_sensibilita}.freeze
    end
  end
end
