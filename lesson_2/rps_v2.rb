# Rock Paper Scissors Game
# Player class
class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def increment_score
    @score += 1
  end

  def reset_score
    @score = 0
  end
end

# Human class
class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts 'Sorry, must enter a value.'
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts 'Please choose rock, paper, or scissors:'
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts 'Sorry, invalid choice.'
    end
    self.move = Move.new(choice)
  end
end

# Computer class
class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

# Move class
class Move
  VALUES = %w(rock paper scissors).freeze

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

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

# RPSGame class
class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts 'Welcome to Rock, Paper, Scissors!'
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} wins this round!"
      human.increment_score
    elsif human.move < computer.move
      puts "#{computer.name} wins this round."
      computer.increment_score
    else
      puts "It's a tie."
    end
  end

  def display_score
    puts "#{human.name}'s score is: #{human.score}"
    puts "#{computer.name}'s score is #{computer.score}"
  end

  def number_of_games
    return true if human.score == 5 || computer.score == 5
  end

  def display_final_outcome
    if human.score > computer.score
      puts "#{human.name} WINS the game!"
    elsif computer.score > human.score
      puts "#{computer.name} WINS the game!"
    end
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

  def play
    display_welcome_message
    loop do
      loop do
        human.choose
        computer.choose
        display_moves
        display_winner
        display_score
        break if number_of_games
      end
      display_final_outcome
      human.reset_score
      computer.reset_score
      break unless play_again?
    end
    display_goodbye_message
  end
end

game = RPSGame.new
game.play
