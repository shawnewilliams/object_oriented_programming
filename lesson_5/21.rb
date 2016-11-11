# TwentyOneDisplayable Module
module TwentyOneDisplayable
  def display_welcome_message
    puts 'Welcome to 21!'
  end

  def clear
    system 'clear'
  end

  def display_dealing_message
    message = "Dealing"
    4.times do
      clear
      puts message
      message += '.'
      sleep(0.3)
    end
  end

  def display_deal
    sleep(0.2)
    puts
    @computer.display_showing
    sleep(0.5)
    puts
    human.display_hand
    puts
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def display_winner
    clear
    puts '--- Result ---'
    sleep(1)
    puts
    display_cards_and_totals
    if @human.busted?
      puts "*** #{@human.name} Busted. #{@computer.name} WINS! ***"
    elsif @computer.busted?
      puts "*** #{@computer.name} Busted. #{@human.name} WINS! ***"
    elsif @computer.total > @human.total
      puts "*** #{@computer.name} WINS! ***"
    elsif @human.total > @computer.total
      puts "*** #{@human.name} WINS! ***"
    elsif @human.total == @computer.total
      puts "*** Its a TIE. ***"
    end
    puts
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def display_cards_and_totals
    @computer.display_hand
    puts
    @human.display_hand
    puts
  end

  def display_goodbye_message
    puts 'Thanks for playing 21! Goodbye!'
    puts
  end
end

# Player Class
class Player
  MAX = 21
  MIN = 17
  include TwentyOneDisplayable

  attr_accessor :name, :hand, :total, :stay, :bet, :money
  def initialize
    @hand = []
    @stay = false
    @bet = 0
    @money = 100
  end

  def set_name
    name = nil
    loop do
      puts 'What is your name?'
      name = gets.chomp
      break unless name.strip.empty?
      puts "How do I know who you are if you don't tell me?"
    end
    @name = name
  end

  def hit(card)
    @hand << card.card
  end

  def stay?
    @stay
  end

  def busted?
    total > MAX
  end

  def total
    @total = 0
    hand_array = @hand.flatten
    @hand.each do |card|
      if Deck::CARDS.keys.include?(card[0])
        @total += Deck::CARDS[card[0]]
      end
      if @total > MAX && hand_array.include?("Ace")
        @total -= 10
        hand_array.delete_at(hand_array.index("Ace"))
      end
      @total
    end
    @total
  end

  def display_hand
    puts "--- #{@name}'s hand ---"
    @hand.each { |num, suit| puts "=> #{num} of #{suit}" }
    puts "=> Total: #{total}"
  end

  def place_bet
    bet = 0
    loop do
      puts "You have $#{@money}. How much would you like to bet?"
      bet = gets.chomp
      break if bet.to_i.to_s == bet && bet.to_i <= @money && bet.to_i > 0
      puts "That's not a valid amount"
    end
    @bet = bet.to_i
  end

  # rubocop:disable Metrics/MethodLength
  def hit_or_stay?(deck)
    choice = nil
    loop do
      puts "Would you like to hit (h) or stay (s)?"
      choice = gets.chomp.downcase
      clear
      break if ['h', 's'].include?(choice)
      puts "That's not a valid choice."
    end
    if choice == 'h'
      puts "#{@name} hits!"
      puts
      hit(Card.new(deck))
      display_hand
      puts
    elsif choice == 's'
      @stay = true
    end
  end
  # rubocop:enable Metrics/MethodLength

  def add_bet
    @money += case @total
              when MAX
                @bet * 2
              else
                @bet
              end
  end

  def subtract_bet
    @money -= @bet
  end

  def reset
    @hand = []
    @stay = false
  end
end

# Computer Class
class Computer < Player
  def initialize
    @hand = []
    @name = "Dealer"
  end

  def total_showing
    @total_showing = Deck::CARDS[hand.first[0]]
  end

  def display_showing
    puts "--- #{@name}'s hand ---"
    puts "=> #{hand.first[0]} of #{hand.first[1]}"
    puts "=> ???"
    puts "=> Total: #{total_showing}"
  end

  def stay?
    total >= MIN
  end
end

# Deck Class
class Deck
  CARDS = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, +
            "7" => 7, "8" => 8, "9" => 9, "10" => 10, "Jack" => 10, +
            "Queen" => 10, "King" => 10, "Ace" => 11 }.freeze

  H = "Hearts".freeze
  D = "Diamonds".freeze
  S = "Spades".freeze
  C = "Clubs".freeze

  attr_accessor :cards

  def initialize
    @cards = shuffle
  end

  def shuffle
    deck_keys = CARDS.keys
    deck = []
    deck_keys.each do |card|
      deck.push([card, H])
      deck.push([card, D])
      deck.push([card, S])
      deck.push([card, C])
    end
    deck
  end

  def empty?
    if @cards.empty?
      puts "Time to shuffle!"
      @cards = shuffle
    end
  end

  def deal(player)
    empty?
    player.hand.push(@cards.sample)
    @cards.delete(player.hand[-1])
  end
end

# Card Class
class Card
  attr_accessor :card

  def initialize(deck)
    deck.empty?
    @card = deck.cards.delete_at(deck.cards.find_index(deck.cards.sample))
  end
end

# Game Class
class TwentyOneGame
  attr_accessor :human, :computer, :deck
  include TwentyOneDisplayable

  def initialize
    @human = Player.new
    @computer = Computer.new
    @deck = Deck.new
  end

  def play
    clear
    display_welcome_message
    @human.set_name
    game_loop
    display_goodbye_message
    # show_result
  end

  def deal_cards
    2.times do
      deck.deal(@human)
      deck.deal(@computer)
    end
  end

  def game_loop
    loop do
      @human.place_bet
      display_dealing_message
      deal_cards
      display_deal
      player_turn
      computer_turn
      display_winner
      settle_bet
      reset
      break if broke?
      break unless play_again?
      clear
    end
  end

  def player_turn
    loop do
      @human.hit_or_stay?(@deck)
      if @human.busted?
        puts "#{@human.name} busted!"
        puts
        break
      elsif @human.stay?
        puts "#{@human.name} stays!"
        puts
        break
      end
    end
    sleep(1)
  end

  # rubocop:disable Metrics/MethodLength
  def computer_turn
    loop do
      break if @human.busted?
      if @computer.busted?
        puts "#{@computer.name} busted!"
        sleep(1)
        break
      elsif @computer.stay?
        puts "#{@computer.name} stays!"
        sleep(1)
        break
      else
        @computer.hit(Card.new(@deck))
        puts "#{@computer.name} hits!"
        sleep(1)
      end
      puts
    end
  end
  # rubocop:enable Metrics/MethodLength

  def settle_bet
    if @human.busted? || @human.total < @computer.total && !@computer.busted?
      @human.subtract_bet
    elsif @computer.busted? || @human.total > @computer.total
      @human.add_bet
    end
    puts "You have $#{@human.money}."
  end

  def reset
    @human.reset
    @computer.reset
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

  def broke?
    if @human.money == 0
      puts "Sorry, I have all your money. Better luck next time."
      puts
      return true
    end
    false
  end
end

TwentyOneGame.new.play
