require 'aws-sdk'
require_relative '../lib/configs'
require_relative '../lib/PartyConfig'
require_relative '../lib/Accumulator'

class CharacterStats
  attr_reader :actions

  def initialize(actions=[])
    @actions = actions
    @stats = {
        :damage => {
          'MELEE' => ActionAccumulator.new,
          'RANGED' => ActionAccumulator.new,
          'SPELL' => ActionAccumulator.new,
          'WEAPONSKILL' => ActionAccumulator.new,
          'JA' => ActionAccumulator.new
        },
        :curing => {
          'SPELL' => Accumulator.new,
          'JA' => Accumulator.new
        }
    }
    self.update
  end

  def add_action(a)
    @actions.unshift(a)
  end

  def update
    @actions.each do |a|
      next unless(a.format == 'COMBAT')
      subtype = (a.subtype == 'CURE') ? :curing : :damage

      @stats[subtype][a.type].add_action(a)
    end
  end

  def damage_total
    sum = 0
    @stats[:damage].each_value do |accumulator|
      sum += accumulator.damage_total
    end
    return sum
  end
  def curing_total
    sum = 0
    @stats[:curing].each_value do |accumulator|
      sum += accumulator.damage_total
    end
    return sum
  end

  def count
    sum = 0
    @stats.each_pair {|type, data| data.each_value {|a| sum += a.count}}
    return sum
  end

  def to_xml(name='default')
    self.update
    xml = <<XML
  <CharacterStats name="#{name}">
    <damage_total>#{self.damage_total}</damage_total>
    <curing_total>#{self.curing_total}</curing_total>
    <damage>
      #{@stats[:damage].collect {|category, accumulator| "<category><name>#{category}</name><data>#{accumulator.to_xml}</data></category>"}.join("\n        ")}
    </damage>
    <curing>
      #{@stats[:curing].collect {|category, accumulator| "<category><name>#{category}</name>#{accumulator.to_xml}</category>"}.join("\n        ")}
    </curing>
  </stats>
XML
  end
end

class Analyzer
  attr_accessor :party_id
  attr_accessor :bucket
  attr_reader :stats

  def initialize(party_id=nil)
    @party_id = party_id
    @stats = {}
    @bucket = CONFIGS[:aws][:s3][:analysis_bucket]
  end

  # Produce offense statistics for the PCs in the party from the provided 
  #  set of Actions.
  # If no actions are specified, then #fetch_actions will be called to attempt 
  #  to load the action set from the configured remote data store.
  # If actions are specified, the caller can optionally specify a set of PCs
  #  to override the @party_id configuration setting.
  # @param actions [Array] The set of Action objects to generate stats from.
  # @return [String] A textual report summarizing the stats.
  def analyze_offense(actions=nil, player_characters=nil)
    return false if (!actions.nil? && !actions.kind_of?(Array))
    
    if (player_characters.nil? && @party_id.nil?)
      # No party config given
      return false 
    end

    if (player_characters.nil?)
      # Load the party config from the db
      pconfig = PartyConfig.new
      if (!pconfig.load(@party_id))
        LOGGER.error {"Unable to load party configuration for id #{@party_id}"}
        return false
      end  
      player_characters = pconfig.player_characters
    end

    # If no actions are provided, attempt to pull the set of Actions 
    # performed by this party from a remote data store (probably a 
    # mongodb or dynamodb somewhere)
    actions = self.fetch_actions if (actions.nil? && !@party_config.nil?)
    
    # Initialize the stats array for each of the party's PCs
    @stats = {:overall => CharacterStats.new, :player_characters => {}}
    player_characters.each do |pc_name|
      @stats[:player_characters][pc_name] = CharacterStats.new
    end

    # Add each of the Actions to the relevant Statistics Engines
    actions.each do |a|
      next if (a.actor.nil?)
      # Skip the action if there is a specified party config and 
      next if (!player_characters.nil? && !player_characters.include?(a.actor))
      @stats[:overall].add_action(a)
      @stats[:player_characters][a.actor].add_action(a)
    end

    # Remove party members who did nothing
    @stats[:player_characters].each_key do |pc_name|
      @stats[:player_characters][pc_name] = nil if (@stats[:player_characters][pc_name].count == 0)
    end
    @stats[:player_characters].compact!

    # Generate an XML Report
    report = <<XML
<OffenseAnalysis>
  <timestamp>#{Time.now.utc}</timestamp>
  <stats name="overall">
    #{@stats[:overall].to_xml}
  </stats>
  #{@stats[:player_characters].collect {|name, accumulator| "<stats name=\"#{name}\">\n      #{accumulator.to_xml}\n    </stats>"}.join("\n    ")}
</OffenseAnalysis>
XML

    # Write the results to S3 if a party config is specified
    if (!@party_config.nil?)
      output_filename = "#{@party_id}.offense.xml"
      upload_analysis(output_filename, output_data)
    end

    # Return the report we created
    report
  end

  def fetch_actions
    bucket = AWS::S3.new.buckets[CONFIGS[:aws][:s3][:data_bucket]]
    if (bucket.nil? || !bucket.exists?)
      return nil
    end

    obj = bucket.objects["#{@party_id}.data"]
    if (obj.nil? || !obj.exists?)
      return nil
    end

    @actions = obj.read
    @actions = @actions.split("\n")
    @actions.collect! do |line| 
      if (line.strip.length == 0)
        nil
      else
        line.strip
      end
    end
    @actions.compact!
    return true
  end

  def add_action(row)
    a = Action.parse_row(row)
    @accumulator.add(a)
    dmg = a.data[:damage]
    actor = a.data[:actor]

    if (!dmg.nil? && @party_config.player_characters.include?(actor))  # COMBAT type row
      case (row[3])
      when 'MELEE'
        @accumulators[:melee].add_datum(dmg) 
      when 'WS'
        @accumulators[:weaponskill].add_datum(dmg)
      when 'MAGIC'
        @accumulators[:magic].add_datum(dmg)
      when 'JA'
        @accumulators[:ja].add_datum(dmg)
      end
    end
  end

  def upload_analysis(filename, data)
    s3 = AWS::S3.new
    LOGGER.d("Writing analysis: Bucket '#{@bucket}', Filename '#{filename}', Data Length #{data.length}")
    b = s3.buckets[@bucket]
    o = b.objects[filename]
    o.write(data)
  end
end


