class SetMatchLoosers < ActiveRecord::Migration[5.2]
  def change
    Match.all.each do |match|
      if match.winner
        looser = if match.winner == match.player1
          match.player2
        elsif match.winner == match.player2
          match.player1
        end

        match.looser = looser
        match.save!
      end
    end
  end
end
