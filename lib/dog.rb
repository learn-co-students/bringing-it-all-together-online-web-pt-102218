require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    instance = self.new(name: name, breed: breed)
    instance.save
    instance
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.find_by_name(name)
    sql = <<-SQL
     SELECT * FROM dogs WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed).first
    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
    instance = self.new(id:row[0], name:row[1], breed:row[2])
  end


end
