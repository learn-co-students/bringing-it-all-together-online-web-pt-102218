class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize(name:, breed:, id:nil)
    @id = id
    self.name = name
    self.breed = breed
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if @id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
      dog = self.new(name: name, breed: breed)
      dog.save
      dog
  end

  def self.find_by_id(id)
      row = DB[:conn].execute("SELECT * FROM dogs WHERE id=?", id)[0]
      if row
        dog = self.new_from_db(row)
      end
  end

  def self.find_or_create_by(name:, breed:)
      rows = DB[:conn].execute("SELECT * FROM dogs WHERE name=?", name)
      if rows.count > 1
          rows = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?", name, breed)
          row = rows[0]
          if row
            dog = self.new_from_db(row)
          else
            dog = self.create(name: name, breed: breed)
          end
      elsif rows.count == 1
        row = rows[0]
        dog = self.new_from_db(row)
      else
        dog = self.create(name: name, breed: breed)
      end
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    dog = self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    rows = DB[:conn].execute("SELECT * FROM dogs WHERE name=?", name)
    row = rows[0]
    dog = self.new_from_db(row)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name=?, breed=? WHERE id=?", self.name, self.breed, self.id)
  end

end
