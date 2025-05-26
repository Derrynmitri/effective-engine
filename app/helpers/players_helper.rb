module PlayersHelper
  def player_ranking_classes(player, base_classes: "mr-2")
    ranking_class = case player.ranking
    when 1 then "text-yellow-500"
    when 2 then "text-slate-400"
    when 3 then "text-amber-700"
    else "text-gray-700 dark:text-gray-300"
    end

    "#{base_classes} #{ranking_class}"
  end
end
