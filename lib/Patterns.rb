require "../src/Weaponskills.rb"

class Patterns
    def Patterns.first_line_patterns
        [ 'ja_cure_1', 'spell_cure_1',
            'weaponskill_miss', 'attack_ja_miss',
            'ranged_pummel', 'ranged_square', 'ranged_hit', 'ranged_crit_1', 'ranged_miss', 
            'melee_hit', 'melee_miss', 'melee_crit_1', 
            'weaponskill_1',  'attack_ja_1', 
            'attack_spell_1',  
            'kill_defeats', 'kill_falls', 
            'light' ]
    end
    def Patterns.second_line_patterns
        [ 'ja_cure_2', 'spell_cure_2',
        'ranged_crit_2', 
        'melee_crit_2', 
        'weaponskill_2', 'attack_ja_2', 
        'attack_spell_2' ]
    end    
    
    def Patterns.melee_hit
        /^#{Patterns.character_name} hits #{Patterns.mob_name} for [\d]+ point(s)? of damage/i
    end
    def Patterns.melee_hit_parse(s)
        tokens = s.split(/ /)
        iHit = tokens.index("hits")
        ret = Hash.new
        ret['pattern_name'] = "melee_hit"
        ret['action'] = "MELEE HIT"
        ret['format'] = "COMBAT"
        ret['ability name'] = 'MELEE'
        ret['actor'] = Patterns.clean_name(tokens[iHit-1])
        ret['damage'] = tokens[-4].to_i
        ret['target'] = Patterns.clean_name(tokens[iHit+1...-5].join(" "))
        
        return ret
    end
    
    # matches lines like: "Nimbex misses the Sharabha."
    def Patterns.melee_miss
        /#{Patterns.character_name} misses #{Patterns.mob_name}/i
    end
    def Patterns.melee_miss_parse(s)
        tokens = s.split(/ /)
        ret = Hash.new
        ret['pattern_name'] = "melee_miss"
        ret['action'] = "MELEE MISS"
        ret['format'] = "COMBAT"
        ret['ability name'] = 'MELEE'
        iMiss = tokens.index("misses")
        ret['actor'] = Patterns.clean_name(tokens[iMiss-1])
        ret['target'] = Patterns.clean_name(tokens[iMiss+1..-1].join(" "))
        ret['damage'] = 0
        
        return ret
    end
    
    
    def Patterns.melee_crit_1
        /#{Patterns.character_name} scores a critical hit!/i
    end
    def Patterns.melee_crit_1_parse(s)
        ret = Hash.new
        ret['pattern_name'] = "melee_crit"
        ret['action'] = "MELEE CRIT"
        ret['format'] = "COMBAT"
        ret['ability name'] = 'MELEE'
        tokens = s.split(/ /)
        ret['actor'] = Patterns.clean_name(tokens[tokens.index("scores")-1])
        return ret
    end
    
    
    def Patterns.melee_crit_2
        /#{Patterns.mob_name} takes [\d]+ point(s)? of damage/i
    end
    def Patterns.melee_crit_2_parse(s, old_action)
        return nil if(old_action.nil?)
        tokens = s.split(/ /)
        iTakes = tokens.rindex("takes")
        ret = old_action
        ret['target'] = Patterns.clean_name(tokens[0...iTakes].join(" "))
        ret['damage'] = tokens[iTakes+1].to_i
        
        return ret
    end
    
    def Patterns.attack_ja_miss
        ja_pattern = Patterns.attack_jas.join("|")
        /^#{Patterns.character_name} uses (#{ja_pattern}), but misses #{Patterns.mob_name}\.$/
    end
    def Patterns.attack_ja_miss_parse(s)
        ret = Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = "ATTACK_JA MISS"
        ret['pattern_name'] = "attack_ja_miss"
        
        iActorEnd = (s =~ / uses .+, but misses /)
        ret['actor'] = Patterns.clean_name(s[0...iActorEnd])
        iComma = (s =~ /, but misses /)
        ret['ability name'] = s[iActorEnd+6...iComma]
        ret['target'] = Patterns.clean_name(s[iComma+13..-2])
        ret['damage'] = 0
        
        return ret
    end
    
    
    def Patterns.attack_ja_1
        /#{Patterns.character_name} uses /
    end
    def Patterns.attack_ja_1_parse(s)
        ret = Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = "ATTACK_JA HIT"
        ret['pattern_name'] = "attack_ja"
        tokens = s.split(/ /)
        iUses = tokens.rindex("uses")
        ret['ability name'] = tokens[iUses+1..-1].join(" ")[0...-1]
        ret['actor'] = Patterns.clean_name(tokens[0...iUses].join(" "))
        
        return ret
    end
    
    
    def Patterns.attack_ja_2
        return Patterns.melee_crit_2
    end
    def Patterns.attack_ja_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end
    
    def Patterns.weaponskill_miss
        ws_modifier = Patterns.weaponskills.join("|")
        /^#{Patterns.character_name} uses (#{ws_modifier}), but misses #{Patterns.mob_name}\.$/
    end
    def Patterns.weaponskill_miss_parse(s)
        ret = Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = "WS MISS"
        ret['pattern_name'] = "weaponskill_miss"
        
        iActorEnd = (s =~ / uses .+, but misses /)
        ret['actor'] = Patterns.clean_name(s[0...iActorEnd])
        iComma = (s =~ /, but misses /)
        ret['ability name'] = s[iActorEnd+6...iComma]
        ret['target'] = Patterns.clean_name(s[iComma+13..-2])
        ret['damage'] = 0
        
        return ret
    end
    
    def Patterns.weaponskill_1(ws_list=[])
        if(ws_list.length > 0)
            ws_modifier = ws_list.join("|")
        else
            ws_modifier = Patterns.weaponskills.join("|")
        end
        return /#{Patterns.character_name} uses (#{ws_modifier})/i
    end
    def Patterns.weaponskill_1_parse(s)
        ret = Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = "WS HIT"
        ret['pattern_name'] = "weaponskill"
        tokens = s.split(/ /)
        iUses = tokens.index("uses")
        ret['ability name'] = tokens[iUses+1..-1].join(" ")[0...-1]
        ret['actor'] = Patterns.clean_name(tokens[0...iUses].join(" "))
        
        return ret
    end
    
    def Patterns.weaponskill_2
        return Patterns.melee_crit_2
    end
    def Patterns.weaponskill_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end
    
    def Patterns.attack_spell_1
        /#{Patterns.character_name} casts /i
    end
    def Patterns.attack_spell_1_parse(s)
        ret = Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = "SPELL"
        ret['pattern_name'] = "attack_spell"
        tokens = s.split(/ /)
        iCasts = tokens.index("casts")
        ret['ability name'] = tokens[iCasts+1..-1].join(" ")[0...-1]
        ret['actor'] = Patterns.clean_name(tokens[0...iCasts].join(" "))
        return ret
    end
    
    def Patterns.attack_spell_2
        Patterns.melee_crit_2
    end
    def Patterns.attack_spell_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end

    def Patterns.ranged_hit
        /#{Patterns.character_name}'s ranged attack hits #{Patterns.mob_name} for [\d]+ points of damage/
    end
    def Patterns.ranged_hit_parse(s)
        ret= Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = "RANGED HIT"
        ret['pattern_name'] = 'ranged_hit'
        ret['ability name'] = 'RANGED'
        tokens = s.split(/ /)
        iRanged = tokens.index("ranged")
        iHits = tokens.index("hits")
        iFor = tokens.rindex("for")
        ret['actor'] = Patterns.clean_name(tokens[0...iRanged].join(" "))
        ret['target'] = Patterns.clean_name(tokens[iHits+1..iFor-1].join(" "))
        ret['damage'] = tokens[iFor+1].to_i
        
        return ret
    end
    
    def Patterns.ranged_crit_1
        /^#{Patterns.character_name}'s ranged attack scores a critical hit!$/
    end
    def Patterns.ranged_crit_1_parse(s)
        ret = Hash.new
        ret['format'] = 'COMBAT'
        ret['action'] = 'RANGED CRIT'
        ret['pattern_name'] = 'ranged_crit'
        ret['ability name'] = 'RANGED'
        tokens = s.split(/ /)
        iRanged = tokens.index("ranged")
        ret['actor'] = Patterns.clean_name(tokens[0..iRanged-1].join(" "))
        return ret
    end
    
    def Patterns.ranged_crit_2
        return Patterns.melee_crit_2
    end
    def Patterns.ranged_crit_2_parse(s, old_action)
        return Patterns.melee_crit_2_parse(s, old_action)
    end
    
    def Patterns.ranged_miss
        /^#{Patterns.character_name}'s ranged attack misses\.$/
    end
    def Patterns.ranged_miss_parse(s)
        ret = Hash.new
        ret['format'] = 'COMBAT'
        ret['action'] = 'RANGED MISS'
        ret['ability name'] = 'RANGED'
        ret['pattern_name'] = 'ranged_miss'
        tokens = s.split(/ /)
        iRanged = tokens.index('ranged')
        ret['actor'] = Patterns.clean_name(tokens[0..iRanged-1].join(" "))
        ret['target'] = '-'
        ret['damage'] = 0
        
        return ret
    end
    
    def Patterns.ranged_pummel
        /^#{Patterns.character_name}'s ranged attack strikes true, pummeling #{Patterns.mob_name} for [\d]+ point(s)? of damage!$/
    end
    def Patterns.ranged_pummel_parse(s)
        ret = Hash.new
        ret['format'] = 'COMBAT'
        ret['action'] = 'RANGED PUMMEL'
        ret['pattern_name'] = 'ranged_pummel'
        ret['ability name'] = 'RANGED'
        tokens = s.split(/ /)
        iRanged = tokens.index('ranged')
        iPummel = tokens.index('pummeling')
        iFor = tokens.rindex('for')
        ret['actor'] = Patterns.clean_name(tokens[0..iRanged-1].join(" "))
        ret['target'] = Patterns.clean_name(tokens[iPummel+1..iFor-1].join(" "))
        ret['damage'] = tokens[-4].to_i
        
        return ret
    end
    
    def Patterns.ranged_square
        /^#{Patterns.character_name}'s ranged attack hits #{Patterns.mob_name} squarely for [\d]+ point(s)? of damage!$/
    end
    def Patterns.ranged_square_parse(s)
        ret = Hash.new
        ret['format'] = 'COMBAT'
        ret['action'] = 'RANGED SQUARE'
        ret['pattern_name'] = 'ranged_pummel'
        ret['ability name'] = 'RANGED'
        tokens = s.split(/ /)
        iRanged = tokens.index('ranged')
        iHits = tokens.index('hits')
        iSquare= tokens.rindex('squarely')
        ret['actor'] = Patterns.clean_name(tokens[0..iRanged-1].join(" "))
        ret['target'] = Patterns.clean_name(tokens[iHits+1..iSquare-1].join(" "))
        ret['damage'] = tokens[-4].to_i
        
        return ret
    end
    
    def Patterns.spell_cure_1
        /^#{Patterns.character_name} casts Cur(e|aga)( (II|III|IV|V|VI))?\.$/
    end
    def Patterns.spell_cure_1_parse(s)
        ret = Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = 'CURE SPELL'
        ret['pattern_name'] = 'spell_cure'
        tokens = s.split(/ /)
        iCasts = tokens.rindex("casts")
        ret['ability name'] = tokens[iCasts+1..-1].join(" ")[0...-1]
        ret['actor'] = Patterns.clean_name(tokens[0...iCasts].join(" "))
        return ret
    end
    
    def Patterns.spell_cure_2
        # "Klaital recovers 1099 HP."
        /^#{Patterns.character_name} recovers [\d]+ HP\.$/
    end
    def Patterns.spell_cure_2_parse(s, old_action)
        tokens = s.split(/ /)
        
        old_action['target'] = Patterns.clean_name(tokens[0..-4].join(" "))
        old_action['damage'] = tokens[-2].to_i
        return old_action
    end
    
    def Patterns.ja_cure_1
        /^#{Patterns.character_name} uses (Curing|Divine) Waltz( (II|III|IV|V|VI))?\.$/
    end
    def Patterns.ja_cure_1_parse(s)
        ret = Hash.new
        ret['format'] = "COMBAT"
        ret['action'] = 'CURE JA'
        ret['pattern_name'] = 'ja_cure'
        tokens = s.split(/ /)
        iUses = tokens.rindex("uses")
        ret['ability name'] = tokens[iUses+1..-1].join(" ")[0...-1]
        ret['actor'] = Patterns.clean_name(tokens[0...iUses].join(" "))
        return ret
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
        /#{Patterns.character_name} defeats #{Patterns.mob_name}/
    end
    def Patterns.kill_defeats_parse(s)
        ret = Hash.new
        ret['format'] = "KILL"
        ret['pattern_name'] = "kill_defeats"
        tokens = s.split(/ /)
        iDefeats = tokens.index("defeats")
        ret['actor'] = Patterns.clean_name(tokens[0...iDefeats].join(" "))
        ret['target'] = Patterns.clean_name(tokens[iDefeats+1..-1].join(" "))
        return ret
    end
    
    def Patterns.kill_falls
        /#{Patterns.mob_name} falls to the ground/
    end
    def Patterns.kill_falls_parse(s)
        ret = Hash.new
        ret['format'] = "KILL"
        ret['pattern_name'] = "kill_falls"
        ret['actor'] = "DoT"
        tokens = s.split(/ /)
        iFalls = tokens.rindex("falls")
        ret['target'] = Patterns.clean_name(tokens[0...iFalls].join(" "))
        return ret
    end
    
    #
    # LIGHT format patterns
    #
    def Patterns.light
        /body emits a (feeble|faint) (pearlescent|ruby|amber|azure|ebon|golden|silvery) light!/
    end
    def Patterns.light_parse(s)
        tokens = s.split(/ /)
        ret = Hash.new
        ret['format'] = "LIGHT"
        ret['pattern_name'] = "light"
        ret['color'] = tokens[tokens.index("light!")-1]
        return ret
    end

    #
    # Utility patterns
    #

    def Patterns.character_name
        "[A-Za-z]{3,18}"
    end
    def Patterns.mob_name
        "([tT]he )?[A-Za-z \\-'\\.]+"
    end

    #
    # utility parser methods
    #
    
    def Patterns.clean_name(name)
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
    
end
