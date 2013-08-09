require 'rexml/document'
include REXML

######
####
###
##  
#   Basic Information Structure
##
###
####
######
class GeneralInfo
  def initialize (name, info, look_text)
    @name         = name
    @info         = info
    @look_text    = look_text
    @looks        = 0
  end
  attr_reader :name, :info, :look_text, :looks
  attr_writer :info, :look_text, :looks
  
  def look 
    @looks += 1
    @looks
  end
end

######
####
###
##  
#   Map File Digesting
##
###
####
######

class Map
  @@MAX_INDEX = [2,2]
  @@START_ROOM = [0,1]
  def initialize(mapfile, inventory)
    @room = {}
#    @item = {}
    @items = []
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
        message.attributes["identifier"] ,
        message.text )
    end
    xml.elements.each("Map/item") do |element| 
      item = Item.new(
        element.attributes["item_id"], 
        element.text("identifier"),
        element.text("name"), 
        element.text("info"),
        element.text("look_text")        
      )
      @items.push(item)
      element.elements.each("event") do |event|
        item.add_event(
          event.attributes["name"],
          event.text("unique"),
          event.text("condition"),
          event.text("command"), 
          event.text("object"), 
          event.text("helper"),  
          event.text("message")
        )
      end
    end
      
    xml.elements.each("Map/room") do |xe|
      tmp = xe.attributes["location"].split(/\|/)
      @room[ [tmp[0].to_i, tmp[1].to_i] ] = 
        Room.new(
          xe.text("exits"), 
          xe.attributes["location"],
          xe.text("info"),
          xe.text("look_text")
        )
        xe.elements.each("event") do |event|
          @room[ [tmp[0].to_i, tmp[1].to_i] ].add_event(
            event.attributes["name"],
            event.text("unique"),
            event.text("condition"),
            event.text("command"), 
            event.text("object"), 
            event.text("helper"),  
            event.text("message")
          )
        end
        xe.elements.each("item") do |item|
          @room[ [tmp[0].to_i, tmp[1].to_i] ].inventory.add_byId(item.attributes["item_id"])
      end
    end
    xml.elements.each("Map/start_inventory") do |item|
      inventory.add_byId(item.text)
    end
    @room_id = @@START_ROOM
    self
  end
  attr_reader :welcome_message

######
####
###
##  
#   Map Methods
##
###
####
######


######
#####
####
###
##
# go
#
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
      return Message.text('go_going') +
      case direction
        when /N/: Message.text('go_north')
        when /S/: Message.text('go_south')
        when /E/: Message.text('go_east')
        when /W/: Message.text('go_west')
      end + '...'
    else
      return Message.text('go_nogo')
    end
    
  end 
   
######
#####
####
###
##
# returns current room
#
  def room
    @room[@room_id]
  end
end
