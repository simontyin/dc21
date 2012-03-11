def create_roles
  Role.delete_all

  Role.create!(:name => "Administrator")
  Role.create!(:name => "Researcher")
  Role.create!(:name => "API Uploader")

end

def create_parameter_categories
  light = ParameterCategory.create!(name: "Light")
  atmosphere = ParameterCategory.create!(name: "Atmosphere")
  temperature = ParameterCategory.create!(name: "Temperature")

  atmosphere.parameter_sub_categories.create!(name: "Carbon Dioxide")
  atmosphere.parameter_sub_categories.create!(name: "Nitrogen")
  atmosphere.parameter_sub_categories.create!(name: "Oxygen")

  light.parameter_sub_categories.create!(name: "Natural")
  light.parameter_sub_categories.create!(name: "Infrared")
  light.parameter_sub_categories.create!(name: "Ultraviolet")

  temperature.parameter_sub_categories.create!(name: "Air temperature")
  temperature.parameter_sub_categories.create!(name: "Soil temperature")
end
