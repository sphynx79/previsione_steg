#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  # Mi connetto al file Excel del forecast
  class SendEmail
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises excel [WIN32OLE]
    # @promises workbook [WIN32OLE]
    expects :path_pdf_report, :html

    # @!method ConnectExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
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
      end.map_err { ctx.fail_and_return!("Non riesco a inviare l'email controlare che Outlook sia aperto!") }
    end

    def self.type
      ctx.dig(:env, :command_options, :type) == "consuntivo" ? "CONS" : "FCT"
    end

    def self.date
      ctx.dig(:env, :command_options, :dt)
    end

    def self.time
      DateTime.now.strftime("%H:%M")
    end

    def self.day
      case Date.parse(date).strftime("%u")
      when "1" then "Lunedì"
      when "2" then "Martedì"
      when "3" then "Mercoledì"
      when "4" then "Giovedì"
      when "5" then "Venerdì"
      when "6" then "Sabato"
      when "7" then "Domenica"
      end
    end

    private_class_method :type, :date, :day
  end
end
