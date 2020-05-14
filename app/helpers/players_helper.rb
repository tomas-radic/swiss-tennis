module PlayersHelper
  def player_name_link(player, user, quiet = true)
    player_name = player_name_by_consent(player, user)

    if player.dummy?
      player_name
    else
      link_to(player_name, player_path(player), class: quiet ? "quiet-link" : "")
    end
  end

  def player_name_by_consent(player, user = nil)
    return player.name if player.consent_given? || player.dummy?

    anonymized_last_name = if user.blank?
                             player.last_name.split('').map.with_index do |letter, index|
                               (index % 3 == 0) ? letter : '*'
                             end.join
                           else
                             player.last_name.split('').tap { |a| a[-1] = '*' }.join
                           end

    [player.first_name, anonymized_last_name].join(' ')
  end

  def success_of_play_color_class(percentage)
    if percentage.nil?
      'border-dark'
    elsif percentage > 65
      'border-danger'
    elsif percentage > 50
      'border-warning'
    else
      'border-dark'
    end
  end
end
