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
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
              SELECT * FROM dogs
              WHERE name = ?;
            SQL
    new_from_db(DB[:conn].execute(sql, name).first)
  end

  def self.find_by_id(id)
    sql = <<-SQL
              SELECT * FROM dogs
              WHERE id = ?;
            SQL
    new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.create(attr_hash)
    new_dog = new(id: attr_hash [:id], name: attr_hash [:name], breed: attr_hash [:breed])
    new_dog.save
    return new_dog
  end

  def self.new_from_db(row)
    new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
   sql = <<-SQL
             SELECT * FROM dogs
             WHERE name = ? AND breed = ?;
           SQL
   dog = DB[:conn].execute(sql, name, breed)
   unless dog.empty?
     dog_data = new_from_db(dog.first)
   else
     dog_data= create({name: name, breed: breed})
   end
   return dog_data
 end


  def update
    sql = <<-SQL
              UPDATE dogs
              SET name = ?, breed = ?
              WHERE id = ?;
            SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
                 INSERT INTO dogs (name, breed)
                 VALUES (?, ?)
               SQL

     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   end
   return self
 end
end
