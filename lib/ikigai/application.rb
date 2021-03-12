#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module Ikigai 
  class Application
    class << self
      attr_accessor :env

      def call(env)
        self.env = env
        dispatch
      end

      def dispatch
        # controller.new(env).public_send(env[:action])
        controller.__send__(env[:action], env: env)
      end

      def controller
        controller_name = env[:controller].capitalize + 'Controller'
        Object.const_get(controller_name)
      end
    end
  end
end
