require 'rexml/document'
include REXML

class Map
  @@MAX_INDEX = [2,2]
  @@START_ROOM = [0,1]
  def initialize(mapfile, inventory)
    @room = {}
    @item = {}
    @message = {}
    @room_id = []
    @welcome_message = ''
    xml = Document.new(File.open(mapfile))
    xml.elements.each("Map/variable") do |e|
      tmp = e.attributes["value"].split(/\|/)
      case e.attributes["name"]
        when /MAX_INDEX/  : @@MAX_INDEX = [tmp[0].to_i, tmp[1].to_i]
        when /START_ROOM/ : @@START_ROOM = [tmp[0].to_i, tmp[1].to_i]
#        when /WELCOME_MESSAGE/ : @welcome_message = e.attributes["value"]
        when /WELCOME_MESSAGE/ : @welcome_message = e.text
      end
    end
    xml.elements.each("Map/message") do |message|
      @message[ message.attributes["identifier"] ] = 
      Message.new(
        message.text,
        message.attributes["identifier"] )
    end
    xml.elements.each("Map/item") do |item| 
      @item[ item.attributes["item_id"] ] = Item.new(
        item.attributes["item_id"], 
        item.text("name"), 
        item.text("identifier"),
        item.text("look_text")        
      )
    end
    xml.elements.each("Map/room") do |room|
      tmp = room.attributes["location"].split(/\|/)
      @room[ [tmp[0].to_i, tmp[1].to_i] ] = 
        Room.new(
          room.text("exits"), 
          room.text("info"),
          room.text("look_text")
        )
    end
    xml.elements.each("Map/room/event") do |event|
      tmp = event.parent.attributes["location"].split(/\|/)
      @room[ [tmp[0].to_i, tmp[1].to_i] ].add_event(
        event.attributes["name"],
        event.text("condition"),
        event.text("command"), 
        event.text("object"), 
        event.text("second_object"),  
        event.text("message")
      )
    end
    xml.elements.each("Map/room/item") do |item|
      tmp = item.parent.attributes["location"].split(/\|/)
      @room[ [tmp[0].to_i, tmp[1].to_i] ].inventory.add_byId(item.attributes["item_id"])
    end
    xml.elements.each("Map/start_inventory") do |item|
      inventory.add_byId(item.text)
    end
    @room_id = @@START_ROOM
    self
  end
  attr_reader :welcome_message
#  attr_reader :room, :room_id, :welcome_message
#  attr_writer :room, :room_id

#-------------------------------
#
#-------------------------------


  def go(direction)
    direction = direction[0,1].upcase
    goto = case direction
      when /^N/ : [ 0,-1]
      when /^S/ : [ 0, 1]
      when /^E/ : [ 1, 0]
      when /^W/ : [-1, 0]
    end
    if room.exits =~ /#{direction}/
      [0,1].each do |i| 
        @room_id[i] = case 
          when @room_id[i] + goto[i] > @@MAX_INDEX[i] : 0
          when @room_id[i] + goto[i] < 0 : @@MAX_INDEX[i]
          else                         @room_id[i] + goto[i]
        end 
      end
      @room[ @room_id ].visit
      return "Going " +
      case direction
        when /N/: 'North'
        when /S/: 'South'
        when /E/: 'East'
        when /W/: 'West'
      end + '...'
    else
      $message_handler.add_message("You cannot go in that direction!")
      return "You cannot go in that direction!"
    end
    
  end 
   
  ################################
  
  def room
    @room[@room_id]
  end
end
