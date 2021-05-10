#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ReportActions
  # Setto il path dove salvare il PDF
  class SetPdfPath
    # @!parse
    #   extend FunctionalLightService::Action
    extend FunctionalLightService::Action
    # @expects path[String] Path dove salvare i PDF
    # @expects data[String] Data del report
    # @promises path_pdf_report[String] Path dove salvare il PDF
    expects :path, :data
    promises :path_pdf_report

    # @!method SetPdfPath
    #   @yield Description
    #   @yieldparam ctx {FunctionalLightService::Context} Input contest
    #   @yieldreturn {FunctionalLightService::Context} Output contest
    executed do |ctx|
      file_name = "/STEG_#{type}_#{ctx.data}_rev#{version}.pdf"
      full_path = (ctx.path + file_name).gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
      ctx.path_pdf_report = full_path.freeze
    end

    def self.version
      files = Dir.glob("#{ctx.path}/STEG_*_#{ctx.data}_rev*.pdf")
      return "1" if files.empty?
      last_version = files.max_by { |x| x.scan(/rev\d/) }.match(%r{(?<version>rev\d)})
      return "1" if last_version.nil?
      last_version[:version][-1].to_i + 1
    end

    def self.type
      ctx.env.dig(:command_options, :type) == "forecast" ? "FCT" : "CONS"
    end

    private_class_method :version, :type
  end
end
