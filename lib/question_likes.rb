require_relative 'questions_database'

class QuestionLike < Modelbase
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.table_name
    "question_likes"
  end

  def self.likers_for_question_id(question_id)
    users =  QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM question_likes
      JOIN users ON users.id = question_likes.user_id
      WHERE question_likes.question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    arr = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(*) AS num_likes
      FROM question_likes
      WHERE question_id = ?
    SQL

    arr.first["num_likes"]
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM question_likes
      JOIN questions ON question_likes.question_id = questions.id
      WHERE question_likes.user_id = ?
    SQL

    questions.map {|question| Question.new(question)}
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM question_likes
      JOIN questions ON questions.id = question_likes.question_id
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
