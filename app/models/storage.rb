class Storage < ApplicationRecord
	belongs_to :token

	validates :path, presence: true
	
	before_destroy :delete_file

	protected
	def delete_file
		delete_path = "#{Rails.root}/app/scraper/db/#{self.path}.data"
	    File.delete(delete_path) if File.exist?(delete_path)
  	end
end
