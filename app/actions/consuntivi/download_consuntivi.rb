#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ConsuntiviActions
  ##
  # Avvio lo script SyncToRemoteScript.bat che mi scarica dal FTP di scada i consuntivi
  #
  class DownloadConsuntivi
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @!method DownloadConsuntivi(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      # @type [String]
      cmd = Ikigai::Config.path.scada + Ikigai::Config.file.bat_dowload_scada

      # @type [String]
      _stdout,
      # @type [String]
      stderr,
      # @type [Process::Status]
      wait_thr = Open3.capture3(cmd)

      ctx.fail_and_return!("Errore nello scaricare dall'FTP i consuntivi:\n#{stderr.chomp}") if wait_thr.exitstatus != 0
    end
  end
end
