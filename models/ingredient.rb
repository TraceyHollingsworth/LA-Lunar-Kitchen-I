class Ingredient

  attr_reader :id, :recipe_id, :name

  def initialize(id, recipe_id, name)
    @id = id
    @recipe_id = recipe_id
    @name = name
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.find_by_recipe(recipe_id)
    query = "SELECT * FROM ingredients
      WHERE recipe_id = $1;"

    records = nil

    db_connection do |conn|
      records = conn.exec(query, [recipe_id])
    end

    ingredients = []

    records.each do |record|
      ingredients << Ingredient.new(record["id"], record["recipe_id"], record["name"])
    end
    ingredients
  end
end
