require_relative 'database'
TABLE = 'question_likes'
COLUMNS = ['question_id', 'user_id']
class QuestionLike < ModelBase
  attr_accessor :question_id, :user_id
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    likes = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    QuestionLike.new(likes.first)
  end

  def self.likers_for_question_id(question_id)
    users = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes ON question_likes.user_id = users.id
      WHERE
        question_id = ?
    SQL

    users.map { |user| User.new(user) }

  end

  def self.num_likes_for_question_id(question_id)
    result = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) as num_likes
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL

    result.first['num_likes']

  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        user_id = ?
    SQL

    questions.map { |question| Question.new(question) }

  end

  def self.most_liked_questions(n)
    questions = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id, COUNT(*)
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      GROUP BY
        questions.id, questions.title, questions.body, questions.author_id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL

    questions.map { |question| Question.new(question) }
  end
end
