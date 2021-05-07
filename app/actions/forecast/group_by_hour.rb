#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: tru

module ForecastActions
  # Raggruppo i consuntivi filtrati per ora
  class GroupByHour
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    expects :filtered_data

    # @promises filtered_data_group_by_hour [Array<Hash>] Consuntivi filtrati raggraupati per ora
    promises :filtered_data_group_by_hour

    # @!method GroupByHour
    #   @yield Raggruppo i consuntivi filtrati per ora
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      group_by_hour = ctx.filtered_data.value.group_by { |h| h["Ora"] }
      hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 0, 1, 2, 3, 4, 5, 6, 7]
      ctx.filtered_data_group_by_hour = {}
      hours.each do |h|
        ctx.filtered_data_group_by_hour[h] = group_by_hour[h]
      end
    end
  end
end
