#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module PdfActions
  # Prende dal file excel la data del report PDF
  class GetExcelData
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises data [DataTime]
    promises :data

    # @!method GetExcelData
    #   @yield Prende dal file excel la data del report PDF
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      data = get_data
      ctx.data = data.delete("/").freeze
    end

    def self.get_data
      if data.nil? || !data[0..9].match?(/^([0-2][0-9]|(3)[0-1])(\/)(((0)[0-9])|((1)[0-2]))(\/)\d{4}$/)
        ctx.fail_and_return!(
          <<~HEREDOC
            Controllare che nel file: Forecast.xlsm 
            Foglio: "Forecast V1"
            Nella cella Data (M3): sia presente una data
          HEREDOC
        )
      end
      data[0..9]
    end

    private_class_method :get_data
  end
end
