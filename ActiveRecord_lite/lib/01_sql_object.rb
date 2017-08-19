require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  @columns = []

  def self.columns
    return @columns unless @columns.nil?
    columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      SQL
    @columns = columns.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |var_name|
      define_method(var_name) do
        attributes[var_name]
      end
      define_method("#{var_name}=") do |value|
        attributes[var_name] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= 'cats'
    # ...
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |params| new(params) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
    @attributes
  end

  def attribute_values
    columns = self.class.columns
    columns.map do |col_name|
      send(col_name)
    end
  end

  def col_names
    columns = self.class.columns
    columns.join(', ')
  end

  def question_marks
    count = self.class.columns.count
    result = [['?'] * count].join(", ")
    result
  end

  def insert
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_names = self.class.columns.map { |attr_name| "#{attr_name} = ?" }
    set = attr_names.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set}
      WHERE
        id = ?
      SQL
  end

  def save
    id.nil? ? insert : update
  end
end
