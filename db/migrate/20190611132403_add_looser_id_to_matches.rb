class AddLooserIdToMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :looser_id, :uuid, foreign_key: true
  end

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
