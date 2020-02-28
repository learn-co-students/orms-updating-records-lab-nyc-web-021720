require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
 def initialize (name,grade,id=nil)
  @name=name 
  @grade=grade 
  @id = id 
 end 

 def self.create_table
   sql = <<-SQL
    CREATE TABLE if NOT EXISTS students (
      ID INTEGER PRIMARY KEY,
      name TEXT 
      grade INTEGER
    )
   SQL
   DB[:conn].execute(sql)
  end 

  def self.create(name,grade)
   new_student =  Student.new(name,grade)
   new_student.save
  end 

  def self.new_from_db(row)
    new_student = Student.new(row[1],row[2],row[0])
    new_student
  end 

  def self.find_by_name(name)
    sql= <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    student = Student.new_from_db(DB[:conn].execute(sql,name)[0])
    student
  end
  
  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade =? WHERE ID = ?
    SQL
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end


 def save
   if self.id
     self.update
   else
    sql = <<-SQL
      INSERT INTO students(name,grade)
      values(?,?)
    SQL
    DB[:conn].execute(sql,self.name,self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
   end
 end 

 def self.drop_table 
  sql = "DROP TABLE IF EXISTS students"
  DB[:conn].execute(sql)
 end

end
