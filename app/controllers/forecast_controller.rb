#!/usr/bin/env ruby
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
  include ForecastActions
  include ShareActions

  # Entry point chiamato per avviare il forecast
  #
  # @param  env [Hash] Enviroment della mia applicazione
  # @option env [String] :controller Controller chiamato
  # @option env [String] :action Entry point del mio controller da eseguire
  # @option env [Hash] :command_options parametri della mia azione da eseguire
  # @option env [Hash] :global_options parametri globali dell'applicazione
  #
  # @example param :env
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
    # @type [FunctionalLightService::Context]
    result = with(env: env).reduce(steps)
    verbose = env.dig(:global_options, :verbose)
    check_result(result, detail: verbose)
    nil
  rescue => e
    msg = e.message + "\n"
    e.backtrace.each { |x| msg += x + "\n" if x.include? APP_NAME }
    log.fatal msg
    exit 1
  end

  # Azioni eseguite in serie per il calcolo del Forecast
  #
  # {ForecastActions::ConnectExcel}
  # Mi connetto ad excel<br/>
  #  - **@promises** excel [WIN32OLE] Instance Excel\
  #  - **@promises** workbook [WIN32OLE] Instance Excel del file excel del Forecast\
  #
  # {ShareActions::SetExcelDay}
  # Setta nel file excel del Forecast la data
  #  - **@promises** data [String] Contiene la data es. "09042021"
  #
  # {ForecastActions::GetExcelParams}
  # Prendo da excel tutti i dati di input per eseguire il Forecast
  #  - **@promises** params [Hash] parametri letti da excel per eseguire il forecast
  #
  # {ShareActions::RefreshLinks}
  # Fai il refresh dei link nel file Forecast, chimando una macro presente nel file excel
  #
  # {ForecastActions::ParseCsv}
  # Prendo dal file csv tutti i dati consuntivi
  #  - **@promises** consuntivi [Array<Hash>] Consuntivi di Steg
  #
  # {ForecastActions::FilterData}
  # Filtro i consuntivi letti dal DB in base ai filtri impostati nell'Excel
  #   - **@expects** consuntivi [Array<Hash>] Consuntivi di Steg letti dal DB
  #   - **@expects** params [Hamster::Hash] parametri letti da excel
  #   - **@promises** filtered_data [FunctionalLightService::Result] Se finisce con successo forecast [Array<Hash>]
  #
  # {ForecastActions::GroupByHour}
  # Raggruppo i consuntivi filtrati per ora
  #   - **@expects** filtered_data [FunctionalLightService::Result] Se finisce con successo forecast [Array<Hash>]
  #   - **@promises** filtered_data_group_by_hour [Hash<Array>] Consuntivi filtrati raggraupati per ora
  #
  # {ForecastActions::Previsione}
  # Esegue la media ponderata dei dati filtrati nelo step precedente e crea la mia previsione
  #   - **@expects** filtered_data_group_by_hour [Hash<Array>] Consuntivi filtrati raggraupati per ora
  #   - **@promises** previsione [Hash<Array>] Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione
  #
  #    previsone = {"feriana"=>[28513.707674943573, 30426.730663741077],
  #                 "kasserine"=>[5293.154627539503, 5158.996160175534],
  #                 "zriba"=>[236252.539503386, 251786.7526055952],
  #                 "nabeul"=>[79220.02257336344, 87046.02303894682],
  #                 "korba"=>[5760.112866817157, 6106.385079539223]}
  #
  # {ForecastActions::PrevisionLimit}
  # Genero gli estremi superiore e inferiore del mio forecast
  #   - **@expects** previsione [Hash<Array>] Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione
  #   - **@expects** params [Hamster::Hash] parametri letti da excel
  #   - **@expects** filtered_data_group_by_hour [Hash<Array>] Consuntivi filtrati raggraupati per ora
  #   - **@promises** previsione_up [Hash<Array>] Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione
  #   - **@promises** previsione_down [Hash<Array>] Mette in un hash la mia previsione ogni chiave dell'Hash è una stazione
  #
  # @example previsone_up
  #     {"feriana"=>[28513.707674943573, 30426.730663741077],
  #                 "kasserine"=>[5293.154627539503, 5158.996160175534],
  #                 "zriba"=>[236252.539503386, 251786.7526055952],
  #                 "nabeul"=>[79220.02257336344, 87046.02303894682],
  #                 "korba"=>[5760.112866817157, 6106.385079539223]}
  #
  # @example previsone_down
  #     {"feriana"=>[28513.707674943573, 30426.730663741077],
  #                 "kasserine"=>[5293.154627539503, 5158.996160175534],
  #                 "zriba"=>[236252.539503386, 251786.7526055952],
  #                 "nabeul"=>[79220.02257336344, 87046.02303894682],
  #                 "korba"=>[5760.112866817157, 6106.385079539223]}
  #
  # {ForecastActions::Dispersione}
  # Calcolo la dispersione delle curve sugli anni, come si distribuiscono le curve sui vari anni
  #   - **@expects** filtered_data_group_by_hour [Hash<Array>] Consuntivi filtrati raggraupati per ora
  #   - **@expects** previsione_up [Hash<Array>] contiene tutte le curve suddivise per stazione che sono sopra la mia previsione
  #   - **@expects** previsione_down [Hash<Array>] contiene tutte le curve suddivise per stazione che sono sotto la mia previsione
  #   - **@promises** dispersione [Hash<Array>] Mette in un hash la mia disperzione, nel quale ogni chiave e un anno, e i valori sono un array con tutti le curve relative a quell'anno
  #
  # @example dispersione
  #     {2015 => [75000, 80000], 2016 => [8000, 445544], 2017 => [332432, 31243, 4324342], 2018 => [32314, 3243432] ... }
  #
  # {ForecastActions::CompilaForecastExcel}
  # Compila in il file Forecast,xlsm con la mia previsone
  #   **@expects** previsione [Hash<Array>] la mia previsione ogni chiave dell'Hash è una stazione
  #   **@expects** previsione_up [Hash<Array>] contiene tutte le curve suddivise per stazione che sono sopra la mia previsione
  #   **@expects** previsione_down [Hash<Array>] contiene tutte le curve suddivise per stazione che sono sotto la mia previsione
  #   **@expects** dispersione [Hash<Array>] hash della disperzione, nel quale ogni chiave e un anno, e i valori sono un array con tutti le curve relative a quell'anno
  #   **@expects** workbook [WIN32OLE] file excel del mio forecast
  #
  # @return [FunctionalLightService::Context] Contesto finale dopo aver eseguito tutte le azioni
  def self.steps
    # rubocop:disable Layout/ExtraSpacing
    [
      ConnectExcel,         # E:[]                                                                  P:[excel, workbook]
      SetExcelDay,          # E:[]                                                                  P:[data]
      GetExcelParams,       # E:[],                                                                 P:[params]
      RefreshLinks,         # E:[]                                                                  P:[]
      ParseCsv,             # E:[]                                                                  P:[consuntivi]
      FilterData,           # E:[consuntivi, params]                                                P:[filtered_data]
      GroupByHour,          # E:[filtered_data]                                                     P:[filtered_data_group_by_hour]
      Previsione,           # E:[filtered_data_group_by_hour]                                       P:[previsione]
      PrevisionLimit,       # E:[previsione,filtered_data_group_by_hour, params]                    P:[previsone_up, previsone_down]
      Dispersione,          # E:[filtered_data_group_by_hour, previsione, previsione_down]          P:[dispersione]
      CompilaForecastExcel  # E:[previsione, previsione_up, previsione_down, dispersione, workbook] P:[]
    ]
    # rubocop:enable Layout/ExtraSpacing
  end

  private_class_method :steps
end
