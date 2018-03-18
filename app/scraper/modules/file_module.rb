require 'json'
require 'yaml'

module FileModule
  
  #receive: an object it could be a hash or an array and optional the file name (this is needed to save something different from the conflict_matrix)
  def self.create_json(object, file_name = "conflict_matrix")
    begin
      names = [-1]
      Dir.new('db/').each do |file|
        if file.include?(".json") and file.include?(file_name) then names.push(Integer(file.split('(')[1].split(")")[0])) end
      end
      path = "db/#{file_name}(#{names.max + 1}).json"
      File.open(path,"w") { |f| f.write(object.to_json) }
      return true
    rescue
        return false
    end
  end
      
  #receive: a string with the name of the file if we are going to load a conflict_matrix storaged we just put the number of the file, if is another type of file we set the method in false
  #return: the render of the .json file 
  def self.render_json(file_name, conflict_matrix = true)
    path = "db/conflict_matrix(#{file_name}).json"
    if !conflict_matrix then path = "db/#{file_name}.json" end
    file = File.read(path) 
    data_hash = JSON.parse(file)
    return data_hash
  end
    
  #receive: an object it could be a hash or an array and the file name  YAML::load(
  def self.serialize(object, file_name)
    begin
      names = [-1]
      Dir.new('db/').each do |file|
        if file.include?(".data") and file.include?(file_name) then names.push(Integer(file.split('(')[1].split(")")[0])) end
      end
      path = "db/#{file_name}(#{names.max + 1}).data"
      File.open(path,"w") { |f| f.write(object.to_yaml) }
      return true
    rescue
        return false
    end
  end  

  #receive: an object it could be a hash or an array and the file name 
  #return: an string, the url where the file was stored
  def self.web_serialize(object, path)
    begin
      storage_path = "db/#{path.split("/").last}"
      File.open(storage_path,"w") { |f| f.write(object.to_yaml) }
      return path 
    rescue
        return nil
    end
  end 
  
  #receive: a string with the name of the file that we are going to load
  #return: the object   
  def self.deserialize(file_name)
    begin
      # object = YAML::load(File.open("db/#{file_name}.data"))
      # File.open("db/#{file_name}.data") { |file| YAML::load(file) }
      return YAML.load_file("db/#{file_name}.data")
    rescue 
      return nil 
    end
  end  
end