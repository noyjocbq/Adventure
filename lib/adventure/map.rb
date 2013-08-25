####
###
##
#   Module Map
##  Map file digest
###
#### v0.6
require 'rexml/document'
include REXML

module Map
  @@max_index = [2,2]
  @@start_room = '0|1'
  @@name = 'untitled'
  @@current_room = ''
  @@initial = true
  @@inventory = Inventory.new
  @@welcome_message = ''
  @@events = []
  attr_reader :name, :current_room, :welcome_message, :inventory, :events #, :initial
#  attr_writer :initial

####
###
## Some helper methods
#
#
  def welcome_message
    @@welcome_message
  end

  def inventory
    @@inventory
  end

  def events
    @@events
  end

  def name
    @@name
  end

  def initial?
    if @@initial == true
      @@initial = false
      return true
    end
    return false
  end

####
###
## Read and digest the map file
#
#
  def read_map(mapfile)
    mapfile = File.join("lib", "adventure", "data", mapfile)
    xml = Document.new(File.open(mapfile))
    @@name = xml.root.attributes["name"]

    xml.elements.each("Map/variable") do |e|
      tmp = e.attributes["value"].split(/\|/)
      case e.attributes["name"]
        when /MAX_INDEX/  : @@max_index = [tmp[0].to_i, tmp[1].to_i]
        when /START_ROOM/ : @@start_room = e.attributes["value"]
        when /WELCOME_MESSAGE/ : @@welcome_message = e.text
      end
    end # xml.elements.each("Map/variable")

    xml.elements.each("Map/message") do |message|
      mymessage = Message.new(
        message.attributes["message_id"] ,
        message.text)
    end # xml.elements.each("Map/message")

    xml.elements.each("Map/item") do |item|
      myitem = Thing.new(
        item.attributes["item_id"],
        item.text("identifier"),
        item.text("use_with"),
        item.text("name"),
        item.text("info"),
        item.text("look_text")
      )
      item.elements.each("event") do |event|
        myevent = myitem.add_event(
          event.attributes["name"],
          event.text("unique"),
          event.text("condition"),
          event.text("phrase"),
          event.text("message")
        )
        event.elements.each("command") do |command|
          myevent.add_command(
            command.text("action"),
            command.text("object"),
            command.text("helper")
          )
        end #xml.elements.each("command") do |command|
      end # element.elements.each("event") do |event|
    end # xml.elements.each("Map/item") do |element|

    xml.elements.each("Map/person") do |person|
      myperson = Person.new(
        person.attributes["person_id"],
        person.text("identifier"),
        person.text("name"),
        person.text("info"),
        person.text("look_text")
      )
      person.elements.each("item") do |item|
        myperson.add_thing(
          item.attributes["item_id"],
          item.text("identifier"),
          item.text("use_with"),
          item.text("name"),
          item.text("info"),
          item.text("look_text")
        )
      end
      person.elements.each("event") do |event|
        myevent = myperson.add_event(
          event.attributes["name"],
          event.text("unique"),
          event.text("condition"),
          event.text("phrase"),
          event.text("message")
        )
        event.elements.each("command") do |command|
          myevent.add_command(
            command.text("action"),
            command.text("object"),
            command.text("helper")
          )
        end #xml.elements.each("command") do |command|
      end # person.elements.each("event") do |event|
    end #xml.elements.each("Map/person") do |person|

    xml.elements.each("Map/door") do |door|
      mydoor = Door.new(
        door.attributes["door_id"],
        door.text("identifier"),
        door.text("exit"),
        door.text("open"),
        door.text("key"),
        door.text("name"),
        door.text("info"),
        door.text("look_text")
      )
      door.elements.each("item") do |item|
        mydoor.add_thing(
          item.attributes["item_id"],
          item.text("identifier"),
          item.text("use_with"),
          item.text("name"),
          item.text("info"),
          item.text("look_text")
        )
      end
      door.elements.each("event") do |event|
        myevent = mydoor.add_event(
          event.attributes["name"],
          event.text("unique"),
          event.text("condition"),
          event.text("phrase"),
          event.text("message")
        )
        event.elements.each("command") do |command|
          myevent.add_command(
            command.text("action"),
            command.text("object"),
            command.text("helper")
          )
        end #xml.elements.each("command") do |command|
      end # person.elements.each("event") do |event|
    end #xml.elements.each("Map/door") do |door|

    xml.elements.each("Map/room") do |room|
      myroom = Room.new(
        room.attributes["room_id"],
        room.text("identifier"),
        room.text("exits"),
        room.text("name"),
        room.text("info"),
        room.text("look_text")
      )
      room.elements.each("event") do |event|
        myevent = myroom.add_event(
          event.attributes["name"],
          event.text("unique"),
          event.text("condition"),
          event.text("phrase"),
          event.text("message")
        )
        event.elements.each("command") do |command|
          myevent.add_command(
            command.text("action"),
            command.text("object"),
            command.text("helper")
          )
        end #xml.elements.each("command") do |command|
      end # room.elements.each("event") do |event|

      room.elements.each("item") do |item|
        myroom.add_thing(
          item.attributes["item_id"],
          item.text("identifier"),
          item.text("use_with"),
          item.text("name"),
          item.text("info"),
          item.text("look_text")
        )
      end # room.elements.each("item") do |item|

      room.elements.each("door") do |door|
        mydoor = myroom.add_door(
          door.attributes["door_id"],
          door.text("identifier"),
          door.text("exit"),
          door.text("open"),
          door.text("key"),
          door.text("name"),
          door.text("info"),
          door.text("look_text")
        )
        door.elements.each("item") do |item|
          mydoor.add_thing(
            item.attributes["item_id"],
            item.text("identifier"),
            item.text("use_with"),
            item.text("name"),
            item.text("info"),
            item.text("look_text")
          )
        end #door.elements.each("item") do |item|
        door.elements.each("event") do |event|
          myevent = mydoor.add_event(
            event.attributes["name"],
            event.text("unique"),
            event.text("condition"),
            event.text("phrase"),
            event.text("message")
          )
          event.elements.each("command") do |command|
            myevent.add_command(
              command.text("action"),
              command.text("object"),
              command.text("helper")
            )
          end #xml.elements.each("command") do |command|
        end # door.elements.each("event") do |event|
      end # room.elements.each("door") do |door|

      room.elements.each("person") do |person|
        myperson = myroom.add_person(
          person.attributes["person_id"],
          person.text("identifier"),
          person.text("name"),
          person.text("info"),
          person.text("look_text")
        )

        person.elements.each("item") do |item|
          myperson.add_thing(
          item.attributes["item_id"],
          item.text("identifier"),
          item.text("use_with"),
          item.text("name"),
          item.text("info"),
          item.text("look_text")
        )
        end

        person.elements.each("event") do |event|
          myevent = myperson.add_event(
            event.attributes["name"],
            event.text("unique"),
            event.text("condition"),
            event.text("phrase"),
            event.text("message")
          )
          event.elements.each("command") do |command|
            myevent.add_command(
              command.text("action"),
              command.text("object"),
              command.text("helper")
            )
          end #xml.elements.each("command") do |command|
        end # person.elements.each("event") do |event|
      end # room.elements.each("person") do |person|
    end # xml.elements.each("Map/room") do |room|

    xml.elements.each("Map/event") do |event|
      myevent = Map.add_event(
        event.attributes["name"],
        event.text("unique"),
        event.text("condition"),
        event.text("phrase"),
        event.text("message")
      )
      event.elements.each("command") do |command|
        myevent.add_command(
          command.text("action"),
          command.text("object"),
          command.text("helper")
        )
      end #xml.elements.each("command") do |command|
    end # xml.elements.each("Map/event") do |event|

    xml.elements.each("Map/start_inventory") do |item|
      @@inventory.add_byId(item.text)
    end
    @@current_room = Map.room(@@start_room)
    @@current_room.visit
    self
  end


#
##
###
#### Other Methods

####
###
##
# go
#
  def go(direction)
    direction = direction[0,1].upcase
    location = @@current_room.item_id.split(/\|/)
    [0,1].each {|i| location[i] = location[i].to_i }
    goto = case direction
      when /^N/ : [ 0,-1]
      when /^S/ : [ 0, 1]
      when /^E/ : [ 1, 0]
      when /^W/ : [-1, 0]
    end
    if room.exits =~ /#{direction}/
      [0,1].each do |i|
        location[i] = case
          when location[i] + goto[i] > @@max_index[i] : 0
          when location[i] + goto[i] < 0 : @@max_index[i]
          else                         location[i] + goto[i]
        end
      end
      @@current_room = room(location.join("|"))
      @@current_room.visit
      return true
    else
      return false
    end

  end

####
###
##
# returns current room or room identified by location "x|y"
#
  def room(location = nil)
    return @@current_room if location.nil?
    Item.allRooms.each do |r|
      return r if r.item_id == location
    end
#    @room[@room_id]
  end

####
###
##
# Add a map event
#
  def add_event(name, unique, condition, phrase, message)
    event = Event.new(name, unique, condition, phrase, command, object, helper, message, 'Map')
    @@events.push(event)
    event
  end

end

