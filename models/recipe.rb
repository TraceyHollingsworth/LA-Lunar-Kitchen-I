require_relative 'ingredient'

class Recipe
  attr_reader :id, :name, :instructions, :description

  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    result = []
    query = 'SELECT * FROM recipes ORDER BY name ASC'

    db_connection do |connection|
      @recipes = connection.exec(query)
    end

    @recipes.each do |recipe_item|
      result << Recipe.new(
        recipe_item['id'],
        recipe_item['name'],
        recipe_item['instructions'],
        recipe_item['description']
      )
    end

    result
  end

  def self.find(id)

    sql = 'SELECT * FROM recipes WHERE id = $1'

    record = nil
    db_connection do |connection|
      record = connection.exec(sql, [id]).first
    end

    Recipe.new(
      record['id'],
      record['name'],
      record['instructions'],
      record['description']
    )
    ##===rewrite above===##
    # found_recipe = ''
    # self.all.each do |recipe|
    #   if id == recipe.id
    #     found_recipe = recipe
    #   end
    # end
    # found_recipe
  end

  def ingredients
    Ingredient.find_by_recipe(@id)
  end
end
