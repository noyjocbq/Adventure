#!/usr/bin/ruby
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
#require 'tk'
#require test/unit

######
#####
####
###
##
# Initialize main message handler, player inventory and map
#
$message_handler = Messager.new
$inventory = Inventory.new
$map = Map.new('map.xml', $inventory)

######
#####
####
###
##
# Issue welcome message
$message_handler.new_screen
$message_handler.pass_message($map.welcome_message, "Hit 'Return' >")
gets

######
#####
####
###
##
# Start program
$message_handler.new_screen
$message_handler.add_message($map.room.info)
$message_handler.commit

######
#####
####
###
##
# Get command and take action

while input = gets.chomp
  ObjectSpace.garbage_collect
  command_handler = Command.new(input)
end
exit true
