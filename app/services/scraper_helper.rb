class ScraperHelper

  attr_accessor :conflict_matrix, :errors

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

  def add_errors(member_alias)
    @errors[:schedule_not_fetched] = "#{member_alias} #{@errors[:schedule_not_fetched]}"
  end
end