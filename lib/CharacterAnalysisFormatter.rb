require 'time'

class CharacterAnalysisFormatter
  attr_accessor :stats
  def initialize(character_stats)
    @stats = character_stats
  end
  
  def report
    html = <<HTML
<html>
<head>
  <title>CloudMoogle Character Analysis</title>
</head>
<body>
  <h1>CloudMoogle Character Analysis</h1>
  <p>Generated at: #{Time.now.iso8601}</p>
HTML

    @stats.each_pair do |pc, data|
      pc_html = <<HTML
  <div id="#{pc}">
    <h2>#{pc}</h2>
    <h3>Totals</h3>
    <table>
      <tr><th>Damage Dealt</th><td>#{data[:damage_dealt_total].round(1)}</td><td>(#{data[:damage_dealt_share].round(1)})%</td></tr>
      <tr><th>Damage Taken</th><td>#{data[:damage_taken_total].round(1)}</td><td>(#{data[:damage_taken_share].round(1)})%</td></tr>
      <tr><th>Curing</th><td>#{data[:curing_total].round(1)}</td><td>(#{data[:cure_share].round(1)})%</td></tr>
    </table>
    <h3>Rates</h3>
    <table>
      <tr><th>Dmg Type</th><th>Accuracy</th><th>Crit%</th></tr>
      <tr><th>Melee</th><td>#{data[:hitrates]['MELEE'].round(1)}%</td><td></td></tr>
      <tr><th>Melee</th><td>#{data[:hitrates]['WEAPONSKILL'].round(1)}%</td><td></td></tr>
      <tr><th>Melee</th><td>#{data[:hitrates]['RANGED'].round(1)}%</td><td></td></tr>
    </table>
  </div>
HTML
      
      html += pc_html
    end
    html += "\n</body>\n</html>\n"
  
    return html
  end
end
