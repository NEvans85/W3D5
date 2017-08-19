require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line_parts = params.keys.map { |col_name| "#{col_name} = ?"}
    where_line = where_line_parts.join(" AND ")
    values = params.values
    result = DBConnection.execute(<<-SQL, *values )
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    self.parse_all(result)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
