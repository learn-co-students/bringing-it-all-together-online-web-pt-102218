class Dog
  
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize (name:, breed:, id:nil)
    @name=name
    @breed=breed
    @id=id
  end
  
  def save
        sql = <<-SQL
        INSERT INTO dogs VALUES (?, ?, ?)
        SQL
        DB[:conn].execute(sql, id, name, breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, name, breed, id)
    end

    def self.create(name:,breed:)
        self.new(name:name,breed:breed).save
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        self.new_from_db(DB[:conn].execute(sql, name).first)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ? 
        SQL
        self.new_from_db(DB[:conn].execute(sql, id).first)
    end

    def self.find_or_create_by(name:,breed:)
        sql = <<-SQL
        SELECT * FROM dogs where name= ? and breed = ?
        SQL
        res=DB[:conn].execute(sql,name,breed)
        if res.length ==0 then
            self.new(name:name,breed:breed).save
        else
            self.new_from_db(res.first)
        end
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

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end
end 
