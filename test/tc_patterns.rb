require 'test/unit'
require_relative '../lib/Patterns'

class TestPatterns < Test::Unit::TestCase
    # TODO: add negative tests to ensure no false positives

    def test_melee_hit
        lines = ["Klaital hits the Goblin Alchemist for 37 points of damage.",
                    "The Rock Eater hits Demandred for 1 point of damage.",
                    "Gulool Ja Ja hits Klaital for 0 points of damage."
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.melee_hit, "Line ##{i} does not match as a melee hit: #{lines[i]}")
        end

        action1 = Patterns.melee_hit_parse(lines[0])
        assert_not_nil(action1)
        assert_equal('MELEE', action1.type)
        assert_equal('HIT', action1.subtype)
        assert_equal('COMBAT', action1.format)
        assert_equal('MELEE', action1.ability_name)
        assert_equal('Klaital', action1.actor)
        assert_equal('Goblin Alchemist', action1.target)
        assert(action1.complete?)
        assert_equal(37, action1.damage)

        action2 = Patterns.melee_hit_parse(lines[1])
        assert_not_nil(action2)
        assert_equal('MELEE', action2.type)
        assert_equal('HIT', action2.subtype)
        assert_equal('COMBAT', action2.format)
        assert_equal('MELEE', action2.ability_name)
        assert_equal('Rock Eater', action2.actor)
        assert_equal('Demandred', action2.target)
        assert(!action2.incomplete?)
        assert_equal(1, action2.damage)

        action3 = Patterns.melee_hit_parse(lines[2])
        assert_not_nil(action3)
        assert_equal('MELEE', action3.type)
        assert_equal('HIT', action3.subtype)
        assert_equal('COMBAT', action3.format)
        assert_equal('MELEE', action3.ability_name)
        assert_equal('Gulool Ja Ja', action3.actor)
        assert_equal('Klaital', action3.target)
        assert(!action3.incomplete)
        assert_equal(0, action3.damage)
    end

    def test_melee_miss
        lines = ["Klaital misses the Goblin Alchemist.",
                    "The Rock Eater misses Demandred.",
                    "Gulool Ja Ja misses Klaital."
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.melee_miss, "Line ##{i} does not match as a melee miss: #{lines[i]}")
        end

        a = Patterns.melee_miss_parse(lines[0])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert(a.complete?)
        assert_nil(a.damage)

        a = Patterns.melee_miss_parse(lines[1])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_equal('Demandred', a.target)
        assert(a.complete?)
        assert_nil(a.damage)

        a = Patterns.melee_miss_parse(lines[2])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert(a.complete?)
        assert_nil(a.damage)
    end

    def test_melee_crit
        lines = [ ["Klaital scores a critical hit!", "The Goblin Alchemist takes 97 points of damage."], 
                  ["The Rock Eater scores a critical hit!", "Demandred takes 1 point of damage."],
                  ["Gulool Ja Ja scores a critical hit!", "Klaital takes 0 points of damage."]
                ]

        lines.each_index do |i|
            assert(lines[i][0] =~ Patterns.melee_crit_1, "Line ##{i}[0] does not match as a melee crit: #{lines[i][0]}")
            assert(lines[i][1] =~ Patterns.melee_crit_2, "Line ##{i}[1] does not match as a melee crit: #{lines[i][1]}")
        end

        # Parse the first line and verify
        a = Patterns.melee_crit_1_parse(lines[0][0])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.melee_crit_2_parse(lines[0][1], a)
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_equal(97, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.melee_crit_1_parse(lines[1][0])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.melee_crit_2_parse(lines[1][1], a)
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_equal('Demandred', a.target)
        assert_equal(1, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.melee_crit_1_parse(lines[2][0])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.melee_crit_2_parse(lines[2][1], a)
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert_equal(0, a.damage)
        assert(a.complete?)
    end

    def test_ja_miss
        lines = ["Klaital uses Shield Bash, but misses the Goblin Alchemist.",
                    "The Rock Eater uses Slam, but misses Demandred.",
                    "Gulool Ja Ja uses Overthrow, but misses Klaital.",
                    "Cydori uses High Jump, but misses Aquarius."
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.attack_ja_miss, "Line ##{i} does not match as an Attack JA miss: #{lines[i]}")
        end

        a = Patterns.attack_ja_miss_parse(lines[0])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Shield Bash', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_nil(a.damage)
        assert(a.complete?)

        a = Patterns.attack_ja_miss_parse(lines[1])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Slam', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_equal('Demandred', a.target)
        assert_nil(a.damage)
        assert(a.complete?)

        a = Patterns.attack_ja_miss_parse(lines[2])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Overthrow', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert_nil(a.damage)
        assert(a.complete?)

        a = Patterns.attack_ja_miss_parse(lines[3])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('High Jump', a.ability_name)
        assert_equal('Cydori', a.actor)
        assert_equal('Aquarius', a.target)
        assert_nil(a.damage)
        assert(a.complete?)
    end

    def test_attack_ja_hit
        lines = [ ["Klaital uses Shield Bash.", "The Goblin Alchemist takes 97 points of damage."], 
                  ["The Rock Eater uses Slam.", "Demandred takes 1 point of damage."],
                  ["Gulool Ja Ja uses Overthrow.", "Klaital takes 0 points of damage."],
                  ["Cydori uses Jump.", "Aquarius takes 100 points of damage."]
                ]

        lines.each_index do |i|
            assert(lines[i][0] =~ Patterns.attack_ja_1, "Line ##{i}[0] does not match as an Attack JA hit: #{lines[i][0]}")
            assert(lines[i][1] =~ Patterns.attack_ja_2, "Line ##{i}[1] does not match as an Attack JA hit: #{lines[i][1]}")
        end

        # Parse the first line and verify
        a = Patterns.attack_ja_1_parse(lines[0][0])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Shield Bash', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.attack_ja_2_parse(lines[0][1], a)
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Shield Bash', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_equal(97, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.attack_ja_1_parse(lines[1][0])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Slam', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.attack_ja_2_parse(lines[1][1], a)
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Slam', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_equal('Demandred', a.target)
        assert_equal(1, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.attack_ja_1_parse(lines[2][0])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Overthrow', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.attack_ja_2_parse(lines[2][1], a)
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Overthrow', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert_equal(0, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.attack_ja_1_parse(lines[3][0])
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Jump', a.ability_name)
        assert_equal('Cydori', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.attack_ja_2_parse(lines[3][1], a)
        assert_not_nil(a)
        assert_equal('ATTACK_JA', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Jump', a.ability_name)
        assert_equal('Cydori', a.actor)
        assert_equal('Aquarius', a.target)
        assert_equal(100, a.damage)
        assert(a.complete?)
    end

    def test_ws_miss
        lines = ["Klaital uses Tachi: Gekko, but misses the Goblin Alchemist.",
                 "Cydori uses Drakesbane, but misses Aquarius."
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.weaponskill_miss, "Line ##{i} does not match as a Weaponskill miss: #{lines[i]}")
        end

        a = Patterns.weaponskill_miss_parse(lines[0])
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Tachi: Gekko', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_nil(a.damage)
        assert(a.complete?)

        a = Patterns.weaponskill_miss_parse(lines[1])
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Drakesbane', a.ability_name)
        assert_equal('Cydori', a.actor)
        assert_equal('Aquarius', a.target)
        assert_nil(a.damage)
        assert(a.complete?)
    end

    def test_weaponskill_hit
        lines = [ ["Klaital uses Tachi: Gekko.", "The Goblin Alchemist takes 97 points of damage."], 
                  ["Demandred uses Ukko's Fury.", "The Rock Eater takes 0 points of damage."],
                  ["Cydori uses Drakesbane.", "Aquarius takes 1 points of damage."]
                ]

        lines.each_index do |i|
            assert(lines[i][0] =~ Patterns.weaponskill_1, "Line ##{i}[0] does not match as a Weaponskill hit: #{lines[i][0]}")
            assert(lines[i][1] =~ Patterns.weaponskill_2, "Line ##{i}[1] does not match as a Weaponskill hit: #{lines[i][1]}")
        end

        # Parse the first line and verify
        a = Patterns.weaponskill_1_parse(lines[0][0])
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Tachi: Gekko', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.weaponskill_2_parse(lines[0][1], a)
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Tachi: Gekko', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_equal(97, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.weaponskill_1_parse(lines[1][0])
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Ukko\'s Fury', a.ability_name)
        assert_equal('Demandred', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.weaponskill_2_parse(lines[1][1], a)
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Ukko\'s Fury', a.ability_name)
        assert_equal('Demandred', a.actor)
        assert_equal('Rock Eater', a.target)
        assert_equal(0, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.weaponskill_1_parse(lines[2][0])
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Drakesbane', a.ability_name)
        assert_equal('Cydori', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.weaponskill_2_parse(lines[2][1], a)
        assert_not_nil(a)
        assert_equal('Weaponskill', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Drakesbane', a.ability_name)
        assert_equal('Cydori', a.actor)
        assert_equal('Aquarius', a.target)
        assert_equal(1, a.damage)
        assert(a.complete?)
    end

    def test_attack_spell_hit
        lines = [ ["Klaital casts Fire.", "The Goblin Alchemist takes 97 points of damage."], 
                  ["The Rock Eater casts Stone IV.", "Demandred takes 1 point of damage."],
                  ["Gulool Ja Ja casts Katon: Ni.", "Klaital takes 0 points of damage."],
                  ['Klaital casts Dia II.', 'The Sharabha takes 0 points of damage.']
                ]

        lines.each_index do |i|
            assert(lines[i][0] =~ Patterns.attack_spell_1, "Line ##{i}[0] does not match as an Attack Spell hit: #{lines[i][0]}")
            assert(lines[i][1] =~ Patterns.attack_spell_2, "Line ##{i}[1] does not match as an Attack Spell hit: #{lines[i][1]}")
        end

        # Parse the first line and verify
        a = Patterns.attack_spell_1_parse(lines[0][0])
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Fire', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.attack_spell_2_parse(lines[0][1], a)
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Fire', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_equal(97, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.attack_spell_1_parse(lines[1][0])
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Stone IV', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.attack_spell_2_parse(lines[1][1], a)
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Stone IV', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_equal('Demandred', a.target)
        assert_equal(1, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.attack_spell_1_parse(lines[2][0])
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Katon: Ni', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.attack_spell_2_parse(lines[2][1], a)
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('HIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Katon: Ni', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert_equal(0, a.damage)
        assert(a.complete?)
    end

    def test_ranged_miss
        lines = ["Klaital's ranged attack misses.",
                 "The Goblin Pathfinder's ranged attack misses."
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.ranged_miss, "Line ##{i} does not match as a Ranged miss: #{lines[i]}")
        end

        a = Patterns.ranged_miss_parse(lines[0])
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.complete?)

        a = Patterns.ranged_miss_parse(lines[1])
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Goblin Pathfinder', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.complete?)
    end

    def test_ranged_hit
        lines = ["Klaital's ranged attack hits the Goblin Alchemist for 37 points of damage.",
                    "The Rock Eater's ranged attack hits Demandred for 1 point of damage.",
                    "Gulool Ja Ja's ranged attack hits Klaital for 0 points of damage."
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.ranged_hit, "Line ##{i} does not match as a ranged hit: #{lines[i]}")
        end

        action1 = Patterns.ranged_hit_parse(lines[0])
        assert_not_nil(action1)
        assert_equal('RANGED', action1.type)
        assert_equal('HIT', action1.subtype)
        assert_equal('COMBAT', action1.format)
        assert_equal('RANGED', action1.ability_name)
        assert_equal('Klaital', action1.actor)
        assert_equal('Goblin Alchemist', action1.target)
        assert_equal(37, action1.damage)
        assert(action1.complete?)

        action2 = Patterns.ranged_hit_parse(lines[1])
        assert_not_nil(action2)
        assert_equal('RANGED', action2.type)
        assert_equal('HIT', action2.subtype)
        assert_equal('COMBAT', action2.format)
        assert_equal('RANGED', action2.ability_name)
        assert_equal('Rock Eater', action2.actor)
        assert_equal('Demandred', action2.target)
        assert_equal(1, action2.damage)
        assert(action2.complete?)

        action3 = Patterns.ranged_hit_parse(lines[2])
        assert_not_nil(action3)
        assert_equal('RANGED', action3.type)
        assert_equal('HIT', action3.subtype)
        assert_equal('COMBAT', action3.format)
        assert_equal('RANGED', action3.ability_name)
        assert_equal('Gulool Ja Ja', action3.actor)
        assert_equal('Klaital', action3.target)
        assert_equal(0, action3.damage)
        assert(action3.complete?)
    end

    def test_ranged_crit
        lines = [ ["Klaital's ranged attack scores a critical hit!", "The Goblin Alchemist takes 97 points of damage."], 
                  ["The Rock Eater's ranged attack scores a critical hit!", "Demandred takes 1 point of damage."],
                  ["Gulool Ja Ja's ranged attack scores a critical hit!", "Klaital takes 0 points of damage."]
                ]

        lines.each_index do |i|
            assert(lines[i][0] =~ Patterns.ranged_crit_1, "Line ##{i}[0] does not match as a ranged crit: #{lines[i][0]}")
            assert(lines[i][1] =~ Patterns.ranged_crit_2, "Line ##{i}[1] does not match as a ranged crit: #{lines[i][1]}")
        end

        # Parse the first line and verify
        a = Patterns.ranged_crit_1_parse(lines[0][0])
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.ranged_crit_2_parse(lines[0][1], a)
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_equal(97, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.ranged_crit_1_parse(lines[1][0])
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.ranged_crit_2_parse(lines[1][1], a)
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_equal('Demandred', a.target)
        assert_equal(1, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.ranged_crit_1_parse(lines[2][0])
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.ranged_crit_2_parse(lines[2][1], a)
        assert_not_nil(a)
        assert_equal('RANGED', a.type)
        assert_equal('CRIT', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('RANGED', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert_equal(0, a.damage)
        assert(a.complete?)
    end

    def test_ranged_pummel
        lines = ["Klaital's ranged attack strikes true, pummeling the Goblin Alchemist for 37 points of damage!",
                    "The Rock Eater's ranged attack strikes true, pummeling Demandred for 1 point of damage!",
                    "Gulool Ja Ja's ranged attack strikes true, pummeling Klaital for 0 points of damage!"
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.ranged_pummel, "Line ##{i} does not match as a pummeling ranged hit: #{lines[i]}")
        end

        action1 = Patterns.ranged_pummel_parse(lines[0])
        assert_not_nil(action1)
        assert_equal('RANGED', action1.type)
        assert_equal('PUMMEL', action1.subtype)
        assert_equal('COMBAT', action1.format)
        assert_equal('RANGED', action1.ability_name)
        assert_equal('Klaital', action1.actor)
        assert_equal('Goblin Alchemist', action1.target)
        assert_equal(37, action1.damage)
        assert(action1.complete?)

        action2 = Patterns.ranged_pummel_parse(lines[1])
        assert_not_nil(action2)
        assert_equal('RANGED', action2.type)
        assert_equal('PUMMEL', action2.subtype)
        assert_equal('COMBAT', action2.format)
        assert_equal('RANGED', action2.ability_name)
        assert_equal('Rock Eater', action2.actor)
        assert_equal('Demandred', action2.target)
        assert_equal(1, action2.damage)
        assert(action2.complete?)

        action3 = Patterns.ranged_pummel_parse(lines[2])
        assert_not_nil(action3)
        assert_equal('RANGED', action3.type)
        assert_equal('PUMMEL', action3.subtype)
        assert_equal('COMBAT', action3.format)
        assert_equal('RANGED', action3.ability_name)
        assert_equal('Gulool Ja Ja', action3.actor)
        assert_equal('Klaital', action3.target)
        assert_equal(0, action3.damage)
        assert(action3.complete?)
    end

    def test_ranged_square
        lines = ["Klaital's ranged attack hits the Goblin Alchemist squarely for 37 points of damage!",
                    "The Rock Eater's ranged attack hits Demandred squarely for 1 point of damage!",
                    "Gulool Ja Ja's ranged attack hits Klaital squarely for 0 points of damage!"
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.ranged_square, "Line ##{i} does not match as a square ranged hit: #{lines[i]}")
        end

        action1 = Patterns.ranged_square_parse(lines[0])
        assert_not_nil(action1)
        assert_equal('RANGED', action1.type)
        assert_equal('SQUARE', action1.subtype)
        assert_equal('COMBAT', action1.format)
        assert_equal('RANGED', action1.ability_name)
        assert_equal('Klaital', action1.actor)
        assert_equal('Goblin Alchemist', action1.target)
        assert_equal(37, action1.damage)
        assert(action1.complete?)

        action2 = Patterns.ranged_square_parse(lines[1])
        assert_not_nil(action2)
        assert_equal('RANGED', action2.type)
        assert_equal('SQUARE', action2.subtype)
        assert_equal('COMBAT', action2.format)
        assert_equal('RANGED', action2.ability_name)
        assert_equal('Rock Eater', action2.actor)
        assert_equal('Demandred', action2.target)
        assert_equal(1, action2.damage)
        assert(action2.complete?)

        action3 = Patterns.ranged_square_parse(lines[2])
        assert_not_nil(action3)
        assert_equal('RANGED', action3.type)
        assert_equal('SQUARE', action3.subtype)
        assert_equal('COMBAT', action3.format)
        assert_equal('RANGED', action3.ability_name)
        assert_equal('Gulool Ja Ja', action3.actor)
        assert_equal('Klaital', action3.target)
        assert_equal(0, action3.damage)
        assert(action3.complete?)
    end

    def test_spell_curing
        lines = [   ["Wrex casts Cure III.", "Neresh recovers 251 HP."],
                    ["The Goblin Alchemist casts Cure.", "The Goblin Alchemist recovers 0 HP."]

                ]

        # Negative tests
        negative_lines = [
                            ["Klaital casts Cure V.", "The Skleton takes 100 points of damage."] 
                        ]

        lines.each_index do |i|
            assert(lines[i][0] =~ Patterns.spell_cure_1, "Line ##{i}[0] does not match as a spell cure: #{lines[i][0]}")
            assert(lines[i][1] =~ Patterns.spell_cure_2, "Line ##{i}[1] does not match as a spell cure: #{lines[i][1]}")
        end
        
        assert(negative_lines[0][0] =~ Patterns.spell_cure_1, "Line #0[0] should not match as a spell cure, but does: #{negative_lines[0][0]}")
        assert(negative_lines[0][1] !~ Patterns.spell_cure_2, "Line #0[1] should not match as a spell cure, but does: #{negative_lines[0][1]}")
        

        # Parse the first line and verify
        a = Patterns.spell_cure_1_parse(lines[0][0])
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Cure III', a.ability_name)
        assert_equal('Wrex', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.spell_cure_2_parse(lines[0][1], a)
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Cure III', a.ability_name)
        assert_equal('Wrex', a.actor)
        assert_equal('Neresh', a.target)
        assert_equal(251, a.damage)
        assert(a.complete?)

        # Parse the first line and verify
        a = Patterns.spell_cure_1_parse(lines[1][0])
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Cure', a.ability_name)
        assert_equal('Goblin Alchemist', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.spell_cure_2_parse(lines[1][1], a)
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Cure', a.ability_name)
        assert_equal('Goblin Alchemist', a.actor)
        assert_equal('Goblin Alchemist', a.target)
        assert_equal(0, a.damage)
        assert(a.complete?)

        # Negative tests

        # Parse the first line and verify
        a = Patterns.spell_cure_1_parse(negative_lines[0][0])
        assert_not_nil(a)
        assert_equal('SPELL', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Cure V', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.spell_cure_2_parse(negative_lines[0][1], a)
        assert_nil(a)
    end

    def test_ja_curing
        lines = [   
                    ["Demandred uses Curing Waltz II.", "Klaital recovers 121 HP."]
                ]

        # Negative tests
        negative_lines = [
                            ["Klaital uses Curing Waltz.", "The Skleton takes 100 points of damage."] 
                        ]

        lines.each_index do |i|
            assert(lines[i][0] =~ Patterns.ja_cure_1, "Line ##{i}[0] does not match as a JA cure: #{lines[i][0]}")
            assert(lines[i][1] =~ Patterns.ja_cure_2, "Line ##{i}[1] does not match as a JA cure: #{lines[i][1]}")
        end
        
        assert(negative_lines[0][0] =~ Patterns.ja_cure_1, "Line #0[0] should not match as a JA cure, but does: #{negative_lines[0][0]}")
        assert(negative_lines[0][1] !~ Patterns.ja_cure_2, "Line #0[1] should not match as a JA cure, but does: #{negative_lines[0][1]}")
        

        # Parse the first line and verify
        a = Patterns.ja_cure_1_parse(lines[0][0])
        assert_not_nil(a)
        assert_equal('JA', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Curing Waltz II', a.ability_name)
        assert_equal('Demandred', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.ja_cure_2_parse(lines[0][1], a)
        assert_not_nil(a)
        assert_equal('JA', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Curing Waltz II', a.ability_name)
        assert_equal('Demandred', a.actor)
        assert_equal('Klaital', a.target)
        assert_equal(121, a.damage)
        assert(a.complete?)

        # Negative tests

        # Parse the first line and verify
        a = Patterns.ja_cure_1_parse(negative_lines[0][0])
        assert_not_nil(a)
        assert_equal('JA', a.type)
        assert_equal('CURE', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('Curing Waltz', a.ability_name)
        assert_equal('Klaital', a.actor)
        assert_nil(a.target)
        assert_nil(a.damage)
        assert(a.incomplete?)
        # Parse the second line and verify
        a = Patterns.ja_cure_2_parse(negative_lines[0][1], a)
        assert_nil(a)
    end

    def test_kill_defeat
        lines = [
                    'Klaital defeats the Goblin Tinkerer.',
                    'The Rock Worm defeats Klaital',
                    'Gulool Ja Ja defeats Klaital'
                ]
        lines.each_index do |i|
            assert(lines[i] =~ Patterns.kill_defeats, "Line ##{i} does not match as a Kill/defeat pattern: #{lines[i]}")
        end

        a = Patterns.kill_defeats_parse(lines[0])
        assert_not_nil(a)
        assert_equal('KILL', a.format)
        assert_equal('Klaital', a.actor)
        assert_equal('Goblin Tinkerer', a.target)
        assert(a.complete?, "Action not marked complete.")
       
        a = Patterns.kill_defeats_parse(lines[1])
        assert_not_nil(a)
        assert_equal('KILL', a.format)
        assert_equal('Rock Worm', a.actor)
        assert_equal('Klaital', a.target)
        assert(a.complete?, "Action not marked complete.")

        a = Patterns.kill_defeats_parse(lines[2])
        assert_not_nil(a)
        assert_equal('KILL', a.format)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert(a.complete?, "Action not marked complete.")
    end

    def test_kill_fall
        lines = [
                    'The Goblin Tinkerer falls to the ground.',
                    'Klaital falls to the ground.'
                ]
        lines.each_index do |i|
            assert(lines[i] =~ Patterns.kill_falls, "Line ##{i} does not match as a Kill/defeat pattern: #{lines[i]}")
        end

        a = Patterns.kill_falls_parse(lines[0])
        assert_not_nil(a)
        assert_equal('KILL', a.format)
        assert_equal('DoT', a.actor)
        assert_equal('Goblin Tinkerer', a.target)
        assert(a.complete?, "Action not marked complete.")
       
        a = Patterns.kill_falls_parse(lines[1])
        assert_not_nil(a)
        assert_equal('KILL', a.format)
        assert_equal('DoT', a.actor)
        assert_equal('Klaital', a.target)
        assert(a.complete?, "Action not marked complete.")
    end

    def test_lights
        lines = [
                    'Klaital\'s body emits a faint pearlescent light!',
                    'Klaital\'s body emits a strong ruby light!',
                    'Demandred\'s body emits a faint azure light!'
                ]
        lines.each_index do |i|
            assert(lines[i] =~ Patterns.light, "Line #{i} does not match as a Light pattern: #{lines[i]}")
        end

        a = Patterns.light_parse(lines[0])
        assert_not_nil(a)
        assert_equal('LIGHT', a.format)
        assert_equal('pearlescent', a.light)
        assert(a.complete?, "Action not marked complete.")

        a = Patterns.light_parse(lines[1])
        assert_not_nil(a)
        assert_equal('LIGHT', a.format)
        assert_equal('ruby', a.light)
        assert(a.complete?, "Action not marked complete.")

        a = Patterns.light_parse(lines[2])
        assert_not_nil(a)
        assert_equal('LIGHT', a.format)
        assert_equal('azure', a.light)
        assert(a.complete?, "Action not marked complete.")
    end

end
