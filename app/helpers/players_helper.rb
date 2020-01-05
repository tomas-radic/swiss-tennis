module PlayersHelper
  def player_name_by_consent(player, user = nil)
    return player.name if player.consent_given?

    anonymized_last_name = if user.blank?
                             player.last_name.split('').map.with_index do |letter, index|
                               (index % 4 == 0) ? letter : '*'
                             end.join
                           else
                             player.last_name.split('').tap { |a| a[-1] = '*' }.join
                           end

    [player.first_name, anonymized_last_name].join(' ')
  end
end
