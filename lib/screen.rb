####
###
##
#  Main window module
##
###
#### v0.6

module Screen

  require 'tk'
#  require Messager
  include Command

  @@messagefont = TkFont.new("family" => 'Times',
                           "size" => 12,
                           "weight" => 'bold')
  @@inputfont =   TkFont.new("family" => 'Helvetica',
                           "size" => 12)
  @@echofont =    TkFont.new("family" => 'Helvetica',
                           "size" => 10,
                           "weight" => 'bold')
#   Root object: Game window

  def prompt
    ">"
  end


  def win_root
    if @win_root.nil?
      @win_root  =  TkRoot.new() {
        title(@title)
       minsize(400, 400)
      }
      TkGrid.columnconfigure @win_root, 0, :weight=>0
      TkGrid.columnconfigure @win_root, 1, :weight=>1
      TkGrid.rowconfigure @win_root, 0, :weight=>5
      TkGrid.rowconfigure @win_root, 1, :weight=>1
      TkGrid.rowconfigure @win_root, 2, :weight=>0

    end # if
    return @win_root
  end #root

# Message screen
  def win_message
    if @win_message.nil?
      @win_message = TkText.new(win_root) {
        height 20
        font @@messagefont
        takefocus 0
      }
      @win_message.pack("side"=>"top", "fill"=>"x")
      @win_message.grid("columnspan"=>2, "sticky"=>"nsew")
      @win_message.configure("state"=>"normal")
      @win_message.insert('end', Map.welcome_message)
      @win_message.configure("state"=>"disabled")
    end #if
    return @win_message
  end # message

# Input echo screen
  def win_echo
    if @win_echo.nil?
      @win_echo = TkText.new(win_root) {
        height 5
        font @@echofont
        takefocus 0
        foreground 'darkgrey'
      }
      @win_echo.pack("side"=>"top", "fill"=>"x")
      @win_echo.grid("columnspan"=>2, "sticky"=>"nsew")
      @win_echo.configure("state"=>"disabled")
    end #if
    return @win_echo
  end #echo

# Input line window
  def win_input
    if @win_input.nil?
      win_prompt = TkLabel.new(win_root) {
        text ">"
        width 2
        height 1
        font @@inputfont
        takefocus 0 }
      win_prompt.grid("column"=>0, "row"=>2, "sticky"=>"ew")
      @win_input = TkText.new(win_root) {
        height 1
        font @@inputfont
        takefocus 1 }
      @win_input.pack("side"=>"bottom")
      @win_input.grid("column"=>1, "row"=>2, "sticky"=>"ew")
      @win_input.insert('end', "Press Return...")
      @win_input.bind('KeyPress-Return') {
        return_pressed
      }
      @win_input.focus
    end #if
    return @win_input
  end #input

####
###
##
# what to do when return key was pressed
  def return_pressed
    phrase = win_input.get("1.0", "end").chomp.sub(Regexp.new(prompt), '').sub("\n", '')
      Command.digest(phrase)
      echo_win(phrase + "\n")
      win_input.delete("1.0", "end")
  end #  return_pressed

####
###
##
# pass message text to the message window
  def message_win(text)
    Screen.win_message.configure("state"=>"normal")
    Screen.win_message.insert('end', text)
    while Screen.win_message.index("end - 1 line").split('.')[0].to_i > 20
      Screen.win_message.delete(1.0, 2.0)
    end
    Screen.win_message.configure("state"=>"disabled")
    text
  end # message_win

####
###
##
# pass message text to the echo window
  def echo_win(text)
    win_echo.configure("state"=>"normal")
    win_echo.insert('end', "#{text}")
    while win_echo.index("end - 1 line").split('.')[0].to_i > 5
      win_echo.delete(1.0, 2.0)
    end
    win_echo.configure("state"=>"disabled")
    text
  end # echo_win

####
###
##
# start the whole affair
  def start (titel = 'unnamed')
    @win_titel = titel
    @win_root = win_root
    @win_message = win_message
    @win_echo = win_echo
    @win_input = win_input
  end #start

end #module
