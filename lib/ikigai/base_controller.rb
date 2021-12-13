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

      # Controllo il risultato dell'elaborazione dei miei step
      #
      # @param result [FunctionalLightService::Context] esito finale di tutte le azioni eseguite
      #
      # @return [void, Process::Status] non restituisce nulla se ha finito corretamente tutto il processo, altrimenti restituisce il codice di errore 2
      def check_result(result, detail: false)
        controller = name.sub("Controller", "")
        if result.failure?
          msg, location = result.message.split("|")
          message = detail && location ? (msg + ": " + location) : msg
          log.error "#{controller} => #{message} "
          exit 2
        elsif !result.message.empty?
          log.info "#{controller} => #{result.message.split("|")[0]}" && nil
        else
          print "\n"
          log.info { "#{controller} eseguito corretamente" } && nil
        end
      end
    end
  end
end
