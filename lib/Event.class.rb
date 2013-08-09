######
####
###
##
#  Event Class
##
###
####
######

class Event < GeneralInfo
#  @@events = []
  def initialize (name, unique, condition, command, object, helper, message, associated)
    super(name, message, nil)
    @triggered        = 0
    if /true/.=~(unique.downcase)
      @unique         = true
    else
      @unique         = false
    end
    @condition        = condition
    @command          = command
    @object           = object
    @helper           = helper
    @associated       = associated
#    @@events.push(self)
  end
attr_reader :name, :condition, :command, :object, :second_object, 
  :message, :triggered, :associated, :unique
  
######
####
###
##
#  Event Methods
##
###
####
######

######
#####
####
###
##
# trigger
#
  def trigger
    @triggered += 1
    @triggered
  end
  
######
#####
####
###
##
# check condition and take necessary action
#
  def check
    answer = ''
    if eval('@associated.' + @condition)
      if (not @unique) || @triggered == 0
        self.trigger
        answer = case @command
          when /replace/: eval('@associated.' + @object + " = %q{" + @helper + "} ")      
          when /add_item/: @associated.inventory.add_byId(@object)
#puts "Still alive 003"
          else nil
        end
      end
    end
    answer
  end

end
