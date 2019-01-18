class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash)
    @id = dog_hash[:id]
    self.name = dog_hash[:name]
    self.breed = dog_hash[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end


  def save
    sql = <<-SQL
    INSERT INTO dogs(name, breed)
    VALUES (?,?)
    SQL
    dog = DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create (dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    dog = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(dog)
  end

  def self.find_or_create_by(dog_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog_hash[:name], dog_hash[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = Dog.create(dog_hash)
    end
    dog
  end

  def self.new_from_db(db_array)
    Dog.new({:id => db_array[0], :name => db_array[1], :breed => db_array[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL
    dog_array = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(dog_array)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ?"
    DB[:conn].execute(sql, self.name, self.breed)
  end
end
