require_relative "game"

$/ = "\n"

def prompt_game
  print "\nWould you like to play a new game, or load a previous one? \
  ('N' or 'P')\n\n"
  response = gets.chomp

  prompt_game unless %w[N P].include?(response)

  if response == "N"
    Game.new
  else
    previous_game_menu
  end
end

def previous_game_menu
  # Source - https://stackoverflow.com/a/2652196
  # Posted by glenn jackman, modified by community. See post 'Timeline'
  # for change history
  # Retrieved 2026-04-25, License - CC BY-SA 3.0
  count = `wc -l saved/saved_games.json`.split.first.to_i

  if count.zero?
    print "\nThere is no record of any saved games.\n"
    prompt_game
  else
    choose_previous_game
  end
end

def choose_previous_game
  print "\nYou have #{count} saved games. Please select the number " \
        "of the game you would like to play ('1' would be the oldest).\n\n"
  response = gets.chomp.to_i

  if (1..count).include? response
    game = Game.new
    game.unserialize(load_game_no(response))
    return game
  end

  choose_previous_game
end

def load_game_no(game_number)
  # Source - https://stackoverflow.com/a/4015415
  # Posted by steenslag, modified by community. See post 'Timeline'
  # for change history
  # Retrieved 2026-04-25, License - CC BY-SA 3.0
  File.open("saved/saved_games.json", "r") do |f|
    (game_number - 1).times { f.gets }
    f.gets
  end
end

def save_game(current_game)
  update_saved_games(current_game.token) unless current_game.token.nil?
  count = `wc -l saved/saved_games.json`.split.first.to_i

  current_game.token = count + 1
  File.open("saved/saved_games.json", "a") do |saved_games|
    saved_games << current_game.serialize
    saved_games.print("\n")
  end
end

def update_saved_games(token)
  # Source - https://stackoverflow.com/a/37515663
  # Posted by floum, modified by community. See post 'Timeline' for change history
  # Retrieved 2026-04-25, License - CC BY-SA 3.0
  lines = File.readlines("saved/saved_games.json")
  filtered_lines = lines.select.with_index { |_, i| i + 1 != token }

  File.open("saved/saved_games.json", "w") do |f|
    filtered_lines.each do |line|
      f.write line
    end
  end
end

game = prompt_game
ret = game.play_game

if ret.zero?
  save_game(game)
elsif !game.token.nil?
  update_saved_games(game.token)
end
