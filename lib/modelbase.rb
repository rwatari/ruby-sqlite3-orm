require_relative 'questions_database'

class Modelbase

  def self.find_by_id(id)
    object = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
    SQL

    object.empty? ? nil : self.new(object.first)
  end

  def self.all
    objects = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL

    objects.map {|object| self.new(object)}
  end

  def self.where(options)
    if options.is_a? String
      results = QuestionsDatabase.instance.execute(<<-SQL)
        SELECT *
        FROM #{self.table_name}
        WHERE #{options}
      SQL
    else
      results = QuestionsDatabase.instance.execute(<<-SQL, options)
        SELECT *
        FROM #{self.table_name}
        WHERE #{generate_where_str(options)}
      SQL
    end

    results.map {|result| self.new(result)}
  end

  def self.method_missing(method_name, *args)
    method_name = method_name.to_s

    return super unless method_name.start_with?("find_by_")

    attributes_string = method_name[("find_by_".length)..-1]
    attribute_names = attributes_string.split("_and_")

    unless attribute_names.length == args.length
      raise "unexpected # of arguments"
    end

    search_conditions = {}
    attribute_names.each_index do |i|
      search_conditions[attribute_names[i].to_sym] = args[i]
    end

    self.where(search_conditions)
  end

  def save
    if id
      QuestionsDatabase.instance.execute(<<-SQL, ivar_hash)
        UPDATE #{self.class.table_name}
        SET #{generate_update_str}
        WHERE id = :id
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, ivar_hash_no_id)
        INSERT INTO #{self.class.table_name} (#{generate_insert_str})
        VALUES (#{generate_values_str})
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    end
  end


  private

  def self.generate_where_str(options)
    options.map { |key, _| "#{key} = :#{key}" }.join(" AND ")
  end

  def generate_update_str
    ivar_hash_no_id.map { |key, _| "#{key} = :#{key}" }.join(", ")
  end

  def generate_insert_str
    ivar_hash_no_id.keys.map(&:to_s).join(", ")
  end

  def ivar_hash
    hash = {}
    readers = self.instance_variables.map { |sym| ivar_to_sym(sym) }
    readers.each { |sym| hash[sym] = self.send(sym) }
    hash
  end

  def ivar_hash_no_id
    hash = ivar_hash
    hash.delete(:id)
    hash
  end

  def ivar_to_sym(sym)
    sym[1..-1].to_sym
  end

  def generate_values_str
    ivar_hash_no_id.keys.to_s[1..-2]
  end
end
