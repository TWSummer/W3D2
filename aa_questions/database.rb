require 'sqlite3'
require 'singleton'
require_relative 'model_base'

class QuestionDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('aa_questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end
