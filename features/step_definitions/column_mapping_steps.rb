Given /^file "([^"]*)" has column info "([^"]*)", "([^"]*)", "([^"]*)"$/ do |file, name, unit, type|
  data_file = DataFile.find_by_filename(file)
  data_file.column_details.create!(:name => name, :unit => unit, :data_type => type)
end

Given /^I have column mappings$/ do |table|
  table.hashes.each do |attrs|
    ColumnMapping.create!(attrs)
  end
end

When /^I follow "delete" for "([^"]*)"$/ do |name|
  map = ColumnMapping.where(:name => name).first
  click_link("delete_#{map.id}")
end

