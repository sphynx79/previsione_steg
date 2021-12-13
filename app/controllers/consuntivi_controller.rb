#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

# Legge i consuntivi
#
# Utilizzo questa classe per avviare le azioni
# per la lettura de consuntivi, inoltre gestisco
# qualsiasi errore che possa essere avvenuto dentro le varie
# azioni eseguite, in caso di errore imprevisto viene gestino
# da qui e viene stampato il log e inviata un'email di notifica
class ConsuntiviController < Ikigai::BaseController
  # @!parse
  #   extend FunctionalLightService::Organizer
  #   extend FunctionalLightService::Prelude::Result
  #   include ShareAction
  #   include ConsuntiviActions
  extend FunctionalLightService::Organizer
  extend FunctionalLightService::Prelude::Result
  include ConsuntiviActions
  include ShareActions

  # Entry point chiamato per avviare la lettura dei consuntivi
  #
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
    e.backtrace.each { |x| msg += x + "\n" if x.include? APP_NAME } # msg += x + "\n"
    log.fatal msg
    exit 1
  end

  # Azioni eseguite in serie per lo scaricamento e lettura consuntivi
  #
  # {ConsuntiviActions::DownloadConsuntivi}
  # Avvio lo script SyncToRemoteScript.bat che mi scarica dal FTP di scada i consuntivi
  #
  # {ConsuntiviActions::ConnectExcel}
  # Mi connetto al file Excel del db<br/>
  #  - **@promises** excel [WIN32OLE] Instance Excel\
  #  - **@promises** workbook [WIN32OLE] Instance Excel del file excel del DB
  #
  # {ConsuntiviActions::LeggiConsuntivi}
  # Avvio la macro nel file DB.xlsm che legge i file consuntivi, e li mette nel file stesso
  #
  # {ShareActions::RefreshLinks}
  # Refresha i collegamenti del file Excel del forecast
  #
  # @return [FunctionalLightService::Context] Contesto finale dopo aver eseguito tutte le azioni
  def self.steps
    # rubocop:disable Layout/ExtraSpacing
    [
      DownloadConsuntivi,
      ConnectExcel,       # P:[excel, workbook]
      LeggiConsuntivi,
      RefreshLinks
    ]
    # rubocop:enable Layout/ExtraSpacing
  end

  private_class_method :steps
end
