#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ShareActions
  # Refresha i collegamenti del file Excel
  class RefreshLinks
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    promises :excel, :workbook

    # @!method ConnectExcel
    #   @yield Refresha i collegamenti del file Excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      try! do
        refresh_links
      end.map_err { ctx.fail_and_return!("Non riesco ad aggiornare i link del #{Ikigai::Config.file.excel_forecast}") }
    end
  end
end
