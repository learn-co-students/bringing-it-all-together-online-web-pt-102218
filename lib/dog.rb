
require 'pry'
class Dog 
  
  attr_accessor :name, :breed 
  attr_reader :id
  
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table 
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end 
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    dog = DB[:conn].execute(sql, name).flatten
    self.new_from_db(dog)
  end 
  
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def save 
    if self.id 
      self.update 
    else 
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    dog = DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
    end
  end
  
  def self.create(attributes)
   dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
   dog.save 
   dog
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id)
    self.new_from_db(id)
  end
  

  def self.find_or_create_by(dog)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?" 
    new_dog = DB[:conn].execute(sql, dog[:name], dog[:breed])
    if !new_dog.empty?
      new_dog = self.new_from_db(new_dog[0])
    else 
      new_dog = self.create(dog)
    end
      new_dog
  end
  

end