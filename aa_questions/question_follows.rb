require_relative 'database'
TABLE = 'question_follows'
COLUMNS = ['question_id', 'user_id']
class QuestionFollow < ModelBase
  attr_accessor :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    follows = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    QuestionFollow.new(follows.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN
        users ON question_follows.user_id = users.id
      WHERE
        question_id = ?
    SQL
    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        user_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.author_id, questions.title, questions.body, COUNT(*)
      FROM
        question_follows
      JOIN
        questions ON question_follows.question_id = questions.id
      GROUP BY
        questions.id, questions.author_id, questions.title, questions.body
      ORDER BY
        COUNT(*) DESC
      LIMIT ?
    SQL
    questions.map { |question| Question.new(question) }
  end

end
