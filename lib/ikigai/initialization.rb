#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module Ikigai
  class Initialization
    class << self
      def call
        load_file
      end

      def load_file
        load_model
        load_controller
        load_view
        # load_helper
        load_actions
      end

      def load_model
        Dir[APP_ROOT.join('app', 'models', '*.rb')].each do |model_file|
          filename = File.basename(model_file).gsub('.rb', '')
          Object.autoload camelize(filename), model_file
        end
      end

      def load_controller
        Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each do |controller_file|
          filename = File.basename(controller_file).gsub('.rb', '')
          Object.autoload camelize(filename), controller_file
        end
      end

      # def load_helper
      #   Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each do |helper_file|
      #     filename = File.basename(helper_file).gsub('.rb', '')
      #     Object.autoload camelize(filename), helper_file
      #   end
      # end

      def load_actions
        Dir[APP_ROOT.join('app', 'actions', '*.rb')].each do |helper_file|
          filename = File.basename(helper_file).gsub('.rb', '')
          Object.autoload camelize(filename), helper_file
        end
      end

      def load_view
        # Dir[APP_ROOT.join('app', 'views', 'layout', '*.rb')].each do |layout_file|
        #   filename = File.basename(layout_file).gsub('.rb', '')
        #   autoload camelize(filename), layout_file
        # end
      end

      def camelize(filename)
        inflector = Dry::Inflector.new
        inflector.camelize(filename)
      end
    end
  end
end
