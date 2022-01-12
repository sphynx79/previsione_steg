#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

class StegModel < Ikigai::BaseModel
  def create_table(table: "Previsione")
    if type == "sqlite"
      client.execute <<-SQL
              CREATE TABLE IF NOT EXISTS #{table} (
                Id INTEGER PRIMARY KEY AUTOINCREMENT,
                data_time TEXT NOT NULL,
                data TEXT NOT NULL,
                anno TEXT NOT NULL,
                mese TEXT NOT NULL,
                giorno Text NOT NULL,
                ora TEXT NOT NULL,
                previson_type TEXT NOT NULL,
                previsione_v1 INTEGER DEFAULT 0,
                previsione_v2 INTEGER DEFAULT 0,
                previsione_v3 INTEGER DEFAULT 0,
                nomina_steg INTEGER DEFAULT 0,
                steg_progressivo INTEGER DEFAULT 0,
                consuntivo INTEGER DEFAULT 0,
                peso_nomina REAL DEFAULT 0,
                correzione_cons_parziale REAL DEFAULT 0,
                UNIQUE(data_time, previson_type)
            );
      SQL
    else
      client.create_table? table do
        # rubocop:disable Layout/ExtraSpacing
        primary_key :id
        DateTime :data_time, index: true, null: false
        Date     :data, null: false
        String   :anno, size: 10, null: false
        String   :mese, size: 20, null: false
        String   :giorno, size: 10, null: false
        String   :ora, size: 10, null: false
        String   :stazione, size: 10, null: false
        Float    :r1, default: 0
        Float    :r2, default: 0
        Float    :r3, default: 0
        Float    :r4, default: 0
        Float    :r5, default: 0
        Float    :r6, default: 0
        unique   %i[data_time stazione], unique: true
        # rubocop:enable Layout/ExtraSpacing
      end
    end
  end
end
