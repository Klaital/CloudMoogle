# add knowledge of Weaponskill names to the Patterns class

class Patterns
  def Patterns.weaponskills(load_path = "../resources/weaponskills.txt")
    if(File.exists?(load_path))
      f = File.open(load_path, "r")
      ret = f.readlines.collect {|x| x.strip}
      f.close
      return ret
    end
    return []
  end

  def Patterns.attack_jas
    [ 'Weapon Bash', 'Blade Bash', 'Shield Bash', 'Violent Flourish', 
      '(Fire|Ice|Wind|Earth|Thunder|Water) Shot',
      '(High |Super |Spirit |Soul )?Jump', 
      'Chi Blast', 'Mijin Gakure', 'Eagle Eye Shot', 'Barrage' 
    ]
  end
end
