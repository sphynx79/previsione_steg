#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  class AddToPrevisione
    extend FunctionalLightService::Action
    # expects  :..
    # promises :previsione

    executed do |ctx|
      binding.pry
      # PS.each do |ps|
      #   @previsione[ps] << media_ponderata(fcs, ps) * 1000
      #   # @previsione2[ps.to_s] << (fcs2.nil? ? @previsione[ps].last : media_ponderata(fcs2, ps) * 1000)
      # end
    end
    # private_class_method :..
  end
end
