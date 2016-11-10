# TwentyOneDisplayable Module
module TwentyOneDisplayable
  def display_welcome_message
    puts 'Welcome to 21!'
  end

  def display_dealing_message
    clear
    puts "Dealing"
    sleep(0.3)
    clear
    puts "Dealing."
    sleep(0.3)
    clear
    puts "Dealing.."
    sleep(0.3)
    clear
    puts "Dealing..."
  end

  def display_goodbye_message
    puts 'Thanks for playing 21! Goodbye!'
  end

  def display_winner
    clear
    puts '--- Result ---'
    sleep(1)
    puts
    display_cards_and_totals
    case won?
    when :human_busted
      puts "*** #{@human.name} Busted. #{@computer.name} WINS! ***"
    when :computer_busted
      puts "*** #{@computer.name} Busted. #{@human.name} WINS! ***"
    when :computer
      puts "*** #{@computer.name} WINS! ***"
    when :human
      puts "*** #{@human.name} WINS! ***"
    when :tie
      puts "*** Its a TIE. ***"
    end
    puts
  end

  def display_cards_and_totals
    @computer.display_hand
    puts
    @human.display_hand
    puts
  end
end

# Player Class
class Player
  MAX = 21
  MIN = 17

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
    @total_showing = hand.first[0]
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

  def deck_empty?
    if @cards.empty?
      puts "Time to shuffle!"
      @cards = shuffle
    end
  end

  def deal(player)
    deck_empty?
    player.hand.push(@cards.sample)
    @cards.delete(player.hand[-1])
  end
end

# Card Class
class Card
  attr_accessor :card

  def initialize(deck)
    deck.deck_empty?
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
    loop do
      @human.place_bet
      display_dealing_message
      deal_cards
      display_deal
      player_turn_loop
      computer_turn
      display_winner
      settle_bet
      reset
      break if broke?
      break unless play_again?
      system 'clear'
    end
    display_goodbye_message
    # show_result
  end

  def clear
    system 'clear'
  end

  def deal_cards
    2.times do
      deck.deal(@human)
      deck.deal(@computer)
    end
  end

  def display_deal
    sleep(0.5)
    puts
    @computer.display_showing
    sleep(0.5)
    puts
    human.display_hand
    puts
  end

  def player_turn
    choice = nil
    loop do
      puts "Would you like to hit (h) or stay (s)?"
      choice = gets.chomp.downcase
      clear
      break if ['h', 's'].include?(choice)
      puts "That's not a valid choice."
    end
    if choice == 'h'
      puts "#{@human.name} hits!"
      puts
      @human.hit(Card.new(@deck))
      @human.display_hand
      puts
    elsif choice == 's'
      @human.stay = true
    end
  end

  def player_turn_loop
    loop do
      player_turn
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

  def computer_turn
    loop do
      if @human.busted?
        break
      elsif @computer.busted?
        break
      elsif @computer.stay?
        break
      else
        @computer.hit(Card.new(@deck))
      end
    end
  end

  def won?
    if @human.busted?
      :human_busted
    elsif @computer.busted? &&
          !@human.busted?
      :computer_busted
    elsif @human.total > @computer.total
      :human
    elsif @computer.total > @human.total
      :computer
    else
      :tie
    end
  end

  def settle_bet
    result = won?
    if result == :human_busted || result == :computer
      @human.subtract_bet
    elsif result == :computer_busted || result == :human
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
      return true
    end
    false
  end
end

TwentyOneGame.new.play
