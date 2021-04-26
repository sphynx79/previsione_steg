#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ConsuntiviActions
  # Avvio lo script SyncToRemoteScript.bat che mi scarica dal FTP di scada i consuntivi
  class DownloadConsuntivi
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @!method DownloadConsuntivi
    #   @yield Gestisce lo scaricamento dei consuntivi
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      cmd = File.expand_path(Ikigai::Config.path.scada + Ikigai::Config.file.bat_dowload_scada)
      _stdout, stderr, wait_thr = Open3.capture3(cmd)
      ctx.fail_and_return!("Errore nello scaricare dall'FTP i consuntivi:\n#{stderr.chomp}") if wait_thr.exitstatus != 0
    end
  end
end
