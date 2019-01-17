class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
    self
  end

  def self.create(attributes)
    # binding.pry
    dog = new(name: attributes[:name], breed: attributes[:breed])
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
    SQL
    new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?;
    SQL

    result = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])

    if result.empty?
      dog = create(dog_hash)
    else
      dog = new_from_db(result.flatten)
    end
    dog
  end

  def self.new_from_db(attributes)
    # binding.pry
    new(id: attributes[0], name: attributes[1], breed: attributes[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
    SQL

    result = DB[:conn].execute(sql, name)
    new_from_db(result.flatten)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end