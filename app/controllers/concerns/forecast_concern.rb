#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module ExcelConst end

module ForecastConcern
  module Excel
    @@excel = nil
    @@workbook = nil
    @@worksheet = nil
    @@params = {}

    # parametri per far girare il forecast
    #
    # @return [Hash]
    def params
      @@params
    end

    # excel application
    #
    # @return [WIN32OLE]
    def excel
      @@excel
    end

    # file excel che sto usando
    #
    # @return [WIN32OLE]
    def workbook
      @@workbook
    end

    # si connette ad Excel
    #
    # @return [WIN32OLE]
    def conneti_excel
      @@excel ||= WIN32OLE.connect("Excel.Application")
      WIN32OLE.const_load(@@excel, ExcelConst)
      @@excel
    end

    # si connette a un file il cui nome è passato come parametro
    #
    # @param workbook_name [String] nome del file a cui connettersi
    #
    #
    # @return [WIN32OLE]
    def conneti_workbook(workbook_name)
      @@excel.Workbooks(workbook_name).activate
      @@workbook = @@excel.Workbooks(workbook_name)
    end

    # si connette alllo sheet del file excel
    #
    # @param worksheet_name [String] nome dello sheet a cui connetersi
    #
    #
    # @return [WIN32OLE]
    def worksheets(worksheet_name)
      @@worksheet = @@workbook.worksheets(worksheet_name)
    end

    # Avvia la macro GetElement del file Forecast.xlsm
    #
    # @param variabile [String] variable del file Forecast.xlsm da leggere
    # @param sheet [String] foglio in cui si trova la variabile da leggere
    #
    # @return [String]
    def get_param(variabile, sheet)
      tmp = @@excel.Evaluate(@@workbook.Sheets(sheet).Names(variabile).Value).value
      tmp == "" ? nil : tmp
    end

    # Avvia la macro GetRangeName del file Forecast.xlsm
    #
    # @param variabile [String] variable del file Forecast.xlsm da leggere
    # @param sheet [String] foglio in cui si trova la variabile da leggere
    #
    # @example return value
    #   [{"Date"=>2021-12-13 08:00:00 +0100, "Giorno"=>13.0, "Mese"=>12.0, "Anno"=>2021.0, "Ora"=>8.0, "Giorno_Sett_Num"=>1.0, "Giorno_Sett_Txt"=>"lunedì", "Festivo"=>"N", "Festivita"=>"N", "Stagione"=>"autunno"}]
    #
    # @return [Array]
    def get_range_name(variabile, sheet)
      tmp = @@excel.Evaluate(@@workbook.Sheets(sheet).Names(variabile).Value)
      tmp == "" ? nil : range_to_array(tmp)
    end

    # trasforma il range del giorno da fare in un hash
    #
    # @param range [WIN32OLE] range letto dal file del forecast per il girono da fare,
    #     dal quale poi prendo se è un festivo o altre cose che mi servono per il forecast
    #
    # @return [Array]
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

    # abilito o disavilito ScreenUpdating in excel
    #
    # @param value [Boolean]
    #
    # @return [Void]
    def screen_updating=(value)
      @@excel.ScreenUpdating = value
    end

    # abilito o disavilito Calculation in excel
    #
    # @param value [Boolean]
    #
    # @return [Void]
    def calculation=(value)
      @@excel.Calculation = value
    end

    # setto la data nelle mie variable params prendendola dal file del forecast
    #
    # @return [DateTime]
    def data
      # @@params[:data] ||= get_param("data", "Forecast V1")
      @@params[:data] ||= @@workbook.sheets("Forecast V1").Range("$M$3").value.to_datetime
    end

    # legge le caratteristiche del giorno che devo fare il forecast, tipo il giorno settimana, se è un festivo, ecc..
    #
    # @return [Array]
    #
    # ```ruby
    #   [
    #      [0] {
    #        "Date"            => 2021-11-25 08:00:00 +0100,
    #        "Giorno"          => 25.0,
    #        "Mese"            => 11.0,
    #        "Anno"            => 2021.0,
    #        "Ora"             => 8.0,
    #        "Giorno_Sett_Num" => 4.0,
    #        "Giorno_Sett_Txt" => "giovedì",
    #        "Festivo"         => "N",
    #        "Festivita"       => "N",
    #        "Stagione"        => "autunno"
    #      }
    #    ]
    # ```
    def day
      @@params[:day] ||= get_range_name("day", "Day")
    end

    # setto il giorno_settimana nelle mie variable params prendendola dal file del forecast
    #
    # @return [String]
    def giorno_settimana
      @@params[:giorno_settimana] ||= get_param("giorno_settimana", "Forecast V1")
    end

    # prendo da "Forecast.xlsm" foglio "Forecast V1" se devo prendere un giorno della settima esatto
    #
    # @return [String] se è un giorno festivo ["SI", "NO", "ALL"]
    def festivo
      @@params[:festivo] ||= get_param("festivo", "Forecast V1")
    end

    # prendo da "Forecast.xlsm" foglio "Forecast V1" se è un festività
    #
    # @return [String] Se è una festività ["SI", "NO", "ALL"]
    def festivita
      @@params[:festivita] ||= get_param("festività", "Forecast V1")
    end

    # legge la nomina di STEG
    #
    # @return [Float]
    def nomina_steg
      @@params[:nomina_steg] ||= get_param("nomina_steg", "Forecast V1").nil? ? nil : get_param("nomina_steg", "Forecast V1").sub(",", ".").to_f
    end

    # Avvia la macro Save_PDF del file Forecat.xlsm
    #
    # @param path [String] dove salvare il file pdf
    #
    # @return [Void]
    def save_pdf(path)
      @@excel.Run("'Forecast.xlsm'!Save_PDF", path)
    end

    # legge dal file Forecast.xlsm foglio forecast il relativo tipo di previsone [dicom,prv,simulazione]
    #
    # @param type [Symbol] tipo di prevsione che devo leggere [dicom,prv,simulazione]
    #
    # @return [Integer]
    def previsione(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("T10").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("M10").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("AA10").value.round
      end
    end

    # legge dal file Forecast.xlsm foglio forecast il relativo tipo di delta di scostamento [dicom,prv,simulazione]
    #
    # @param type [Symbol] tipo di delta di scostamento che devo leggere [dicom,prv,simulazione]
    #
    # @return [Float]
    def previsione_delta(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("V10").value
      when :prv
        @@workbook.Worksheets("Forecast").Range("O10").value
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("AC10").value
      end
    end

    # legge dal file Forecast.xlsm foglio forecast la relativa nomina di STEG [dicom,prv,simulazione]
    #
    # @param type [Symbol] tipo di nomina di STEG da leggere [dicom,prv,simulazione]
    #
    # @return [Integer]
    def previsione_nomina_steg(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("T12").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("M12").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("AA12").value.round
      end
    end

    # legge dal file Forecast.xlsm foglio forecast il relativa consuntivo progressivo [dicom,prv,simulazione]
    #
    # @param type [Symbol] tipo di consuntivo progressivo da leggere [dicom,prv,simulazione]
    #
    # @return [Integer]
    def previsione_nomina_steg_progressivo(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("T14").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("M14").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("AA14").value.round
      end
    end

    # legge dal file Forecast.xlsm foglio forecast il relativa scostamento percentuale progressivo [dicom,prv,simulazione]
    #
    # @param type [Symbol] tipo di scostamento percentuale progressivo da leggere [dicom,prv,simulazione]
    #
    # @return [Float]
    def previsione_nomina_steg_progressivo_delta(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("V14").value
      when :prv
        @@workbook.Worksheets("Forecast").Range("O14").value
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("AC14").value
      end
    end

    # legge dal file Forecast.xlsm foglio forecast il relativa consuntivo [dicom,prv,simulazione]
    #
    # @param type [Symbol] tipo di scostamento percentuale progressivo da leggere [dicom,prv,simulazione]
    #
    # @return [Integer]
    def previsione_consuntivi(type)
      case type
      when :dicom
        @@workbook.Worksheets("Forecast").Range("T16").value.round
      when :prv
        @@workbook.Worksheets("Forecast").Range("M16").value.round
      when :simulazione
        @@workbook.Worksheets("Forecast").Range("AA16").value.round
      end
    end

    # legge dal file Forecast.xlsm foglio forecast il relativa valore di daily evolution in base all'ora e al tipo [nomina,previsione,steg_progr]
    #
    # @param type [Symbol] tipo di daily evolution da leggere [nomina,previsione,steg_progr]
    # @param hour [Integer] l'ora che devo leggere mi serve per prendere la riga giusta
    #
    # @return [Integer]
    def daily_evolution(type, hour)
      case type
      when :nomina
        get_daily_evolution_value("D", hour)
      when :previsione
        get_daily_evolution_value("F", hour)
      when :steg_progr
        get_daily_evolution_value("H", hour)
      end
    end

    # legge dal file Forecast.xlsm foglio forecast il relativa valore della tabella daily evolution
    #
    # @param column [String] colonnna del file excel da leggere
    # @param row [Integer] riga del file excel da leggere
    #
    # @return [Integer]
    def get_daily_evolution_value(column, row)
      value = @@workbook.Worksheets("Forecast").Range("#{column}#{row}").value
      return "" if value.nil?
      value.round
    end

    # Setto la data nel file Excel del Forecast
    #
    # @param  data [String] Data da impostare nel file excel
    #
    # @return [void]
    def set_day(data_hour)
      @@workbook.Worksheets("Forecast V1").Range("M3").value = data_hour
      nil
    end

    # salvo il file passato parametro
    #
    # @param name [String]
    #
    # @return [Void]
    def save_workbook(name)
      @@excel.CalculateBeforeSave = false
      @@excel.Workbooks(name).Save
      @@excel.CalculateBeforeSave = true
    end

    def leggi_consuntivi
      @@excel.Run("'DB.xlsm'!LeggiConsuntivi")
    end

    # Aggiorna i link al file passato come parametro
    #
    # @param workbook [WIN32OLE]
    # @param path [String]
    #
    # @return [Void]
    def refresh_links(workbook, path)
      workbook.UpdateLink(path, ExcelConst::XlExcelLinks)
      @@excel.Calculate
    end

    # Avvia la macro CopyToCSV del fileDB2.xlsm
    #
    # @return [Void]
    def export_db
      @@excel.Run("'DB2.xlsm'!CopyToCSV")
    end

    # Pulisco la tabella daily evolution del forecast
    #
    # @return [Void]
    def clear_daily_evolution
      @@workbook.Worksheets("Forecast").Range("$D$7:$D$17").value = ""
      @@workbook.Worksheets("Forecast").Range("$F$7:$F$17").value = ""
      @@workbook.Worksheets("Forecast").Range("$H$7:$H$17").value = ""
    end
  end

  module Csv
    # fa il parser del file csv delle misure
    #
    # @example return value
    #   [
    #      [0] {
    #       "Date"            => #<DateTime: 2015-10-20T08:00:00+00:00 ((2457316j,28800s,0n),+0s,2299161j)>,
    #       "Giorno"          => 20,
    #       "Mese"            => 10,
    #       "Anno"            => 2015,
    #       "Ora"             => 8,
    #       "Giorno_Sett_Num" => 2,
    #       "Festivo"         => "N",
    #       "Festivita"       => "N",
    #       "Stagione"        => "autunno",
    #       "Exclude"         => "N",
    #       "Peso"            => 1.0,
    #       "Flow_Feriana"    => 70.0,
    #       "Flow_Kasserine"  => 1.0,
    #       "Flow_Zriba"      => 256.0,
    #       "Flow_Nabeul"     => 49.0,
    #       "Flow_Korba"      => 7.0,
    #       "Flow_Totale"     => 9235.0
    #     }
    #   ]
    #
    # @return [Array<Hash>]
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
