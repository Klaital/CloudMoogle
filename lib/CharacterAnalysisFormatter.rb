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
      <tr><th>Damage Dealt</th><td>#{data[:damage_dealt_total]}</td><td>(#{data[:damage_dealt_share})%</td></tr>
      <tr><th>Damage Taken</th><td>#{data[:damage_taken_total]}</td><td>(#{data[:damage_taken_share})%</td></tr>
      <tr><th>Curing</th><td>#{data[:curing_total]}</td><td>(#{data[:cure_share})%</td></tr>
    </table>
    <h3>Rates</h3>
    <table>
      <tr><th>Dmg Type</th><th>Accuracy</th><th>Crit%</th></tr>
      <tr><th>Melee</th><td>#{data[:hitrates]['MELEE']}%</td><td></td></tr>
      <tr><th>Melee</th><td>#{data[:hitrates]['WEAPONSKILL']}%</td><td></td></tr>
      <tr><th>Melee</th><td>#{data[:hitrates]['RANGED']}%</td><td></td></tr>
    </table>
  </div>
HTML
    end
  end
  html += "\n</body>\n</html>\n"
  
  return html
end
