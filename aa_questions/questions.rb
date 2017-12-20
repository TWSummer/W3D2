require_relative 'database'
TABLE = 'questions'
COLUMNS = ['title', 'body', 'author_id']


class Question < ModelBase

  attr_accessor :title, :body, :author_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  # def self.find_by_id(id)
  #   questions = QuestionDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       questions
  #     WHERE
  #       id = ?
  #   SQL
  #   Question.new(questions.first)
  # end

  def self.find_by_author_id(author_id)
    questions = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def author
    user = QuestionDatabase.instance.execute(<<-SQL, @author_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(user.first)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  # def save
  #   raise "#{self} already in database" if @id
  #   QuestionDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
  #     INSERT INTO
  #       questions (title, body, author_id)
  #     VALUES
  #       (?, ?, ?)
  #   SQL
  #   @id = QuestionDatabase.instance.last_insert_row_id
  # end

  def update
    raise "#{self} not in database" unless @id
    QuestionDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
    SQL
  end

end

if $PROGRAM_NAME == __FILE__
  p Question.find_by_id(1)
end
