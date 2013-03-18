module Factory
  def self.default_attributes(name)
    { players: {first_name: 'John', last_name: 'Doe'},
      statistics: {}
    }.fetch(name)
  end

  def factory(name, attributes = {})
    BaseballStats.db[name] << Factory.default_attributes(name).merge(attributes)
  end
end
