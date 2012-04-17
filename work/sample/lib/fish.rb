# = Fish Sampler
# 
# Let us review... Red fish, Blue fish, One fish, Two fish...
#
module FishSampler

  class << self
    # Example of a class-level attribute.
    attr_reader :fishy_active
  end

  # Every fish is scaly.
  DEFALULT_QUALITIES = [ :scaly ]

  # A fish is any aquatic vertebrate animal that is typically ectothermic (or cold-blooded),
  # covered with scales, and equipped with two sets of paired fins and several unpaired fins.
  # Fish are abundant in the sea and in fresh water, with species being known from mountain
  # streams (e.g., char and gudgeon) as well as in the deepest depths of the ocean
  # (e.g., gulpers and anglerfish).

  class Fish
    # List of various fish qualities.
    attr_accessor :qualities

    # New Fish
    def initialize
      @qualities = DEFALULT_QUALITIES
      initialize_qualities
    end

    # Override to add qualties.
    def initialize_qualities
    end

    # Another term for qualities.
    alias_method :properties, :qualities 
  end

  # = Brite Red Fish
  #
  # Red fish are quite pretty a fairly common.
  class RedFish
    # List of various fish qualities.
    attr_accessor :qualities

    # New Red Fish
    def initialize_qualities
      super
      @qualties << :red
    end
  end

  # = Blue Fish
  #
  # Despite their name most Bluefish aren't very blue.
  class BlueFish < Fish
    # List of various fish qualities.
    attr_accessor :qualities

    # New Blue Fish
    def initialize_qualities
      super
      @qualties << :blue
    end
  end

  # Fish get old too.
  class OldFish < Fish
    # List of various fish qualities.
    attr_accessor :qualities

    # New Old Fish
    def initialize_qualities
      super
      @qualties << :old
    end
  end

  # It's hard to tell new fish form small fish.
  class NewFish < Fish
    # List of various fish qualities.
    attr_accessor :qualities

    # New NewFish
    def initialize_qualities
      super
      @qualties << :new
    end
  end

  # Some fish will eat a man!
  module ManEater
    # Man Eaters are scary!
    def initialize_qualities
      super
      @qualties << :scary
    end
  end

  # = Shark (Yikes!)
  #
  # Sharks (superorder Selachimorpha) are a type of fish with a full cartilaginous skeleton
  # and a highly streamlined body. The earliest known sharks date from more than 420 million
  # years ago, before the time of the dinosaurs.
  #
  class Shark < Fish
    include ManEater

    # New Shark
    def initialize_qualities
      super
      @qualties << :big
    end

  private

    def secret
      puts "Shh... shark secrets!"
    end

  end

end

