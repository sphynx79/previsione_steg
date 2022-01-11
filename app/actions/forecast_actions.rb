#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ForecastActions
  Dir.glob(Dir.glob(__dir__ + "/forecast/" + "**/*.rb"), &method(:require))
  constants.each do |action_class|
    const_get(action_class).include(Ikigai::Log)
    ForecastConcern.constants.each do |concern_module|
      const_get(action_class).extend(ForecastConcern.const_get(concern_module))
    end
  end
  # DarthVader
  # .constants
  # .map { |class_symbol| DarthVader.const_get(class_symbol) }
  # .select { |c| !c.ancestors.include?(StandardError) && c.class != Module }
end
