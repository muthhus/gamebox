require 'actor'

class MajorRuby < Actor

  has_behavior :animated, :updatable, :layered => {:layer => 4}
  attr_accessor :move_left, :move_right, :jump
  def setup
    @speed = 8
    @vy = 0
    @map = @opts[:map]
    input_manager.while_key_pressed :left, self, :move_left
    input_manager.while_key_pressed :right, self, :move_right
    input_manager.while_key_pressed :up, self, :jump
    input_manager.reg KeyPressed, :up do 
      try_to_jump
    end
  end

  def update(time_delta)
    # TODO sucks that I have to call this here to update my behaviors
    super 

    time_delta = time_delta/25.floor

    if move_right
      (@speed * time_delta).times do
        move 1, 0
      end
      self.action = :move_right unless self.action == :move_right
    elsif move_left
      (@speed * time_delta).times do
        move -1, 0
      end
      self.action = :move_left unless self.action == :move_left
    else
      self.action = :idle
    end
    if @vy < 0
      self.action = :jump unless self.action == :jump
    end

    time_delta.times { apply_gravity }

  end

  def apply_gravity
    @vy += 1
    if @vy < 0 
      (-@vy).times { if would_fit?(0, -1) then @y -= 1 else @vy = 0 end }
    end
    if @vy > 0 
      (@vy).times do 
        if would_fit?(0, 1) 
          if (move_left and !would_fit?(-1,0)) || 
            (move_right and !would_fit?(1,0)) 
            fall_rate = 0.2
          else
            fall_rate = 1
          end
          @y += fall_rate
        else 
          @vy = 0 
        end 
      end
    end
  end

  def try_to_jump
    if !would_fit?(0, 1) || (move_left and !would_fit?(-1,0)) || 
      (move_right and !would_fit?(1,0)) 
#      play_sound :jump
      @vy = -20
    end
  end

  def move(dx,dy)
    if would_fit?(dx,0)
      @x += dx 
    end
    if would_fit?(0,dy)
      @y += dy 
    end
  end

  def would_fit?(x_off, y_off)
    not @map.solid? @x.floor+x_off+10, @y.floor+y_off+5 and
    not @map.solid? @x.floor+x_off+40, @y.floor+y_off+5 and
    not @map.solid? @x.floor+x_off+10, @y.floor+y_off+45 and
      not @map.solid? @x.floor+x_off+40, @y.floor+y_off+45 
  end

  def collect_gems(gems)
    collected = []
    gems.each do |pg|
      matched = false
      if (pg.x+25 - @x).abs < 50 and (pg.y+25 - @y).abs < 50
        matched = true
        play_sound :pretty
        pg.remove_self
        collected << pg
      end
      matched
    end
    collected
  end
end