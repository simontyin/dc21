class Facility < ActiveRecord::Base

  before_validation :remove_white_spaces

  validates :name, :code,  :presence => true,
                           :uniqueness => {:case_sensitive => false},
                           :length   => { :maximum => 50 }

  default_scope :order => 'name ASC'

  has_many :column_details

  private

  def remove_white_spaces
    self.name = self.name.strip
    self.code = self.code.strip
  end

end