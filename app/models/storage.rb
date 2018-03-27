class Storage < ApplicationRecord
  validates :path, presence: true
  
  after_destroy :delete_file

  PATH = "db"

  protected
  def delete_file
  delete_path = Rails.root.join(path)
    File.delete(delete_path) if File.exist?(delete_path)
  end

  def self.get_path
    begin
      path = "#{PATH}/#{SecureRandom.uuid.gsub(/-/, '')}.data"
    end while (where(path:path).any?)  
    path
  end
end
