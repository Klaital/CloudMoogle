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

  def analyze_by_players(actions, player_characters=[])
    # Error trapping: Make sure we have some data to work with
    return false if (actions.nil? || player_characters.nil? || actions.empty? || player_characters.empty?)

    # Pre-populate the results hash with keys for each of the participating PCs
    pc_data = {}
    player_characters.each do |pc|
      # TODO: add tracking for ability/ability_breakdown
      pc_data[pc] = {
        :damage_dealt_total => 0,
        :damage_dealt_breakdown => {}, # This will be 'mobname' => DMG_SUM
        :damage_taken_total => 0,
        :damage_taken_breakdown => {}, # This will be 'mobname' => DMG_SUM
        :curing_total => 0,
        :curing_breakdown => {}, # This will be 'recipient_name' => CURE_SUM
        :rate_counts => {
          "MELEE" => {
            "HIT" => 0,
            "CRIT" => 0,
            :count => 0
          },
          "WEAPONSKILL" => {
            "HIT" => 0,
            :count => 0,
            :by_ability => {} # This will be 'ability name' => {:hit => 0, :count => 0, :damage => 0}
          },
          "RANGED" => {
            "HIT" => 0,
            "CRIT" => 0,
            "SQUARE" => 0,
            "PUMMEL" => 0,
            :count => 0
          }
        },
        :hitrates => {
          "MELEE" => 0,
          "WEAPONSKILL" => 0,
          "RANGED" => 0
        },
        :damage_dealt_share => 0.0,
        :damage_taken_share => 0.0,
        :cure_share => 0.0
      }
    end

    # Keep track of some global numbers
    total_damage_dealt = 0
    total_damage_taken = 0
    total_curing       = 0

    actions.each do |a|
      if (player_characters.include?(a.actor))
        # Action performed by a party memeber

        # Track count of the ability/crit/etc. 
        # Used to compute hitrates/critrates later during postprocessing.
        # TODO: track count & damage for weaponskills & abilities broken down by name
        if (pc_data[a.actor][:rate_counts].keys.include?(a.type))
          pc_data[a.actor][:rate_counts][a.type][:count] += 1
          if (pc_data[a.actor][:rate_counts][a.type].keys.include?(a.subtype) && !a.damage.nil?) # nil damage implies a miss
            pc_data[a.actor][:rate_counts][a.type][a.subtype] += 1
          end
        end

        
        if (a.subtype == 'CURE' && !a.damage.nil?)
          # Track cures
          total_curing += a.damage
          pc_data[a.actor][:curing_total] += a.damage
          if (!pc_data[a.actor][:curing_breakdown].keys.include?(a.target))
            # Initialize the breakdown hash to track cures to this target
            pc_data[a.actor][:curing_breakdown][a.target] = 0
          end
          pc_data[a.actor][:curing_breakdown][a.target] += a.damage

        elsif (!a.damage.nil?)
          # Track damage dealt
          total_damage_dealt += a.damage
          pc_data[a.actor][:damage_dealt_total] += a.damage
          if (!pc_data[a.actor][:damage_dealt_breakdown].keys.include?(a.target))
            # Initialize the breakdown hash to track damage to this target
            pc_data[a.actor][:damage_dealt_breakdown][a.target] = 0
          end
          pc_data[a.actor][:damage_dealt_breakdown][a.target] += a.damage
        end


      elsif (player_characters.include?(a.target))
        # Action performed against a party member
        next if (a.damage.nil?) # not tracking party members' evasion rates yet
        next if (a.subtype == 'CURE') # not tracking enemies/outsiders curing PCs yet

        total_damage_taken += a.damage
        pc_data[a.target][:damage_taken_total] += a.damage
      end
    end

    # Postprocessing: compute second-order stats
    pc_data.each_pair do |pc, data|
      # Compute the hit rates based on this hit counts
      data[:rate_counts].each_pair do |type, count_data|
        total_hits = count_data['HIT'] # This element is always present
        total_hits += count_data['CRIT'] if(count_data.keys.include?('CRIT')) # not present for WS
        total_hits += count_data['SQUARE'] if(count_data.keys.include?('SQUARE')) # only for Ranged
        total_hits += count_data['PUMMEL'] if(count_data.keys.include?('PUMMEL')) # only for Ranged

        data[:hitrates][type] = if (count_data[:count] == 0)
          0
        else
          total_hits * 100.0 / count_data[:count]
        end
      end

      # Compute the % of total damage done/taken/cured by this player
      data[:damage_dealt_share] = if (total_damage_dealt == 0)
        0
      else
        data[:damage_dealt_total] * 100.0 / total_damage_dealt
      end
      data[:damage_taken_share] = if (total_damage_taken == 0)
        0
      else
        data[:damage_taken_total] * 100.0 / total_damage_taken
      end
      data[:cure_share] = if (total_curing == 0)
        0
      else
        data[:curing_total] * 100.0 / total_curing
      end
    end

    return pc_data
  end

  # Produce offense statistics for the PCs in the party from the provided 
  #  set of Actions.
  # If no actions are specified, then #fetch_actions will be called to attempt 
  #  to load the action set from the configured remote data store.
  # If actions are specified, the caller can optionally specify a set of PCs
  #  to override the @party_id configuration setting.
  # @param actions [Array] The set of Action objects to generate stats from.
  # @return [String] A textual report summarizing the stats.
  # @deprecated Use {#analyze_by_players} instead
  def analyze_offense(actions, player_characters=nil)
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
end

# Run this as 'main' if the library is invoked directly
if (__FILE__ == $0 && ARGV.length >= 2)
  require_relative '../lib/Parser'
  require_relative '../lib/CharacterAnalysisFormatter'
  p = Parser.new
  p.parse_file(ARGV[-2])
  puts "ActionsParsed=#{p.actions.length}"
  a = Analyzer.new
  data = a.analyze_by_players(p.actions, PartyConfig.new(ARGV[-1]))
  formatter = CharacterAnalysisFormatter.new(data)
  html = formatter.report
  puts html
end

