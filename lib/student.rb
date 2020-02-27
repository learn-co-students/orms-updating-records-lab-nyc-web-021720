require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists students (
        id INTEGER primary key,
        name TEXT,
        grade TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      drop table students
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def save
    if id then
      update
    else
      save_new
    end 
  end

  def save_new
    sql = <<-SQL
      insert into students (name, grade)
      values(?, ?)
    SQL

    DB[:conn].execute(sql, name, grade)
    @id = DB[:conn].execute("select last_insert_rowid() from students;")[0][0]
  end

  def update
    sql = <<-SQL
      update students
      set name = ?, grade= ?
      where id = ?
    SQL

    DB[:conn].execute(sql, name, grade, id)
  end

  def self.new_from_db(row)
    student = Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name_param)
    sql = <<-SQL
      select *
      from students
      where name = ?
    SQL

    DB[:conn].execute(sql, name_param).map do |row|
      new_from_db(row)
    end.first
  end

end
