module PlayersHelper

  def player_name_link(player, user, quiet: true, vertical: false)
    player_name = player_name_by_consent(player, user, vertical: vertical)

    if player.dummy?
      player_name
    else
      link_to(player_name, player_path(player), class: quiet ? "quiet-link" : "")
    end
  end


  def player_name_by_consent(player, user = nil, vertical: false)
    if player.consent_given? || player.dummy?
      if vertical
        return player.name.gsub(/\s+/, "<br>").html_safe
      else
        return player.name
      end

    end

    anonymized_last_name = if user.blank?
                             player.last_name.split('').map.with_index do |letter, index|
                               (index % 3 == 0) ? letter : '*'
                             end.join
                           else
                             player.last_name.split('').tap { |a| a[-1] = '*' }.join
                           end

    if vertical
      content_tag :span do
        [player.first_name, anonymized_last_name].join("<br>")
      end.html_safe
    else
      [player.first_name, anonymized_last_name].join(' ')
    end
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


  def match_badge(match = nil, player = nil)
    if match.nil? || player.nil? || !match.been_played?
      content_tag :span, '-', class: "badge badge-secondary"

    elsif match.winner == player
      link_to match_path(match) do
        content_tag :span, 'W', class: "badge badge-success"
      end

    elsif match.looser == player
      link_to match_path(match) do
        content_tag :span, 'L', class: "badge badge-danger"
      end
    end
  end
end
