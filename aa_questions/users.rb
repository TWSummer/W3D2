require_relative 'database'
TABLE = 'users'
COLUMNS = ['fname', 'lname']

class User < ModelBase

  attr_accessor :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_id(id)
    users = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(users.first)
  end

  def self.find_by_name(first, last)
    users = QuestionDatabase.instance.execute(<<-SQL, first, last)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    avg_karma = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        AVG(num_likes) AS avg_likes
      FROM (
        SELECT
          questions.id, COUNT(question_likes.id) AS num_likes
        FROM
          questions
        JOIN
          question_likes ON question_likes.question_id = questions.id
        WHERE
          questions.author_id = ?
        GROUP BY
          questions.id
      ) AS alias
    SQL
    avg_karma.first['avg_likes']
  end

  def save
    raise "#{self} already in database" if @id
    QuestionDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end
end


if $PROGRAM_NAME == __FILE__
  p User.find_by_id(1)
end
