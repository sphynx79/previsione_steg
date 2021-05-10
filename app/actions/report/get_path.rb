#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  # Setto il path dove andare a salvare i PDF
  class GetPath
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects env[Array<Hash>] Enviroment Application
    # @promises path[String] Path dei file pdf
    expects :env
    promises :path

    # @!method GetPath
    #   @yield Cerco la directory dove salvare i PDF
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      path = case ctx.env.dig(:command_options, :type)
                 when "consuntivo"
                   Ikigai::Config.path.consuntivi_pdf
                 when "forecast"
                   Ikigai::Config.path.forecast_pdf

      end
      ctx.fail_and_return!("Constrollare che la directory \"#{File.expand_path(path)}\" esiste") if path.nil? || !File.directory?(path)
      ctx.path = File.expand_path(path).freeze
    end
  end
end
