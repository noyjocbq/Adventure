####
###
##
#  Event Class and
##
###
#### v0.6

class EventCommand
  def initialize (action, object=nil, helper=nil)
    @action = action
    @object = object
    @helper = helper
##
#DEBUG
#~ printf ("New comm.: A:%10.10s O: %5.5s, H: %5.5s\n", @action.to_s, @object.to_s, @helper.to_s)
#~ printf (">ID %10s\n", self.to_s.slice(-10..-1))
#
##
    self
  end
  attr_reader :action, :object, :helper
end # class

####
###
##
#
class Event
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
##
#DEBUG
#~ printf ("New event: %10.10s c: %5.5s, p: %5.5s\n", @name.to_s, @condition.to_s, @phrase.to_s)
#~ printf (">ID: %10s\n", self.to_s.slice(-10..-1))
#
##
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
##
#DEBUG
#~ printf ("Adding comm.: A:%10.10s c: %5.5s, p: %5.5s\n", action.to_s, object.to_s, helper.to_s)
#~ printf (">IDs: E: %10.10s  C: %10.10s\n", self.to_s.slice(-10..-1), mycommand.to_s.slice(-10..-1))
#
##

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
##
# DEBUG
#~ printf ("Checking %10.10s : %2d\n", self.to_s.slice(-10..-1), check_condition + check_phrase(phrase))
#
##
    if (check_condition + check_phrase(phrase)) > 0 &&
    ((not @unique) || @triggered == 0) # execute

      self.trigger
##
# DEBUG
#~ puts "Triggered!"
#
##
      @commands.each do |command|
##
# DEBUG
#~ printf ("Command! A:%10.10s , O:%5.5s, H:%5.5s\n", command.action.to_s, command.object.to_s, command.helper.to_s)
#~ printf (">IDS: E: %10.10s  C: %10.10s\n", self.to_s.slice(-10..-1), command.to_s.slice(-10..-1))
#
##
        case command.action
          when /replace_object_by_helper/:
            eval('@associated.' + command.object + " = %q{" + command.helper + "} ")

          when /add_helper_to_object/ :
            eval('@associated.' + command.object + " << %q{" + command.helper + "} ")

          when /add_item_to_inventory/:
            @associated.inventory.add_byId(command.object)

          when /withdraw_item_from_inventory/:
            @associated.inventory.withdraw(Item.which(command.object))

          when /pass_item_to_player/:
            myobject = Item.which(command.object)
            @associated.inventory.withdraw(myobject)
            Map.inventory.add(myobject)

          when /retrieve_item_from_player/:
            myobject = Item.which(command.object)
            @associated.inventory.add(myobject)
            Map.inventory.withdraw(myobject)

          when /add_item_to_player_inventory/:
            Map.inventory.add_byId(command.object)

          when /withdraw_item_from_player_inventory/:
            Map.inventory.withdraw(Item.which(command.object))

          when /add_item_to_helper_inventory/:
            Item.which(command.helper).inventory.add_byId(command.object)

          when /withdraw_item_from_helper_inventory/:
            Item.which(command.helper).inventory.withdraw(Item.which(command.object))

          when /add_to_info_of_object/:
            (Item.which(command.object)).info << command.helper

          when /replace_info_of_object/:
            (Item.which(command.object)).info = command.helper

          when /open_door_by_id/:
            (Item.which(command.object)).open

          when /close_door_by_id/:
            (Item.which(command.object)).close

        end # case command.action
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

