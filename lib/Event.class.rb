class Event
  @@events = []
  def initialize (name, condition, command, object, second_object, message, associated)
    @triggered        = false
    @name             = name
    @condition        = condition
    @command          = command
    @object           = object
    @second_object    = second_object
    @message          = message
    @associated       = associated
    @@events.push(self)
  end
  ################################
attr_reader :name, :condition, :command, :object, :second_object, :message, :triggered, :associated
  ################################
  def trigger
    @triggered = true
    @triggered
  end
  ################################
  def check
    answer = ''
    if eval('@associated.' + @condition)
      answer = case @command
        when /replace/: eval('@associated.' + @object + " = %q{" + @second_object + "} ")      
        else nil
      end
    end
    answer
  end

end
