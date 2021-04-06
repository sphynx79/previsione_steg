#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module PdfActions
  # Mi connetto al file Excel del forecast
  class SendEmail
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action

    # @promises excel [WIN32OLE]
    # @promises workbook [WIN32OLE]
    expects :path_pdf_report

    # @!method ConnectExcel
    #   @yield Gestisce l'interfaccia per prendere i parametri da excel
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      # binding.pry
      outlook = WIN32OLE.new("Outlook.Application")
      # mapi = outlook.GetNameSpace('MAPI')
      message = outlook.CreateItem(0)
      message.Subject = "STEG FCT GasDay Lunedì 05/04/2021 [ore 17:00]"
      message.Body = ""
      message.To = "michele.boscolo@ttpc.eni.com"
      message.Attachments.Add(ctx.path_pdf_report, 1)
      message.Send

      # try! do
      #   ctx.excel = conneti_excel.freeze
      #   ctx.workbook = conneti_workbook.freeze
      # end.map_err { ctx.fail_and_return!("Non riesco a connetermi al file Forecast.xlsm, controllare che sia aperto") }
    end
  end
end
