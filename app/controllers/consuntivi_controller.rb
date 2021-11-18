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
  #   include ShareAction
  #   include ConsuntiviActions
  extend FunctionalLightService::Organizer
  extend FunctionalLightService::Prelude::Result
  include ConsuntiviActions
  include ShareActions

  # Entry point chiamato per avviare la lettura dei consuntivi
  #
  # @param env [Hash] Enviroment della mia applicazione
  # @option env [String] :controller Controller chiamato
  # @option env [String] :action Entry point del mio controller da eseguire
  # @option env [Hash] :command_options parametri della mia azione da eseguire
  # @option env [Hash] :global_options parametri globali dell'applicazione
  #
  # @example :env params
  #   {
  #     :controller      => "consuntivi",
  #     :action          => "call",
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
  end

  def self.steps
    [
      DownloadConsuntivi,
      ConnectExcel, #=> [excel, workbook]
      LeggiConsuntivi,
      RefreshLinks
    ]
  end

  def self.check_result(result)
    # !result.warning.empty? && result.warning.each { |w| @log.warn w }
    if result.failure?
      # $stderr.puts("ABORTED! You forgot to BAR the BAZ")
      log.error { result.message }
      exit 1
    else
      log.info { "Download consuntivi avvenuto con successo!" }
    end
  end
end
