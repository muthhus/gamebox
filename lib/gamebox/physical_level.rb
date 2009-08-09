# Levels represent on level of game play.  Some games will likely have only one
# level. Level is responsible for loading its background, props, and directors.
# PhysicalLevel adds a physics space to the Level
require 'level'
require 'physics'
require 'physical_director'
class PhysicalLevel < Level
  
  attr_accessor :space

  def initialize(actor_factory, resource_manager, sound_manager, input_manager, viewport, opts={}) 
    @actor_factory = actor_factory
    @director = PhysicalDirector.new
    @actor_factory.director = @director

    @resource_manager = resource_manager
    @sound_manager = sound_manager
    @input_manager = input_manager
    @viewport = viewport
    @opts = opts

    @space = Space.new
    @space.iterations = 20
    @space.elastic_iterations = 5

    setup
  end

  PHYSICS_STEP = 25.0
  def update_physics(time)
    unless @physics_paused
      steps = (time/PHYSICS_STEP).ceil
      # from chipmunk demo
      dt = 1.0/60/steps
      steps.times do
        @space.step dt
      end
    end
  end
  
  def pause_physics
    @physics_paused = true
  end
  
  def restart_physics
    @physics_paused = false
  end

  def update(time)
    update_physics time
    super
  end

  def register_physical_object(obj,static=false)
    if static
      obj.shapes.each do |shape|
        @space.add_static_shape shape
      end
    else
      @space.add_body(obj.body)
      
      obj.shapes.each do |shape|
        @space.add_shape shape
      end
    end
  end

  def register_physical_constraint(constraint)
    @space.add_constraint constraint
  end

  def unregister_physical_constraint(constraint)
    @space.remove_constraint constraint
  end

  def unregister_physical_object(obj,static=false)
    if static
      obj.physical.shapes.each do |shape|
        @space.remove_static_shape shape
      end
    else
      @space.remove_body(obj.body)
      
      obj.physical.shapes.each do |shape|
        @space.remove_shape shape
      end
    end
  end

end
