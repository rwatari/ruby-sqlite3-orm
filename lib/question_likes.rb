require_relative 'questions_database'

class QuestionLike
  def self.find_by_id(id)
    questionl = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_likes
      WHERE id = ?
    SQL

    questionl.empty? ? nil : QuestionLike.new(questionl.first)
  end

  attr_accessor :user_id, :question_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
