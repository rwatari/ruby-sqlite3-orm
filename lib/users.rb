require_relative 'questions_database'

class User < Modelbase
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?
    SQL

    user.empty? ? nil : User.new(user.first)
  end

  def self.table_name
    "users"
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
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
