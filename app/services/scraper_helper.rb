class ScraperHelper

  attr_accessor :errors #:conflict_matrix,

  def initialize
    @conflict_matrix = {
    "Monday"    => {},
    "Tuesday"   => {},
    "Wednesday" => {},
    "Thursday"  => {},
    "Friday"    => {},
    "Saturday"  => {},
    "Sunday"    => {}
    }
    fill_conflict_matrix

    @errors = {}
  end

  def fill_conflict_matrix
    @conflict_matrix.each do |key,value|
      (6..20).each { |n| @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "" }
    end
  end

  #receive: an entity group
  def create_conflict_matrix(group)
    sp = ScrapingPomelo.new
    if group.storage
      sp.load(group.storage.path)
      join_schedules(sp.conflict_matrix)
    end
    group.members.map do |member| #.map is required to iterate through ActiveRecord::Associations::CollectionProxy element, it is not an array...
      if member.user.storage
        sp.load(member.user.storage.path)
        join_schedules(sp.temporal_student.schedule, member.alias)
      else
        add_errors(member.alias)
      end
    end
  end

  #receive: a hash that represents a schecduel and a string that represents a member alias
  def join_schedules(schedule, member_alias = nil)
    @conflict_matrix.each do |key,value|
      (6..20).each do |n|
        input = schedule[key]["#{n}:30 - #{n+1}:30"]
        if  !(input.empty? || input.nil? || input.eql?("")) and !input.eql?("0") ##schedule[key]["#{n}:30 - #{n+1}:30"].eql?("1") or 
          if member_alias.nil?
            @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "#{@conflict_matrix[key]["#{n}:30 - #{n+1}:30"]} #{input}" 
          else
            # @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "#{@conflict_matrix[key]["#{n}:30 - #{n+1}:30"]} -#{member_alias}-"
            @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "#{@conflict_matrix[key]["#{n}:30 - #{n+1}:30"]} #{member_alias.split.join("_")}" 
          end
        end
      end
    end
  end

  def conflict_matrix
    @conflict_matrix.each do |key,value|
      (6..20).each do |n| 
        input = @conflict_matrix[key]["#{n}:30 - #{n+1}:30"]
        if input.empty? || input.nil? || input.eql?("")
          @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "0"  
        # else
        #   @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = input #input.split.map! { |name|  if name.include?("-") then name else "-#{name}-" end }.join(" ") 
        end
      end
    end
    @conflict_matrix
  end

  #receive: a string that represents a member alias
  #return: the new array of errors with the member that couldn't being added
  def add_errors(member_alias)
    @errors[:schedule_not_fetched] = "-#{member_alias}- #{@errors[:schedule_not_fetched]}"
  end

  #receive: an entity group and the params of an HTTP request
  #return: true if the the schedule of the person was added to the group or false if it didn't happen
  def add_schedule_to_storage(group, params) 
    sl = ScrapingAuthenticate.new
    sp = ScrapingPomelo.new
    if group.storage
      sp.load(group.storage.path)
    end
    if sl.login_pomelo?(params[:user], params[:password])
      group.storage.destroy if group.storage

      ## The .load storage brings the last temporal user fetched too.
      ## So if a new user is going to be fetched the .load couldn't being  
      ## executed after him/her .login pomelo because the scraping authenticate 
      ## takes the name of the temporal user while .login.

      ## In other words, the .student_info is being executed but the name inside 
      ## the matrix is the one from the student loaded. Then the repeated cells are
      ## deleted by the .unique

      #@sp.set_rails_id_temporal_student(@current_user.id) #The name of the person will be set!
      sp.student_info(true)
      s = Storage.create(path:sp.save(Storage.get_path))
      group.update_attribute(:storage_id, s.id)
      return true
    else
      return false
    end  
  end
end