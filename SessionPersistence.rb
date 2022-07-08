class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  def find_list(id)
    @session[:lists].find{ |list| list[:id] == id }
  end

  def all_lists
    @session[:lists]
  end

  def add_list(list_name)
    id = next_element_id(@session[:lists])
    @session[:lists] << { id: id, name: list_name, todos: [] }
  end

  def delete_list(id)
    @session[:lists].reject! { |list| list[:id] == id }
  end

  def update_list_name(id, list_name)
    list = find_list(id)
    list[:name] = new_name
  end

  def create_new_todo(list_id, text)
  @list = find_list(list_id)
   id = next_element_id(@list[:todos])
   @list[:todos] << {id: id, name: text, completed: false }
  end

  private

  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end
end
