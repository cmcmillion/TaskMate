require "pg"

class DatabasePersistence
  def initialize(logger)
    # @db = PG.connect(dbname: "todos_db")
    @db = if Sinatra::Base.production?
        PG.connect(ENV['DATABASE_URL'])
      else
        PG.connect(dbname: "todos")
      end
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)

    tuple = result.first

    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id)
    {id: tuple["id"], name: tuple["name"], todos: todos}
  end

  def all_lists
    sql = "SELECT * FROM lists"
    result = query(sql)
    result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos_for_list(list_id)
      {id: list_id, name: tuple["name"], todos: todos}
    end
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, list_name)
  end

  def delete_list(id)
    sql = "DELETE FROM lists WHERE id = $1"
    query(sql, id)
  end

  def update_list_name(id, list_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, list_name, id)
  end

  def create_new_todo(list_id, text)
    sql = "INSERT INTO todos (name, completed, list_id) VALUES ($1, false, $2)"
    query(sql, text, list_id)
  end

  def delete_todo_from_list(todo_id, list_id)
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    query(sql, todo_id, list_id)
  end

  def update_todo_status(is_completed, todo_id, list_id)
    sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3"
    query(sql, is_completed, todo_id, list_id)
  end

  def mark_all_todos_as_completed(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
  end

  def disconnect
    @db.close
  end

  private

  def find_todos_for_list(list_id)
    todos_sql = "SELECT id, name, completed FROM todos WHERE list_id = $1"
    todos_result = query(todos_sql, list_id)

    todos_result.map do |todos_tuple|
      { id: todos_tuple["id"].to_i,
        name: todos_tuple["name"],
        completed: todos_tuple["completed"] == "t" }
    end
  end
end
