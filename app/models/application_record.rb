class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  enum role: [:normal , :admin]
end
