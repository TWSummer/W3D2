require_relative 'database'
require 'byebug'
class ModelBase

  def initialize
  end

  def self.find_by_id(id)
    result = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{TABLE}
      WHERE
        id = ?
    SQL

    new(result.first)
  end

  def self.all
    results = QuestionDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{TABLE}
    SQL
    results.map { |result| new(result) }
  end

  def save
    instance_vars = self.instance_variables
    instance_vars.map! do |attribute|
      self.instance_variable_get(attribute)
    end
    instance_vars = instance_vars[1..-1]

    # debugger
    question_str = "?, " * COLUMNS.length
    question_str = "(" + question_str[0..-3] + ")"
    raise "@id #{@id} is already in table" if @id
    QuestionDatabase.instance.execute(<<-SQL, *instance_vars)
      INSERT INTO
        #{TABLE}(#{COLUMNS.join(", ")})
      VALUES
        #{question_str}
    SQL
    @id = QuestionDatabase.instance.last_insert_row_id
  end
end
