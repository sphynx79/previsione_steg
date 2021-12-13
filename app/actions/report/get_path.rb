#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  ##
  # Setto il path della directory dove andare a salvare i PDF
  #
  # <div class="lsp">
  #   <h2>Expects:</h2>
  #   - env (Hash) Enviroment Application<br>
  #   <h2>Promises:</h2>
  #   - path (String) Path dei file pdf<br>
  # </div>
  #
  class GetPath
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @expects env[Hash] Enviroment Application
    # @promises path[String] Path dei file pdf
    expects :env
    promises :path

    # @!method GetPath(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @expects env [Hash] Enviroment Application
    #
    #   @promises path [String] Path dei file pdf
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
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
