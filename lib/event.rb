####
###
##
#  Event Class and
##
###
#### v0.6

class EventCommand < Object
  def initialize (action, object=nil, helper=nil)
    @action = action
    @object = object
    @helper = helper
    self
  end
  attr_reader :action, :object, :helper
end # class
##
#
class Event < Object
  def initialize (name, unique, condition, phrase, message, associated)
    @name             = name
    @triggered        = 0
    if unique.nil? || /true/.=~(unique.downcase)
      @unique         = true
    else
      @unique         = false
    end
    @condition        = condition
    @phrase           = phrase
    @commands         = []
    @message          = message
    @associated       = associated
    self
  end # initialize
attr_reader :name, :condition, :commands, :message, :triggered, :associated, :unique

#
##
###
#### Event Methods

####
###
##
# add a command
#

  def add_command (action, object = nil, helper = nil)
    mycommand = EventCommand.new(action, object, helper)
    @commands.push(mycommand)
    mycommand
  end #add_command

####
###
##
# trigger
#
  def trigger
    @triggered += 1
    @triggered
  end

####
###
##
# check condition and/or phrase and take necessary action
#
  def check_phrase(phrase) # -1, 0 or 1
    if (@phrase.nil? || @phrase == '')
      return 0
    elsif (phrase.nil? || phrase=='') || (Regexp.new(@phrase).=~(phrase)).nil?
      return -1
    else
      return 1
    end
  end # check_phrase

  def check_condition # -1, 0 or 1
    if (@condition.nil? || @condition == '')
      return 0
    elsif eval('@associated.' + @condition)
      return 1
    else
      return -1
    end
  end # check_condition

##
#
#
  def check(phrase = nil)
    answer = false

    if (check_condition + check_phrase(phrase)) > 0 &&
    ((not @unique) || @triggered == 0) # execute

      self.trigger
if @events.nil?
 mylength = 0
else
  mylength = @events.length
end
Messager.pass_message("Still alive: " + name)
Messager.pass_message(" Commands: " + mylength.to_s + "\n")

      @commands.each do |command|
Messager.pass_message("Command action: " + @action.to_s + "\n")
Messager.pass_message("Command object: " + @object.to_s + "\n")
Messager.pass_message("Command helper: " + @helper.to_s + "\n")

        case @action

          when /replace_object_by_helper/:
            eval('@associated.' + @object + " = %q{" + @helper + "} ")

          when /add_helper_to_object/ :
            eval('@associated.' + @object + " << %q{" + @helper + "} ")

          when /add_item_to_inventory/:
            @associated.inventory.add_byId(@object)

          when /withdraw_item_from_inventory/:
            @associated.inventory.withdraw(Item.which(@object))

          when /pass_item_to_player/:
            myobject = Item.which(@object)
            @associated.inventory.withdraw(myobject)
            Map.inventory.add(myobject)

          when /retrieve_item_from_player/:
            myobject = Item.which(@object)
            @associated.inventory.add(myobject)
            Map.inventory.withdraw(myobject)

          when /add_item_to_player_inventory/:
Messager.pass_message("Still alive: #{@object}")

            Map.inventory.add_byId(@object)

          when /withdraw_from_player_inventory/:
            Map.inventory.withdraw(Item.which(@object))

          when /add_item_to_helper_inventory/:
            Item.which(@helper).inventory.add_byId(@object)

          when /withdraw_from_helper_inventory/:
            Item.which(@helper).withdraw(Item.which(@object))

          when /add_to_info_of_object/:
            (Item.which(@object)).info << @helper

          when /open_door_by_id/:
            (Item.which(@object)).open

          when /close_door_by_id/:
            (Item.which(@object)).close

        end # case @action
      end #@commands.each do |command|

      if not @message.nil?
#        Messager.new_screen
        @message = '# "' + @message + '"' if not @phrase.nil?
        Messager.pass_message(@message)
        answer = true
      end # if not @message.nil?

    end # if "execute"

    answer
   end # check

end # class Event

