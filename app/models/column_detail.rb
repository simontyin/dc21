class ColumnDetail < ActiveRecord::Base
  belongs_to :data_file

  validates_presence_of :data_file_id
  validates_presence_of :name

  default_scope order(:position)

  def find_by_code_uncased
    mappings = ColumnMapping.all
    mappings.each do |map|
      if map.code.to_s.downcase == self.name.to_s.downcase
        return map
      end
    end
    return nil
  end

end
