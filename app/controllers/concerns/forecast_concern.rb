#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true


module ForecastConcern
  module Excel
    @@excel = nil
    @@workbook = nil
    @@params = {}

    def params
      @@params
    end

    def workbook
      @@workbook
    end

    def conneti_excel
      @@excel ||= WIN32OLE.connect("Excel.Application")
    end

    def conneti_workbook(workbook_name)
      @@excel.Workbooks(workbook_name).activate
      @@workbook = @@excel.Workbooks(workbook_name)
    end

    def get_param(variabile, sheet)
      tmp = @@excel.Run("'Forecast.xlsm'!GetElement", variabile, sheet)
      tmp == "" ? nil : tmp
    end

    def get_range_name(variabile, sheet)
      tmp = @@excel.Run("'Forecast.xlsm'!GetRangeName", variabile, sheet)
      tmp == "" ? nil : range_to_array(tmp)
    end

    def range_to_array(range)
      header = %w[Date Giorno Mese Anno Ora Giorno_Sett_Num Giorno_Sett_Txt Festivo Festivita Stagione]
      x = []
      range.Rows.each do |row|
        b = []
        row.each do |y|
          b << y.value
        end
        x << Hash[*(0...header.size).inject([]) { |arr, ix| arr.push(header[ix], b[0][0][ix]) }]
      end
      x
    end

    def screen_updating=(value)
      @@excel.ScreenUpdating = value
    end

    def calculation=(value)
      @@excel.Calculation = value
    end

    def data
      @@params[:data] ||= get_param("data", "Forecast V1")
    end

    def day
      @@params[:day] ||= get_range_name("day", "Day")
    end

    def giorno_settimana
      @@params[:giorno_settimana] ||= get_param("giorno_settimana", "Forecast V1")
    end

    def festivo
      @@params[:festivo] ||= get_param("festivo", "Forecast V1")
    end

    def festivita
      @@params[:festivita] ||= get_param("festività", "Forecast V1")
    end

    def nomina_steg
      @@params[:nomina_steg] ||= get_param("nomina_steg", "Forecast V1").nil? ? nil : get_param("nomina_steg", "Forecast V1").sub(",", ".").to_f
    end

    def save_pdf(path)
      @@excel.Run("'Forecast.xlsm'!Save_PDF", path)
    end

    def previsione(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("P10").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("H10").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("X10").value.round
      end
    end

    def previsione_delta(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("R10").value
      when :prv
        @@workbook.Worksheets("Forecast").Range("J10").value
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("Z10").value
      end
    end

    def previsione_nomina_steg(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("P12").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("H12").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("X12").value.round
      end
    end

    def previsione_nomina_steg_progressivo(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("P14").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("H14").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("X14").value.round
      end
    end

    def previsione_nomina_steg_progressivo_delta(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("R14").value
      when :prv
        @@workbook.Worksheets("Forecast").Range("J14").value
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("Z14").value
      end
    end

    def previsione_consuntivi(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("P16").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("H16").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("X16").value.round
      end
    end

    def set_day(data)
      @@workbook.Worksheets("Forecast V1").Range("M3").value = data + " 08:00:00"
    end

    def save_workbook(name)
      @@excel.CalculateBeforeSave = false
      @@excel.Workbooks(name).Save
      @@excel.CalculateBeforeSave = true
    end

    def leggi_consuntivi
      @@excel.Run("'DB.xlsm'!LeggiConsuntivi")
    end

    def refresh_links
      @@excel.Run("'Forecast.xlsm'!RefreshLinks")
    end

    def export_db
      @@excel.Run("'DB2.xlsm'!CopyToCSV")
    end
  end

  module Csv
    def parse_csv
      csv_data = File.read(Ikigai::Config.path.db + Ikigai::Config.file.db_csv)

      column = {"Date" => {type: :date},
                "Giorno" => {type: :int},
                "Mese" => {type: :int},
                "Anno" => {type: :int},
                "Ora" => {type: :int},
                "Giorno_Sett_Num" => {type: :int},
                "Festivo" => {type: :string},
                "Festivita" => {type: :string},
                "Stagione" => {type: :string},
                "Exclude" => {type: :string},
                "Peso" => {type: :float},
                # 'Flow_Feriana' => { type: :float },
                "Flow_Feriana" => {type: :float, not_match: [nil]},
                "Flow_Kasserine" => {type: :float},
                "Flow_Zriba" => {type: :float},
                "Flow_Nabeul" => {type: :float},
                "Flow_Korba" => {type: :float},
                "Flow_Totale" => {type: :float}}

      Rcsv.parse(csv_data, row_as_hash: true, column_separator: ";", header: :use, columns: column, only_listed_columns: true)
    end
  end

  module Utility
    def print_result_with_hirb(result)
      Hirb.enable pager: true
      table = Hirb::Helpers::Table.render result,
        fields: %w[Date
          Anno
          Mese
          Giorno
          Ora
          Giorno_Sett_Num
          Festivo
          Festivita
          Stagione
          Exclude
          Peso
          Flow_Feriana
          Flow_Kasserine
          Flow_Zriba
          Flow_Nabeul
          Flow_Korba
          Flow_Totale],
        headers: {"Giorno_Sett_Num" => "Gior_Sett",
                  "Flow_Feriana" => "Feriana",
                  "Flow_Kasserine" => "Kesserine",
                  "Flow_Zriba" => "Zriba",
                  "Flow_Nabeul" => "Nabeul",
                  "Flow_Korba" => "Korba",
                  "Flow_Totale" => "Totale"},
        description: false,
        max_width: 260
      print table
      # File.open('console.log', 'w') { |f| f.write(table) }
    end

    def print_with_hirb(data)
      print Hirb::Helpers::Table.render(data, max_width: 260)
    end
  end
end
