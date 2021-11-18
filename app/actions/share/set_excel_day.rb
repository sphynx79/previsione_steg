#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ShareActions
  ##
  # Setta nel file excel la data e la salva nella variabile ctx.data
  #
  # <div class="lsp">
  #   <h2>Promises:</h2>
  #   - data ('String')<br>
  # </div>
  #
  class SetExcelDay
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    promises :data

    # @!method SetExcelDay(ctx)
    #   Setta nel file excel la data e la salva nella variabile ctx.data
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @promises data [String]
    #
    #   @return [FunctionalLightService::Context]
    executed do |ctx|
      # @type data [String]
      data = ctx.dig(:env, :command_options, :day)
      set_day(data)
      ctx.data = data.delete("/").freeze
    end
  end
end
