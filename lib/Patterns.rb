require_relative '../lib/Action'
require_relative '../lib/Weaponskills'

class Patterns
    def Patterns.first_line_patterns
        [ 'ja_cure_1', 'spell_cure_1',
            'weaponskill_miss', 'attack_ja_miss',
            'ranged_pummel', 'ranged_square', 'ranged_hit', 'ranged_crit_1', 'ranged_miss', 
            'melee_hit', 'melee_miss', 'melee_crit_1', 
            'weaponskill_hit_1',  'attack_ja_hit_1', 
            'spell_hit_1',  
            'kill_defeats', 'kill_falls', 
            'light' ]
    end
    def Patterns.second_line_patterns
        [ 'ja_cure_2', 'spell_cure_2',
        'ranged_crit_2', 
        'melee_crit_2', 
        'weaponskill_hit_2', 'attack_ja_hit_2', 
        'spell_hit_2' ]
    end    
    
    def Patterns.melee_hit
        /^(#{Patterns.mob_name}) hits (#{Patterns.mob_name}) for (\d+) points? of damage/i
    end
    def Patterns.melee_hit_parse(s)
        matches = s.match(Patterns.melee_hit)
        return nil if (matches.nil?)
        ret = Action.new
        ret.type = 'MELEE'
        ret.subtype = 'HIT'
        ret.format = 'COMBAT'
        ret.ability_name = 'MELEE'
        ret.actor = Patterns.clean_name(matches[1])
        ret.target = Patterns.clean_name(matches[3])
        ret.damage = matches[5] # The setter method will perform the integer conversion
        ret.incomplete = false
        
        return ret
    end
    
    # matches lines like: "Nimbex misses the Sharabha."
    def Patterns.melee_miss
        /(#{Patterns.mob_name}) misses (#{Patterns.mob_name})/i
    end
    def Patterns.melee_miss_parse(s)
        matches = s.match(Patterns.melee_miss)
        return nil if (matches.nil?)
        a = Action.new
        a.type = 'MELEE'
        a.subtype = 'MISS'
        a.format = 'COMBAT'
        a.ability_name = 'MELEE'
        a.actor = Patterns.clean_name(matches[1])
        a.target = Patterns.clean_name(matches[3])
        a.damage = nil 
        a.incomplete = false
        
        return a
    end
    
    
    def Patterns.melee_crit_1
        /(#{Patterns.mob_name}) scores a critical hit!$/i
    end
    def Patterns.melee_crit_1_parse(s)
        matches = s.match(Patterns.melee_crit_1)
        return nil if (matches.nil?)
        a = Action.new
        a.type = 'MELEE'
        a.subtype = 'CRIT'
        a.format = 'COMBAT'
        a.ability_name = 'MELEE'
        a.actor = Patterns.clean_name(matches[1])
        return a
    end
    
    
    def Patterns.melee_crit_2
        /(#{Patterns.mob_name}) takes (\d+) points? of damage/i
    end
    # Add the data from the second line of the action to the data parsed from the first line.
    # @param s [String] The second line of the action
    # @param old_action [Action] The Action object containing the data parsed from the first line of the action.
    def Patterns.melee_crit_2_parse(s, old_action)
        return nil if(old_action.nil?)
        matches = s.match(Patterns.melee_crit_2)
        return nil if (matches.nil?)
        
        old_action.target = Patterns.clean_name(matches[1])
        old_action.damage = matches[3] # Setter method will handle integer conversion
        old_action.incomplete = false
        return old_action
    end
    
    def Patterns.attack_ja_miss
        # ja_pattern = Patterns.attack_jas.join("|")
        /^(#{Patterns.mob_name}) uses (.+), but misses (#{Patterns.mob_name})\.$/
    end
    def Patterns.attack_ja_miss_parse(s)
        matches = s.match(Patterns.attack_ja_miss)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'ATTACK_JA'
        a.subtype = 'MISS'
        a.actor = Patterns.clean_name(matches[1])
        a.ability_name = matches[3]
        a.target = Patterns.clean_name(matches[4])
        a.damage = nil
        a.incomplete = false
        
        return a
    end
    
    
    def Patterns.attack_ja_hit_1
        /^(#{Patterns.mob_name}) uses (.+)/
    end
    def Patterns.attack_ja_hit_1_parse(s)
        matches = s.match(Patterns.attack_ja_hit_1)
        return nil if (matches.nil?)
        a = Action.new
        a.type = 'ATTACK_JA'
        a.subtype = 'HIT'
        a.format = 'COMBAT'
        a.ability_name = Patterns.clean_ability_name(matches[3])
        a.actor = Patterns.clean_name(matches[1])
        
        return a
    end
    
    
    def Patterns.attack_ja_hit_2
        return Patterns.melee_crit_2
    end
    # Add the data from the second line of the action to the data parsed from the first line.
    # @param s [String] The second line of the action
    # @param old_action [Action] The Action object containing the data parsed from the first line of the action.
    def Patterns.attack_ja_hit_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end
    
    def Patterns.weaponskill_miss
        ws_modifier = Patterns.weaponskills.join("|")
        /^(#{Patterns.mob_name}) uses (#{ws_modifier}), but misses (#{Patterns.mob_name})\.$/
    end
    def Patterns.weaponskill_miss_parse(s)
        matches = s.match(Patterns.weaponskill_miss)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'Weaponskill'
        a.subtype = 'MISS'
        a.actor = Patterns.clean_name(matches[1])
        a.ability_name = Patterns.clean_ability_name(matches[3])
        a.target = Patterns.clean_name(matches[4])
        a.damage = nil
        a.incomplete = false

        return a
    end
    
    def Patterns.weaponskill_hit_1(ws_list=[])
        if(ws_list.length > 0)
            ws_modifier = ws_list.join("|")
        else
            ws_modifier = Patterns.weaponskills.join("|")
        end
        return /^(#{Patterns.mob_name}) uses (#{ws_modifier})/i
    end
    def Patterns.weaponskill_hit_1_parse(s)
        matches = s.match(Patterns.weaponskill_hit_1)
        return nil if (matches.nil?)

        a = Action.new
        a.format = 'COMBAT'
        a.type = 'Weaponskill'
        a.subtype = 'HIT'
        a.ability_name = Patterns.clean_ability_name(matches[3])
        a.actor = Patterns.clean_name(matches[1])
        return a
    end
    
    def Patterns.weaponskill_hit_2
        return Patterns.melee_crit_2
    end
    # Add the data from the second line of the action to the data parsed from the first line.
    # @param s [String] The second line of the action
    # @param old_action [Action] The Action object containing the data parsed from the first line of the action.
    def Patterns.weaponskill_hit_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end
    
    def Patterns.spell_hit_1
        /^(#{Patterns.mob_name}) casts (.+)/i
    end
    def Patterns.spell_hit_1_parse(s)
        matches = s.match(Patterns.spell_hit_1)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'SPELL'
        a.subtype = 'HIT'
        a.ability_name = Patterns.clean_ability_name(matches[3])
        a.actor = Patterns.clean_name(matches[1])
        return a
    end
    
    def Patterns.spell_hit_2
        Patterns.melee_crit_2
    end
    # Add the data from the second line of the action to the data parsed from the first line.
    # @param s [String] The second line of the action
    # @param old_action [Action] The Action object containing the data parsed from the first line of the action.
    def Patterns.spell_hit_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end

    def Patterns.ranged_hit
        /^(#{Patterns.mob_name})'s ranged attack hits (#{Patterns.mob_name}) for (\d+) points? of damage/
    end
    def Patterns.ranged_hit_parse(s)
        matches = s.match(Patterns.ranged_hit)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'RANGED'
        a.subtype = 'HIT'
        a.ability_name = 'RANGED'
        a.actor = Patterns.clean_name(matches[1])
        a.target = Patterns.clean_name(matches[3])
        a.damage = matches[5] # the setter method will handle the Integer conversion
        a.incomplete = false
        
        return a
    end
    
    def Patterns.ranged_crit_1
        /^(#{Patterns.mob_name})'s ranged attack scores a critical hit!$/
    end
    def Patterns.ranged_crit_1_parse(s)
        matches = s.match(Patterns.ranged_crit_1)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'RANGED'
        a.subtype = 'CRIT'
        a.ability_name = 'RANGED'
        a.actor = Patterns.clean_name(matches[1])
        return a
    end
    
    def Patterns.ranged_crit_2
        return Patterns.melee_crit_2
    end
    # Add the data from the second line of the action to the data parsed from the first line.
    # @param s [String] The second line of the action
    # @param old_action [Action] The Action object containing the data parsed from the first line of the action.
    def Patterns.ranged_crit_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end
    
    def Patterns.ranged_miss
        /^(#{Patterns.mob_name})'s ranged attack misses\.$/
    end
    def Patterns.ranged_miss_parse(s)
        matches = s.match(Patterns.ranged_miss)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'RANGED'
        a.subtype = 'MISS'
        a.ability_name = 'RANGED'
        a.actor = Patterns.clean_name(matches[1])
        a.target = nil
        a.damage = nil
        a.incomplete = false

        return a
    end
    
    def Patterns.ranged_pummel
        /^(#{Patterns.mob_name})'s ranged attack strikes true, pummeling (#{Patterns.mob_name}) for (\d+) points? of damage!$/
    end
    def Patterns.ranged_pummel_parse(s)
        matches = s.match(Patterns.ranged_pummel)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'RANGED'
        a.subtype = 'PUMMEL'
        a.ability_name = 'RANGED'
        a.actor = Patterns.clean_name(matches[1])
        a.target = Patterns.clean_name(matches[3])
        a.damage = matches[5] # The setter method will ensure Integer conversion
        a.incomplete = false

        return a
    end
    
    def Patterns.ranged_square
        /^(#{Patterns.mob_name})'s ranged attack hits (#{Patterns.mob_name}) squarely for (\d+) points? of damage!$/
    end
    def Patterns.ranged_square_parse(s)
        matches = s.match(Patterns.ranged_square)
        return nil if (matches.nil?)
        a = Action.new
        a.format = 'COMBAT'
        a.type = 'RANGED'
        a.subtype = 'SQUARE'
        a.ability_name = 'RANGED'
        a.actor = Patterns.clean_name(matches[1])
        a.target = Patterns.clean_name(matches[3])
        a.damage = matches[5] # The setter method will ensure Integer conversion
        a.incomplete = false

        return a
    end
    
    def Patterns.spell_cure_1
        /^(#{Patterns.mob_name}) casts (Cur(e|aga)( (II|III|IV|V|VI))?)\.$/
    end
    def Patterns.spell_cure_1_parse(s)
        matches = s.match(Patterns.spell_cure_1)
        return nil if(matches.nil?)

        a = Action.new
        a.format = 'COMBAT'
        a.type = 'SPELL'
        a.subtype = 'CURE'
        a.ability_name = Patterns.clean_ability_name(matches[3])
        a.actor = Patterns.clean_name(matches[1])
        return a
    end
    
    # Matches the second line of a recovery spell/ability:
    # "Klaital recovers 1099 HP."
    def Patterns.spell_cure_2
        /^(#{Patterns.mob_name}) recovers (\d+) HP\.$/
    end
    def Patterns.spell_cure_2_parse(s, old_action)
        matches = s.match(Patterns.spell_cure_2)
        return nil if (matches.nil?)
        
        old_action.target = Patterns.clean_name(matches[1])
        old_action.damage = matches[3] # The setter method will ensure Integer conversion
        old_action.incomplete = false
        return old_action
    end
    
    def Patterns.ja_cure_1
        /^(#{Patterns.mob_name}) uses ((Curing|Divine) Waltz.*)\.$/
    end
    def Patterns.ja_cure_1_parse(s)
        matches = s.match(Patterns.ja_cure_1)
        return nil if(matches.nil?)

        a = Action.new
        a.format = 'COMBAT'
        a.type = 'JA'
        a.subtype = 'CURE'
        a.ability_name = Patterns.clean_ability_name(matches[3])
        a.actor = Patterns.clean_name(matches[1])
        return a
    end
    
    def Patterns.ja_cure_2
        return Patterns.spell_cure_2
    end
    def Patterns.ja_cure_2_parse(s, old_action)
        return Patterns.spell_cure_2_parse(s, old_action)
    end
    
    #
    # KILL Format patterns 
    #
    def Patterns.kill_defeats
        /^(#{Patterns.mob_name}) defeats (#{Patterns.mob_name})/
    end
    def Patterns.kill_defeats_parse(s)
        matches = s.match(Patterns.kill_defeats)
        return nil if(matches.nil?)

        a = Action.new
        a.format = 'KILL'
        a.actor = Patterns.clean_name(matches[1])
        a.target = Patterns.clean_name(matches[3])
        a.incomplete = false
        return a
    end
    
    def Patterns.kill_falls
        /(#{Patterns.mob_name}) falls to the ground/
    end
    def Patterns.kill_falls_parse(s)
        matches = s.match(Patterns.kill_falls)
        return nil if(matches.nil?)

        a = Action.new
        a.format = 'KILL'
        a.actor = 'DoT'
        a.target = Patterns.clean_name(matches[1])
        a.incomplete = false
        return a
    end
    
    #
    # LIGHT format patterns
    #
    def Patterns.light
        /body emits a .+ (pearlescent|ruby|amber|azure|ebon|golden|silvery) light!/
    end
    def Patterns.light_parse(s)
        matches = s.match(Patterns.light)
        return nil if(matches.nil?)
        
        a = Action.new
        a.format = 'LIGHT'
        a.light = matches[1]
        a.incomplete = false
        return a
    end

    #
    # Utility patterns
    #

    #
    # Matches all valid names for player characters: 1 capital letter followed by at least two and up to 17 lowercase letters.
    def Patterns.character_name
        "[A-Z][a-z]{2,17}"
    end

    # Matches all valid NPC names. They may optionally be prefixed with 'The'
    def Patterns.mob_name
        "([tT]he )?[A-Za-z \\-'\\.]+"
    end

    #
    # utility parser methods
    #
    
    #
    # Clean up a name for CloudMoogle's use. Useable on both mob and PC names.
    #   Strip the leading 'The ' if present.
    #   Remove any trailing period.
    #   Remove any trailing possessive ("'s")
    #
    # @param name [String] The name to be cleaned up.
    # @return [String] The name cleaned up, ready for CloudMoogle's usage.
    def Patterns.clean_name(name)
        return nil if (name.nil?)
        s = name.strip
        if(name =~ /^[Tt]he /)
            s = name[4..-1]
        end
        
        if(s =~ /\.$/)
            s = s[0..-2]
        end
        
        if(s =~ /'s$/)
            s = s[0..-3]
        end
        
        return s
    end

    def Patterns.clean_ability_name(name)
        return nil if (name.nil?)
        # Strip leading/trailing whitespace
        s = name.strip
        # Strip trailing period.
        s = s[0..-2] if (s=~ /\.$/)

        return s    
    end
    
end
