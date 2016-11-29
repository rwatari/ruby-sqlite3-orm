require_relative 'questions_database'

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL

    user.empty? ? nil : User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL

    user.empty? ? nil : User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def save
    if id
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname, id)
        UPDATE users
        SET fname = ?, lname = ?
        WHERE id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        INSERT INTO users (fname, lname)
        VALUES (?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def authored_questions
    raise "#{self} not yet in DB" unless id
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    raise "#{self} not yet in DB" unless id
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def average_karma
    arr = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        CAST(num_likes AS FLOAT) / num_questions AS karma
      FROM (
        SELECT
          COUNT(DISTINCT questions.id) AS num_questions,
          COUNT(question_likes.id) AS num_likes
        FROM
          questions
        LEFT JOIN
          question_likes ON question_likes.question_id = questions.id
        WHERE
          questions.author_id = ?
        )
    SQL

    arr.first['karma'] || 0
  end
end
