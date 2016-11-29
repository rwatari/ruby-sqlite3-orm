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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def save
    if id
      QuestionsDatabase.instance.execute(<<-SQL, title, body, author_id, id)
        UPDATE questions
        SET title = ?, body = ?, author_id = ?
        WHERE id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, title, body, author_id)
        INSERT INTO questions (title, body, author_id)
        VALUES (?, ?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def author
    User.find_by_id(self.author_id)
  end

  def replies
    raise "#{self} not yet in DB" unless id
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end
end
