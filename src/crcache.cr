require "option_parser"
require "sqlite3"

module CrCache
  VERSION = "0.1.0"

  class CacheDb
    getter db : DB::Database

    def initialize(fname = Path["~/.cache/command_cache.sqlite"].expand(home: true))
      dir = File.dirname(fname)
      Dir.mkdir(dir) unless Dir.exists?(dir)

      @db = DB.open("sqlite3://#{fname}")
      create_table
    end

    def create_table
      @db.exec("CREATE TABLE IF NOT EXISTS cache(" +
               "id INTEGER PRIMARY KEY, " +
               "command TEXT, " +
               "last TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
               "result BLOB)")
    end

    def self.open(fname = Path["~/.cache/command_cache.sqlite"].expand(home: true))
      db = CacheDb.new(fname)
      yield db
    ensure
      db.close unless db.nil?
    end

    def each
      @db.query "select command, last, result from cache" do |rs|
        rs.each do
          yield rs.read(String), rs.read(String), rs.read(String)
        end
      end
    end

    def delete(cmd)
      @db.exec("DELETE FROM cache WHERE command = ?", cmd)
    end

    def update(cmd, result)
      @db.exec("UPDATE cache SET result = ?, last = CURRENT_TIMESTAMP WHERE command = ?", result, cmd)
    end

    def refresh(cmd)
      result = `#{cmd}`
      @db.exec("UPDATE cache SET result = ?, last = CURRENT_TIMESTAMP WHERE command = ?", result, cmd)
      result
    end

    def refresh
      cmds = [] of String

      each do |cmd, last, result|
        cmds << cmd
      end

      cmds.each do |cmd|
        refresh(cmd)
      end
    end

    def get(cmd)
      @db.query_one("SELECT result FROM cache WHERE command = ?", cmd) do |rs|
        return rs.read(String)
      end
    rescue DB::NoResultsError
      result = `#{cmd}`
      @db.exec("INSERT INTO cache (command, result) VALUES (?,?)", cmd, result)
      result
    end

    def close
      @db.close
    end
  end

  OptionParser.parse do |parser|
    parser.banner = "cache v#{VERSION}"

    parser.on "-v", "--version", "Show version" do
      puts "version #{VERSION}"
      exit
    end
    parser.on "-h", "--help", "Show help" do
      puts parser
      exit
    end
    parser.on "-l", "--list", "Show all cached commands" do
      CacheDb.open do |db|
        db.each do |cmd, last, result|
          puts "#{last}: #{cmd}"
        end
      end
      exit
    end
    parser.on "-d CMD", "--delete=CMD", "Delete specified command" do |cmd|
      CacheDb.open do |db|
        db.delete(cmd)
      end
      exit
    end
    parser.on "-r", "--refresh", "Refresh all cached commands" do
      CacheDb.open do |db|
        db.refresh
      end
      exit
    end
    parser.on "-t", "--test", "Refresh test command" do
      CacheDb.open do |db|
        db.refresh("ls")
      end
      exit
    end
    parser.on "-D", "--dump", "Display all cached results" do
      CacheDb.open do |db|
        db.each do |cmd, last, result|
          puts result
        end
      end
      exit
    end
  end

  ENV["CRCACHE_FILE"] ||= Path["~/.cache/command_cache.sqlite"].expand(home: true).to_s
  CacheDb.open(ENV["CRCACHE_FILE"]) do |db|
    puts db.get(ARGV.join(" "))
  end
end
