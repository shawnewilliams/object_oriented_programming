# Rock Paper Scissors Game
# Player Class
class Player
  attr_accessor :name, :choice, :move, :score, :history, :win_history, :human

  def initialize
    set_name
    @score = 0
    @move_history = []
    @win_history = { 'rock' => 0, 'paper' => 0, 'scissors' => 0,
                     'lizard' => 0, 'spock' => 0 }
  end

  def increment_score
    @score += 1
  end

  def reset_score
    @score = 0
  end

  def history
    @move_history
  end

  def increment_win_history(c)
    @win_history[c] += 1
  end

  def reset_history
    @move_history = []
  end

  def reset_win_history
    @win_history = { 'rock' => 0, 'paper' => 0, 'scissors' => 0,
                     'lizard' => 0, 'spock' => 0 }
  end
end

# Human Class
class Human < Player
  def set_name
    entry = ''
    loop do
      puts 'Please enter your name.'
      entry = gets.chomp
      break if entry.strip != ''
      puts "How do I know who you are if you don't tell me."
    end
    self.name = entry
  end

  def choose
    loop do
      puts 'Please choose rock (r), paper (p), or scissors (s), lizard (l), or spock (sp):'
      @choice = gets.chomp.downcase
      break if Move::VALUES.keys.include?(choice)
      puts "That's not a valid choice."
    end
    @choice = Move::VALUES[@choice]
    @move_history << @choice
    self.move = Move.new(@choice)
  end
end

# Computer Class
class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  # rubocop:disable CyclomaticComplexity
  # rubocop:disable PerceivedComplexity
  def learn(human_history, computer, count)
    if computer.win_history['rock'] / count.to_f > 0.6
      computer.choice = Move::VALUES_R.sample
    elsif computer.win_history['paper'] / count.to_f > 0.6
      computer.choice = Move::VALUES_P.sample
    elsif computer.win_history['scissors'] / count.to_f > 0.6
      computer.choice = Move::VALUES_S.sample
    elsif computer.win_history['lizard'] / count.to_f > 0.6
      computer.choice = Move::VALUES_S.sample
    elsif computer.win_history['spock'] / count.to_f > 0.6
      computer.choice = Move::VALUES_SP.sample

    elsif human_history.count('rock') / count.to_f > 0.6 && count > 4
      computer.choice = (Move::VALUES_P + Move::VALUES_SP).sample
    elsif human_history.count('paper') / count.to_f > 0.6 && count > 4
      computer.choice = (Move::VALUES_S + Move::VALUES_L).sample
    elsif human_history.count('scissors') / count.to_f > 0.6 && count > 4
      computer.choice = (Move::VALUES_R + Move::VALUES_SP).sample
    elsif human_history.count('lizard') / count.to_f > 0.6 && count > 4
      computer.choice = (Move::VALUES_S + Move::VALUES_R).sample
    elsif human_history.count('spock') / count.to_f > 0.6 && count > 4
      computer.choice = (Move::VALUES_L + Move::VALUES_P).sample
    else
      computer.choice = Move::VALUES.values.sample
    end
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength
  # rubocop:enable CyclomaticComplexity
  # rubocop:enable PerceivedComplexity

  def choose(human)
    @choice = ''
    learn(human.history, self, RPSGame.game_count)
    @move_history << @choice
    self.move = Move.new(@choice)
  end
end

# Move class
class Move
  VALUES = { 'r' => 'rock', 'p' => 'paper', 's' => 'scissors',
             'l' => 'lizard', 'sp' => 'spock' }.freeze
  VALUES_R = %w(rock rock rock rock rock
                paper scissors lizard spock).freeze
  VALUES_P = %w(rock paper paper paper paper
                paper scissors lizard spock).freeze
  VALUES_S = %w(rock paper scissors scissors scissors
                scissors scissors lizard spock).freeze
  VALUES_L = %w(rock paper scissors lizard lizard
                lizard lizard lizard spock).freeze
  VALUES_SP = %w(rock paper scissors lizard spock
                 spock spock spock spock).freeze

  attr_accessor :value, :game_count

  def initialize(value)
    @value = value
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def scissors?
    @value == 'scissors'
  end

  def lizard?
    @value == 'lizard'
  end

  def spock?
    @value == 'spock'
  end

  # rubocop:disable AbcSize
  # rubocop:disable CyclomaticComplexity
  # rubocop:disable PerceivedComplexity
  def >(other)
    (rock? && other.scissors?) ||
      (rock? && other.lizard?) ||
      (paper? && other.rock?) ||
      (paper? && other.spock?) ||
      (scissors? && other.paper?) ||
      (scissors? && other.lizard?) ||
      (lizard? && other.paper?) ||
      (lizard? && other.spock?) ||
      (spock? && other.rock?) ||
      (spock? && other.scissors?)
  end

  def <(other)
    (rock? && other.paper?) ||
      (rock? && other.spock?) ||
      (paper? && other.scissors?) ||
      (paper? && other.lizard?) ||
      (scissors? && other.rock?) ||
      (scissors? && other.spock?) ||
      (lizard? && other.rock?) ||
      (lizard? && other.scissors?) ||
      (spock? && other.paper?) ||
      (spock? && other.lizard?)
  end
  # rubocop:enable AbcSize
  # rubocop:enable CyclomaticComplexity
  # rubocop:enable PerceivedComplexity

  def to_s
    @value
  end
end

# RPSGame class
# rubocop:disable ClassLength
class RPSGame
  attr_accessor :human, :computer

  @@game_count = 0
  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def self.game_count
    @@game_count
  end

  def increment_game_count
    if @human.move < @computer.move || @human.move > @computer.move
      @@game_count += 1
    end
  end

  def self.reset_game_count
    @@game_count = 0
  end

  def display_welcome_message
    puts 'Welcome to Rock, Paper, Scissors!'
  end

  def display_moves
    puts "#{human.name} chose #{human.choice}."
    puts "#{computer.name} chose #{computer.choice}."
  end

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  # rubocop:disable CyclomaticComplexity
  # rubocop:disable PerceivedComplexity
  def display_what_beats_what
    if human.choice == 'rock' && computer.choice == 'scissors' ||
       human.choice == 'scissors' && computer.choice == 'rock'
      puts 'Rock crushes scissors!'
    elsif human.choice == 'rock' && computer.choice == 'lizard' ||
          human.choice == 'lizard' && computer.choice == 'rock'
      puts 'Rock crushes lizard!'
    elsif human.choice == 'paper' && computer.choice == 'rock' ||
          human.choice == 'rock' && computer.choice == 'paper'
      puts 'Paper covers rock!'
    elsif human.choice == 'paper' && computer.choice == 'spock' ||
          human.choice == 'spock' && computer.choice == 'paper'
      puts 'Paper disproves Spock!'
    elsif human.choice == 'scissors' && computer.choice == 'paper' ||
          human.choice == 'paper' && computer.choice == 'scissors'
      puts 'Scissors cut paper!'
    elsif human.choice == 'scissors' && computer.choice == 'lizard' ||
          human.choice == 'sizard' && computer.choice == 'scissors'
      puts 'Scissors decapitates lizard!'
    elsif human.choice == 'lizard' && computer.choice == 'spock' ||
          human.choice == 'spock' && computer.choice == 'lizard'
      puts 'Lizard poisons Spock!'
    elsif human.choice == 'lizard' && computer.choice == 'paper' ||
          human.choice == 'paper' && computer.choice == 'lizard'
      puts 'Lizard eats paper!'
    elsif human.choice == 'spock' && computer.choice == 'rock' ||
          human.choice == 'rock' && computer.choice == 'spock'
      puts 'Spock vaporizes rock!'
    elsif human.choice == 'spock' && computer.choice == 'scissors' ||
          human.choice == 'scissors' && computer.choice == 'spock'
      puts 'Spock smashes scissors!'
    end
  end

  def display_winner
    if human.move > computer.move
      display_what_beats_what
      puts "#{human.name} wins this round!"
      puts
      human.increment_score
    elsif human.move < computer.move
      display_what_beats_what
      puts "#{computer.name} wins this round."
      puts
      computer.increment_score
    else
      puts "It's a tie."
      puts
    end
  end
  # rubocop:enable MethodLength
  # rubocop:enable CyclomaticComplexity
  # rubocop:enable PerceivedComplexity

  def update_win_history
    if human.move > computer.move
      human.increment_win_history(human.choice)
    elsif human.move < computer.move
      computer.increment_win_history(computer.choice)
    end
  end

  def display_score
    puts "#{human.name}'s score is: #{human.score}"
    puts "#{computer.name}'s score is #{computer.score}"
  end

  def first_to_score?(num)
    return true if human.score == num || computer.score == num
  end

  def display_final_outcome
    if human.score > computer.score
      puts "#{human.name} WINS the game!"
    elsif computer.score > human.score
      puts "#{computer.name} WINS the game!"
    end
  end
  # rubocop:enable AbcSize

  def reset_game
    human.reset_score
    human.reset_history
    human.reset_win_history
    computer.reset_score
    computer.reset_history
    computer.reset_win_history
    RPSGame.reset_game_count
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp
      break if %w(y n).include? answer.downcase
      puts 'Sorry, must be y or n.'
    end
    return false if answer == 'n'
    return true if answer == 'y'
  end

  def display_goodbye_message
    puts 'Thanks for playing Rock, Paper, Scissors. Good bye!'
  end

  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  def play
    display_welcome_message
    loop do
      number_of_games = 0
      loop do
        computer.choose(@human)
        human.choose
        display_moves
        increment_game_count
        puts
        display_winner
        display_score
        update_win_history
        number_of_games += 1
        puts
        break if first_to_score?(10)
      end
      display_final_outcome
      reset_game
      break unless play_again?
    end
    display_goodbye_message
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength
end
# rubocop:enable ClassLength

RPSGame.new.play
