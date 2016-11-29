require_relative 'questions_database'

class Reply
  attr_accessor :user_id, :question_id, :parent_id, :body
  attr_reader :id

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?
    SQL

    replies.map {|reply| Reply.new(reply)}
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
    SQL

    replies.map {|reply| Reply.new(reply)}
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL

    reply.empty? ? nil : Reply.new(reply.first)
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @body = options['body']
  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    return nil unless parent_id
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE parent_id = ?
    SQL

    replies.map {|reply| Reply.new(reply)}
  end

  def save
    if id
      QuestionsDatabase.instance.execute(
        <<-SQL, user_id, question_id, parent_id, body, id)
        UPDATE replies
        SET user_id = ?, question_id = ?, parent_id = ?, body = ?
        WHERE id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(
        <<-SQL, user_id, question_id, parent_id, body)
        INSERT INTO replies (user_id, question_id, parent_id, body)
        VALUES (?, ?, ?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
end
