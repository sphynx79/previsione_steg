#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  ##
  # Invia l'e-mail con allegato il report pdf
  #
  # <div class="lsp">
  #   <h2>Expects:</h2>
  #   - html (String) html da inserire del body dell'e-mail<br>
  #   - path_pdf_report (String) Path dove salvare il PDF<br>
  # </div>
  #
  class SendEmail
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    expects :path_pdf_report, :html

    # @!method SendEmail(ctx)
    #
    #   @!scope class
    #
    #   @param ctx [FunctionalLightService::Context]
    #
    #   @expects html [String] html da inserire del body dell'e-mail
    #   @expects path_pdf_report [String] Path dove salvare il PDF
    #
    #   @return [FunctionalLightService::Context, FunctionalLightService::Context.fail_and_return!]
    executed do |ctx|
      try! do
        subject = "STEG #{type} GasDay #{day} #{date} #{time}"
        outlook = WIN32OLE.new("Outlook.Application")
        message = outlook.CreateItem(0)
        message.Subject = subject
        message.HTMLBody = ctx.html
        message.To = Ikigai::Config.mail.to
        message.CC = Ikigai::Config.mail.cc
        message.Attachments.Add(ctx.path_pdf_report, 1)
        message.Send
      end.map_err do |err|
        ctx.fail_and_return!(
          {message: "Non riesco a inviare l'email controlare che Outlook sia aperto!",
           detail: err.message,
           location: "#{__FILE__}:#{__LINE__}"}
        )
      end
    end

    # tipo di report da inviare
    #
    # @return [String]
    def self.type
      ctx.dig(:env, :command_options, :type) == "consuntivo" ? "CONS" : "FCT"
    end

    # la data del report
    #
    # @return [String]
    def self.date
      ctx.dig(:env, :command_options, :dt)
    end

    # l'ora di generazione del report
    #
    # @return [String]
    def self.time
      DateTime.now.strftime("%H:%M")
    end

    # il giorno della settimana del report
    #
    # @return [String]
    def self.day
      case Date.parse(date).strftime("%u")
      when "1" then "Luned??"
      when "2" then "Marted??"
      when "3" then "Mercoled??"
      when "4" then "Gioved??"
      when "5" then "Venerd??"
      when "6" then "Sabato"
      when "7" then "Domenica"
      end
    end

    private_class_method :type, :date, :day
  end
end
