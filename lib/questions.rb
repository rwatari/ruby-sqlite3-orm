require_relative 'questions_database'

class Question
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT *
      FROM questions
      WHERE author_id = ?
    SQL

    questions.map {|question| Question.new(question)}
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL

    question.empty? ? nil : Question.new(question.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(self.author_id)
  end

  def replies
    raise "#{self} not yet in DB" unless id
    Reply.find_by_question_id(self.id)
  end
end
