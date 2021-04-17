#!/usr/bin/peek_definitionenv ruby
# warn_indent: true
# frozen_string_literal: true

PS = %w[feriana kasserine zriba nabeul korba].freeze

# Crea il Forecast
#
# Utilizzo questa classe per avviare le azioni
# per il calcolo del forecast, inoltre gestisco
# qualsiasi errore che possa essere avvenuto dentro le varie
# azioni eseguite, in caso di errore imprevisto viene gestino
# da qui e viene stamnpato il log e inviata un'email di notifica
class ForecastController < Ikigai::BaseController
  # @!parse
  #   extend FunctionalLightService::Organizer
  #   include ShareAction
  #   include ForecastActions
  extend FunctionalLightService::Organizer
  include ShareActions
  include ForecastActions

  # Entry point chiamato per avviare il forecast
  #
  # @param env [Hash] Enviroment della mia applicazione
  # @option env [String] :controller Controller chiamato
  # @option env [String] :action Entry point del mio controller da eseguire
  # @option env [Hash] :command_options parametri della mia azione da eseguire
  # @option env [Hash] :global_options parametri globali dell'applicazione
  #
  # @example :env params
  #   {
  #     :controller      => "forecast",
  #     :action          => "call",
  #     :command_options => {
  #       "dt"  => "09/04/2021",
  #       :dt   => "09/04/2021",
  #       "day" => "09/04/2021",
  #       :day  => "09/04/2021"
  #     },
  #     :global_options  => {
  #       "l"          => "info",
  #       :l           => "info",
  #     }
  #   }
  #
  # @return [void]
  def self.call(env:)
    result = with(env: env).reduce(steps)
    check_result(result)
    nil
  rescue => e
    msg = e.message + "\n"
    e.backtrace.each { |x| msg += x + "\n" if x.include? APP_NAME } # msg += x + "\n"
    log.fatal msg
    # RemitLinee::Mail.call("Errore imprevisto nella lettura XML", msg) if env[:global_options][:mail]
    exit 1
  end

  # Azioni eseguite in serie per il calcolo del Forecast
  #
  # {ForecastActions::ConnectExcel ConnectExcel}
  # Mi connetto ad excel
  #    @promises excel [WIN32OLE] Instance Excel
  #    @promises workbook [WIN32OLE] Instance Excel del file excel del Forecast
  #
  # {ShareActions::SetExcelDay SetExcelDay}
  # Setta nel file excel del Forecast la data
  #    @promises data [String] Contiene la data es. "09042021"
  #
  # {ForecastActions::GetExcelParams GetExcelParams}
  # Prendo da excel tutti i dati di input per eseguire il Forecast
  #    @promises params [Hash]
  #
  # {ForecastActions::ParseCsv ParseCsv}
  # Prendo dal file csv tutti i dati consuntivi
  #    @promises csv [Array<Hash>] Consuntivi di Steg
  #
  # {ForecastActions::IterateHours IterateHours}
  # Itero sulle ore del giorno del Forecast che devo fare ed eseguo [FilterData, MediaPonderata]
  #    @expects params [Hamster::Hash] parametri letti da excel
  #    @expects callback [Proc] le azioni da eseguire per ogni ora
  #    @promises hour [Hash] Ora di cui fare il forecast
  #
  # {ForecastActions::FilterData FilterData}
  # Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
  #    @expects hour [Hash] Ora di cui fare il forecast
  #    @expects csv [Array<Hash>] Consuntivi di Steg letti dal DB
  #    @expects params [Hamster::Hash] parametri letti da excel
  #    @promises forecast [FunctionalLightService::Result] Se finisce con successo forecast [Array<Hash>]
  #    @promises forecast2 [FunctionalLightService::Result] Se finisce con successo forecast2 [Array<Hash>]
  #
  # {ForecastActions::MediaPonderata MediaPonderata}
  # Esegue la media ponderata dei dati filtrati nelo step precedente e li aggiundo alla mia previsione
  #    @expects forecast [FunctionalLightService::Result] Consuntivi filtrati nello Step precedente per il forecast
  #    @expects forecast2 [FunctionalLightService::Result] Consuntivi filtrati nello Step precedente per il forecast2
  #    @promises previsione [Hash] In questa variabile inserisco il risultato del forecast per ogni stazione e per ogni ora
  #    @promises previsione2 [Hash] In questa variabile inserisco il risultato del forecast per ogni stazione e per ogni ora
  #
  #    previsone = {"feriana"=>[28513.707674943573, 30426.730663741077],
  #                 "kasserine"=>[5293.154627539503, 5158.996160175534],
  #                 "zriba"=>[236252.539503386, 251786.7526055952],
  #                 "nabeul"=>[79220.02257336344, 87046.02303894682],
  #                 "korba"=>[5760.112866817157, 6106.385079539223]}
  #
  #
  # {ForecastActions::CompilaForecastExcel CompilaForecastExcel}
  # Inserisce in Excel nel foglio Previsione e Previsione_2 il risultato dei forecast
  #    @expects previsone [Hash] Risultato del forecast per ogni stazione e per ogni ora
  #    @expects previsone2 [Hash] Risultato del forecast2 per ogni stazione e per ogni ora
  #    @expects workbook [WIN32OLE] File Excel del mio forecast
  #
  # @return [FunctionalLightService::Context] Contesto finale dopo aver eseguito tutte le azioni
  def self.steps
    [
      ConnectExcel,
      SetExcelDay,
      GetExcelParams,
      ParseCsv,
      with_callback(IterateHours, [FilterData, MediaPonderata]),
      CompilaForecastExcel
    ]
  end

  # Controllo il risultato finale e lo stampo sul relativo log
  #
  # @param result [FunctionalLightService::Context] esito finale di tutte le azioni eseguite
  #
  # @return [void]
  def self.check_result(result)
    if result.failure?
      log.error result.message
    elsif !result.message.empty?
      log.info result.message
    else
      print "\n"
      log.info { "Forecast eseguito corretamente" }
    end
  end

  private_class_method :steps, :check_result
end
