require_relative 'questions_database'

class QuestionFollow
  def self.find_by_id(id)
    questionf = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_follows
      WHERE id = ?
    SQL

    questionf.empty? ? nil : QuestionFollow.new(questionf.first)
  end

  attr_accessor :user_id, :question_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
