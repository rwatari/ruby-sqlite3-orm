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

  def authored_questions
    raise "#{self} not yet in DB" unless id
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    raise "#{self} not yet in DB" unless id
    Reply.find_by_user_id(self.id)
  end

end
