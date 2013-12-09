
class Action
  attr_reader :data
  attr_accessor :incomplete
  def initialize
    @data = {
      :type => nil,
      :subtype => nil,
      :actor => nil,
      :target => nil,
      :damage => nil, # nil damage on a combat action implies a miss
      :ability_name => nil,
      :light => nil,
      :format => nil
    }
    @incomplete = true
  end

  def complete?
    return !@incomplete
  end
  def incomplete?
    @incomplete
  end

  # Serialize the Action to a string
  # @return [String] Human-readable single-line representation of the Action
  def to_s
    "<Action type:'#{@data[:type]}' subtype:'#{@data[:subtype]}' actor:'#{@data[:actor]}' target:'#{@data[:target]}' damage:#{@data[:damage]} ability:'#{@data[:ability_name]}' light:#{@data[:light]} format:#{@data[:format]}>"
  end
  # Serialize the Action to a TSV row
  # @return [String] A Tab-Separated Values data row with the action's data.
  def to_tsv
    "#{@data[:format]}\t#{@data[:type]}\t#{@data[:subtype]}\t#{@data[:actor]}\t#{@data[:target]}\t#{@data[:damage]}\t#{@data[:ability_name]}\t#{@data[:light]}"
  end
  def Action.parse_tsv(line)
    a = Action.new
    tokens = line.split("\t").collect {|t| (t.strip.length == 0) ? nil : t.strip}
    return nil if (tokens.length < 8)
    a.format = tokens[0]
    a.type = tokens[1]
    a.subtype = tokens[2]
    a.actor = tokens[3]
    a.target = tokens[4]
    a.damage = tokens[5]
    a.ability_name = tokens[6]
    a.light = tokens[7]
    
    return a
  end
  # Serialize the Action into XML
  # @return [String] XML representation of the action data.
  def to_xml
    xml = '<Action>'
    @data.each_pair {|k,v| xml += "<#{k}>#{v}</#{k}>"}
    xml += '</Action>'
  end
  # Serialize the Action into JSON.
  # @return [String] JSON representation of the action data.
  def to_json
    j = "{\n"
    @data.each_pair {|k,v| j += "#{k}:'#{v}'\n"}
    j += '}'
  end

  # This should match the (root) name of the Pattern method that matched this actoin.
  # @return [String] root part of the pattern name. Computed as "$type_$subtype"
  def pattern_name
    return nil if (@data[:type].nil? || @data[:subtype].nil?)
    "#{@data[:type].downcase}_#{@data[:subtype].downcase}"
  end

  def type
    @data[:type]
  end
  def type=(val)
    @data[:type] = val
  end
  def subtype
    @data[:subtype]
  end
  def subtype=(val)
    @data[:subtype] = val
  end
  def actor
    @data[:actor]
  end
  def actor=(val)
    @data[:actor] = val
  end
  def target
    @data[:target]
  end
  def target=(val)
    @data[:target] = val
  end
  def damage
    @data[:damage]
  end
  # Set the damage dealt duing the action. Forces any non-nil value to an integer using #to_i.
  def damage=(val)
    @data[:damage] = (val.nil?) ? nil : val.to_i
  end
  def ability_name
    @data[:ability_name]
  end
  def ability_name=(val)
    @data[:ability_name] = val
  end
  def light
    @data[:light]
  end
  def light=(val)
    @data[:light] = val
  end
  def format
    @data[:format]
  end
  def format=(val)
    @data[:format] = val
  end
end
