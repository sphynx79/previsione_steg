#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module PdfActions
  # Prendo dal file csv tutti i dati consintivi
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
      ctx.path = case ctx.env.dig(:command_options, :type)
                 when "consuntivo"
                   Ikigai::Config.path.consuntivi_pdf
                 when "forecast"
                   Ikigai::Config.path.forecast_pdf

      end
      ctx.fail_and_return!("Constrollare che la directory \"#{File.expand_path(ctx.path)}\" esiste") if ctx.path.nil? || !File.directory?(ctx.path)
      ctx.path.freeze 
    end
  end
end
