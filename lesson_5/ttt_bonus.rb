# Joinable Module
module Joinable
  def joinor(array, delimiter = ', ', word = 'or')
    array[-1] = "#{word} #{array.last}" if array.size > 1
    array.size == 2 ? array.join(' ') : array.join(delimiter)
  end
end

# Board Class
class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts '     |     |'
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts '     |     |'
    puts '-----+-----+-----'
    puts '     |     |'
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts '     |     |'
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return squares.first.marker if three_identical_markers?(squares)
    end
    nil
  end

  # rubocop:disable Metrics/MethodLength
  def at_risk_marker_and_square
    # Returns a hash with the at risk marker and square
    at_risk_marker = {}
    WINNING_LINES.each do |line|
      square = @squares.values_at(*line)
      next unless at_risk(square)
      key = square.select(&:marked?).collect(&:marker).uniq.join
      value = nil
      line.each do |sq|
        value = sq if @squares[sq].unmarked?
      end
      at_risk_marker[key] = value
    end
    at_risk_marker
  end
  # rubocop:enable Metrics/MethodLength

  def at_risk_squares
    WINNING_LINES.each do |line|
      square = @squares.values_at(*line)
      next unless at_risk(square)
      line.each do |sq|
        return sq if @squares[sq].unmarked?
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  private

  def at_risk(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 2
    markers.min == markers.max
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

# Square Class
class Square
  INITIAL_MARKER = ' '.freeze

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

# Player Class
class Player
  attr_reader :score
  attr_accessor :marker, :name

  def initialize(marker)
    @marker = marker
    @score = 0
  end

  def add_score
    @score += 1
  end

  def reset_score
    @score = 0
  end
end

# TTTGame Class
# rubocop:disable Metrics/ClassLength
class TTTGame
  AVAILABLE_MARKERS = %w(X O).freeze
  X_MARKER = 'X'.freeze
  O_MARKER = 'O'.freeze
  FIRST_TO_MOVE = X_MARKER
  PLAY_TO = 5

  attr_reader :board, :human, :computer
  attr_accessor :turn, :human_marker, :computer_marker, :current_marker

  include Joinable

  def initialize
    @board = Board.new
    @human = Player.new(X_MARKER)
    @computer = Player.new(O_MARKER)
    @current_marker = FIRST_TO_MOVE
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def play
    clear
    display_welcome_message
    set_names

    loop do # Play again loop
      choose_marker
      clear
      loop do # To 5 loop
        display_board
        loop do
          current_player_moves
          break if board.someone_won? || board.full?
          clear_screen_and_display_board if human_turn?
        end
        increment_score
        display_round_winner
        display_score
        break if num_of_wins?
        pause_for_input
        reset_round
      end # End to 5 loop
      display_game_winner
      break unless play_again?
      reset_game
      display_play_again_message
    end # End play again loop
    display_goodbye_message
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  private

  def display_welcome_message
    puts 'Weclome to Tic Tac Toe!'
    puts ''
  end

  def display_goodbye_message
    puts 'Thanks for playing Tic Tac Toe! Goodbye!'
  end

  def set_names
    loop do
      puts 'What is you name?'
      human.name = gets.chomp
      break if human.name != ' '
      puts "How will I know who you are if you don't enter your name?"
    end
    computer.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  # rubocop:disable Metrics/MethodLength
  def choose_marker
    loop do
      puts 'Would you like to be X or O? X goes first.'
      human.marker = gets.chomp.upcase
      break if AVAILABLE_MARKERS.include?(human.marker)
      puts "Than's not a valid choice. Pleas put X or O."
    end
    case human.marker
    when 'X'
      computer.marker = 'O'
    else
      computer.marker = 'X'
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/LineLength
  def display_board
    puts "#{human.name}: #{human.marker} -- #{computer.name}: #{computer.marker}"
    puts
    board.draw
    puts
  end
  # rubocop:enable Metrics/LineLength

  def clear_screen_and_display_board
    clear
    display_board
  end

  # rubocop:disable Metrics/AbcSize
  def human_moves
    puts "Choose a square #{joinor(board.unmarked_keys)}: "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    # Offence
    if board.at_risk_marker_and_square.include?(computer.marker)
      board[board.at_risk_marker_and_square[computer.marker]] = computer.marker
    # Defence
    elsif board.at_risk_marker_and_square.include?(human.marker)
      board[board.at_risk_marker_and_square[human.marker]] = computer.marker
    # Choose center
    elsif board.unmarked_keys.include?(5)
      board[5] = computer.marker
    else
      board[board.unmarked_keys.sample] = computer.marker
    end
  end
  # rubocop:enable Metrics/AbcSize

  def round_winner
    board.winning_marker
  end

  def display_round_winner
    clear_screen_and_display_board
    case round_winner
    when human.marker
      puts "#{human.name} won this round!"
    when computer.marker
      puts "#{computer.name} won this round!"
    else
      puts "It's a tie!"
    end
  end

  # rubocop:disable Metrics/AbcSize
  def display_game_winner
    if human.score == PLAY_TO
      puts
      puts "#{human.name} won the game!"
      puts
    elsif computer.score == PLAY_TO
      puts
      puts "#{computer.name} won the game!"
      puts
    end
  end
  # rubocop:enable Metrics/AbcSize

  def increment_score
    case board.winning_marker
    when human.marker
      human.add_score
    when computer.marker
      computer.add_score
    end
  end

  def display_score
    puts "#{human.name}'s score is: #{human.score}"
    puts "#{computer.name}'s score is: #{computer.score}"
  end

  def change_current_marker
    if @current_marker == human.marker
      @current_marker = computer.marker
    elsif @current_marker == computer.marker
      @current_marker = human.marker
    end
  end

  def winner_goes_first
    if round_winner == human.marker
      @current_marker = human.marker
    elsif round_winner == computer.marker
      @current_marker = computer.marker
    else
      change_current_marker
    end
  end

  def num_of_wins?
    computer.score == PLAY_TO || human.score == PLAY_TO
  end

  def pause_for_input
    puts
    puts "Hit 'return' key to continue."
    gets.chomp
  end

  def play_again?
    answer = nil
    loop do
      puts 'Would you like to play again? (y/n)'
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts 'Sorry, must be y or n'
    end
    answer == 'y'
  end

  def clear
    system 'clear'
  end

  def reset_round
    winner_goes_first
    board.reset
    clear
  end

  def reset_game
    board.reset
    @current_marker = FIRST_TO_MOVE
    reset_score
    clear
  end

  def reset_score
    human.reset_score
    computer.reset_score
  end

  def display_play_again_message
    puts "Let's play again!"
    puts
  end

  def current_player_moves
    if @current_marker == human.marker
      human_moves
      @current_marker = computer.marker

    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
  end
end
# rubocop:enable Metrics/ClassLength

# Start the game

game = TTTGame.new
game.play
