require_relative 'questions_database'

class QuestionFollow < Modelbase
  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.table_name
    "question_follows"
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM question_follows
      JOIN users ON users.id = question_follows.user_id
      WHERE question_follows.question_id = ?
    SQL

    followers.map { |user| User.new(user) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT questions.*
      FROM question_follows
      JOIN questions ON questions.id = question_follows.question_id
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC
      LIMIT ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT questions.*
      FROM question_follows
      JOIN questions ON questions.id = question_follows.question_id
      WHERE question_follows.user_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
