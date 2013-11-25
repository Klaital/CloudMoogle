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
        assert_equal(37, action1.damage)

        action2 = Patterns.melee_hit_parse(lines[1])
        assert_not_nil(action2)
        assert_equal('MELEE', action2.type)
        assert_equal('HIT', action2.subtype)
        assert_equal('COMBAT', action2.format)
        assert_equal('MELEE', action2.ability_name)
        assert_equal('Rock Eater', action2.actor)
        assert_equal('Demandred', action2.target)
        assert_equal(1, action2.damage)

        action3 = Patterns.melee_hit_parse(lines[2])
        assert_not_nil(action3)
        assert_equal('MELEE', action3.type)
        assert_equal('HIT', action3.subtype)
        assert_equal('COMBAT', action3.format)
        assert_equal('MELEE', action3.ability_name)
        assert_equal('Gulool Ja Ja', action3.actor)
        assert_equal('Klaital', action3.target)
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
        assert_nil(a.damage)

        a = Patterns.melee_miss_parse(lines[1])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Rock Eater', a.actor)
        assert_equal('Demandred', a.target)
        assert_nil(a.damage)

        a = Patterns.melee_miss_parse(lines[2])
        assert_not_nil(a)
        assert_equal('MELEE', a.type)
        assert_equal('MISS', a.subtype)
        assert_equal('COMBAT', a.format)
        assert_equal('MELEE', a.ability_name)
        assert_equal('Gulool Ja Ja', a.actor)
        assert_equal('Klaital', a.target)
        assert_nil(a.damage)
    end    
end
