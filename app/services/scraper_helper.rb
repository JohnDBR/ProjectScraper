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

  def join_schedules(schedule, member_alias = nil)
    @conflict_matrix.each do |key,value|
      (6..20).each do |n|
        input = schedule[key]["#{n}:30 - #{n+1}:30"]
        if  !(input.empty? || input.nil? || input.eql?("")) and !input.eql?("0") ##schedule[key]["#{n}:30 - #{n+1}:30"].eql?("1") or 
          if member_alias.nil?
            @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "#{@conflict_matrix[key]["#{n}:30 - #{n+1}:30"]} #{input}" 
          else
            @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "#{@conflict_matrix[key]["#{n}:30 - #{n+1}:30"]} #{member_alias}" 
          end
        end
      end
    end
  end

  def conflict_matrix
    @conflict_matrix.each do |key,value|
      (6..20).each do |n| 
        input = @conflict_matrix[key]["#{n}:30 - #{n+1}:30"]
        @conflict_matrix[key]["#{n}:30 - #{n+1}:30"] = "0" if input.empty? || input.nil? || input.eql?("") 
      end
    end
    @conflict_matrix
  end

  def add_errors(member_alias)
    @errors[:schedule_not_fetched] = "-#{member_alias}- #{@errors[:schedule_not_fetched]}"
  end

  def add_schedule_to_storage(group, params)
    sl = ScrapingAuthenticate.new
    sp = ScrapingPomelo.new
    if group.storage
      sp.load(group.storage.path)
      group.storage.destroy
    end
    sl.login_pomelo?(params[:user], params[:password])
    sp.student_info(true)
    s = Storage.create(path:sp.save(Storage.get_path))
    group.update_attribute(:storage_id, s.id)
  end
end