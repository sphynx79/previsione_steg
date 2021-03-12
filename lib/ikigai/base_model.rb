#!/usr/bin/env ruby
# warn_indent: true
# frozen_string_literal: true

module Ikigai 
  class BaseModel
    attr_reader :client
    attr_reader :type
    attr_reader :message

    def initialize(database: nil)
      # @type = database
    end

    def connect
      # @type == 'access' ? connect_access : connect_sqlite
    end

    #
    # Si Connette al Db sqlite
    #
    # @raise [String] se non riesce a connettersi restituisce l'errore
    #
    # @return [SQLite3::Database]
    #
    def connect_sqlite
      # db_path = File.expand_path(Muletto::Config.database.path + '.db', APP_ROOT)
      # begin
      #   @client = SQLite3::Database.open db_path
      #   @client.execute 'PRAGMA journal_mode = MEMORY;'
      #   @client.execute 'PRAGMA cache_size=4000;'
      #   @client.execute 'PRAGMA synchronous = OFF;'
      #   @client.execute 'PRAGMA count_changes=OFF;'
      # rescue StandardError
      #   @message = <<~MESSAGE
      #     Non riesco connetermi al db Sqlite:
      #     1) Controllare che il file #{db_path} esiste
      #   MESSAGE
      #   @client = nil
      # end
    end

    def connect_access
      # oledb_provider = 'Microsoft.ACE.OLEDB.12.0'
      # db_path = File.expand_path(Muletto::Config.database.path + '.accdb', APP_ROOT)
      # begin
      #   @client = Sequel.ado(conn_string: "Provider=#{oledb_provider};Data Source=#{db_path}")
      # rescue StandardError
      #   @message = <<~MESSAGE
      #     Non riesco connetermi al db Access:
      #     1) Controllare che il file #{db_path} esiste e non sia in uso
      #   MESSAGE
      #   @client = nil
      # end
    end
  end
end
