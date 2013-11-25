require 'test/unit'
require_relative '../lib/Patterns'

class Patterns < Test::Unit::TestCase
    def test_melee_hit
        lines = ["Klaital hits the Goblin Alchemist for 37 points of damage.",
                    "The Rock Eater hits Demandred for 1 point of damage.",
                    "Gulool Ja Ja hits Klaital for 0 points of damage."
                ]

        lines.each_index do |i|
            assert(lines[i] =~ Patterns.melee_hit, "Line ##{i} does not match as a melee hit: #{lines[i]}")
        end

        action1 = Patterns.melee_hit_parse(lines[0])
        assert_equal('MELEE', action1.type)
        assert_equal('HIT', action1.subtype)
        assert_equal('COMBAT', action1.format)
        assert_equal('MELEE', action1.ability_name)
        assert_equal('Klaital', action1.actor)
        assert_equal('Goblin Alchemist', action1.target)
        assert_equal(37, action1.damage)
    end    
end
