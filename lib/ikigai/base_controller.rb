#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module Ikigai
  class BaseController
    include Ikigai::Log
    class << self
      attr_accessor :env

      # def initialize(env)
      #   @env = env
      # end

      def render(msg: nil)
        # @TODO: vedere se questo serve
        # view = controller_action
        load layout_path
        load view_path

        render_template do
          Object.const_get(action_view).call(msg)
        rescue
          p "action: #{action_view} non esiste"
        end
      end

      def render_template(&block)
        Layout.load(&block)
      end

      def layout_path
        file(layout)
      end

      def view_path
        file(controller_action)
      end

      def file(path)
        Dir[File.join("app", "views", "#{path}.rb")].first
      end

      def controller_action
        File.join(env[:controller], env[:action])
      end

      def layout
        File.join("layout", "application")
      end

      def action_view
        env[:action].capitalize
      end
    end
  end
end
