#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  # Avvia la macro che trova la miglior nomina di STEG
  #
  class GoalNomination
    # @!parse
    #   extend FunctionalLightService::Action
    #   extend ForecastConcern::Excel
    extend FunctionalLightService::Action

    # @!method GoalNomination(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      feedback = run_goal_macro
      unless feedback
        ctx.fail_and_return!(
          {message: "Non sono riuscito calcolare la Nomina Goal di STEG",
           location: "#{__FILE__}:#{__LINE__}"}
        )
      end
    end
  end
end
