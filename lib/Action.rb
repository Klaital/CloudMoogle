
class Action
  attr_reader :data
  def initialize
    @data = {
      :type => nil,
      :subtype => nil,
      :actor => nil,
      :target => nil,
      :damage => 0,
      :ability_name => nil,
      :light => nil,
      :format => nil
    }
  end

  def type
    @data[:type]
  end
  def subtype
    @data[:subtype]
  end
  attr_accessor :type, :subtype
  attr_accessor :actor, :target
  attr_accessor :damage
  attr_accessor :ability_name
  
end
