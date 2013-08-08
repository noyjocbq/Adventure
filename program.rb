#require "./resources"
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
#require 'tk'
require test/unit

##
# Initialize main message handler, player inventory and map
#
class TestClass < Test::Unit::TestCase
  def test_01
    assert
end

$message_handler = Messager.new
$inventory = Inventory.new
map = Map.new('map.xml', $inventory)

##
# Issue welcome message

$message_handler.pass_message(map.welcome_message)
gets

##
# Start program

$message_handler.add_message(map.room.info)
$message_handler.commit

##
# Get command and take action

while input = gets.chomp
  command_handler = Command.new(input)
#  puts  map.room.events.each {|e| e.check }
  case 
  when command_handler.verb == "go" then
    if $message_handler.add_message(map.go(command_handler.object)) !~ /cannot/ then
      map.room.events.each{|e| e.check }
      $message_handler.add_message(map.room.info)
    end
    $message_handler.commit
  when command_handler.verb == "inventory" then
    $message_handler.add_message(
      "This is what you carry with you: \n\n" + 
      $inventory.list.join("\n")
    )
    $message_handler.commit
  when command_handler.verb == "take" then
    $inventory.add(Item.whatis(command_handler.object))
    map.room.inventory.withdraw(Item.whatis(command_handler.object))
  when command_handler.verb == "help" then
    help(command_handler.object)
  when command_handler.verb == "unknown" then
    $message_handler.pass_message("Sorry, I didn't quite understand you... ")
  when command_handler.verb == "quit" then
    exit
  when command_handler.verb == "look" then
    command_handler.object = map.room
puts    command_handler.execute
  end
end

#include Screen

#fenster = Screen.new(800,600,'Adventure')
#Tk.mainloop
#puts map
#room_id = '11'
#puts map.room.exits
#puts map.room.info
#puts map.go('E')
