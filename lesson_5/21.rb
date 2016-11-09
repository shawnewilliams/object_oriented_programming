require 'pry'

module Joinable
  def joinor(array, word)
    new_array = []
    array.each do |element|
      new_array << element.join(" #{word} ")
    end
    new_array
  end
end

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
    if @total == MAX
      @money += @bet * 2
    else
      @money += @bet
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

class Computer < Player
  def initialize
    @hand = []
    @name = "Dealer"
  end

  def total_showing
    @total_showing = 0
    @hand.each do |card|
      if Deck::CARDS.keys.include?(card[0])
        @total_showing += Deck::CARDS[card[0]]
      end
    end
    @total_showing -= Deck::CARDS[@hand[-1][0]]
    if @total_showing > MAX && @hand[0...-1].flatten.include?("Ace")
      @total_showing -= 10
    end
    @total_showing
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

class Card
  attr_accessor :card

  def initialize(deck)
    deck.deck_empty?
    @card = deck.cards.delete_at(deck.cards.find_index(deck.cards.sample))
  end
end

class Game
  attr_accessor :human, :computer, :deck
  include Joinable

  def initialize
    @human = Player.new
    @computer = Computer.new
    @deck = Deck.new
  end

  def play
    clear
    display_welcome_message
    choose_name
    loop do
      @human.place_bet
      display_dealing_message
      deal_cards
      player_turn_loop
      computer_turn
      display_winner
      settle_bet
      @human.reset
      @computer.reset
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

  def choose_name
    name = nil
    loop do
      puts 'What is your name?'
      name = gets.chomp
      break unless name.strip.empty?
      puts "How do I know who you are if you don't tell me?"
    end
    human.name = name
  end

  def display_welcome_message
    puts 'Welcome to 21!'
  end

  def display_goodbye_message
    puts 'Thanks for playing 21! Goodbye!'
  end

  def deal_cards
    deck.deal(@human)
    deck.deal(@human)
    deck.deal(@computer)
    deck.deal(@computer)
    sleep(1)
    puts
    computer_display_showing
    computer_display_total_showing
    sleep(1)
    puts
    display_cards(@human)
    display_total(@human)
    puts
  end

  def display_dealing_message
    puts "Dealing..."
  end

  def display_cards(player)
    puts "#{player.name}'s cards: - " \
         "#{joinor(player.hand, 'of').join(' - ')}"
  end

  def display_total(player)
    puts "#{player.name}'s total: #{player.total}"
  end

  def computer_display_showing
    puts "#{@computer.name} cards showing: - " \
         "#{joinor(@computer.hand, 'of')[0...-1].join(' - ')}"
  end

  def computer_display_total_showing
    puts "#{@computer.name} total showing: #{@computer.total_showing}"
  end

  def player_turn
    choice = nil
    loop do
      puts "Would you like to hit (h) or stay (s)?"
      choice = gets.chomp.downcase
      break if ['h', 's'].include?(choice)
      puts "That's not a valid choice."
    end
    if choice == 'h'
      puts "#{@human.name} hits!"
      puts
      @human.hit(Card.new(@deck))
      display_cards(@human)
      display_total(@human)
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
  end

  def computer_turn
    loop do
      sleep(1)
      if @human.busted?
        break
      elsif @computer.busted?
        break
      elsif @computer.stay?
        puts "#{@computer.name} stays!"
        puts
        break
      else
        puts "#{@computer.name} hits!"
        puts
        @computer.hit(Card.new(@deck))
        computer_display_showing
        computer_display_total_showing
        puts
      end
    end
  end

  def pause_for_input
    puts "Press enter to continue"
    gets.chomp
  end

  def won?
    if @human.busted? &&
       !@computer.busted?
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

  def display_winner
    puts 'Result------------------'
    puts
    sleep(1)
    result = won?
    case result
    when :human_busted
      puts "#{@human.name} Busted. #{@computer.name} WINS!"
    when :computer_busted
      puts "#{@computer.name} Busted. #{@human.name} WINS!"
    when :computer
      puts "#{@computer.name} WINS!"
    when :human
      puts "#{@human.name} WINS!"
    when :tie
      puts "Its a TIE."
    end
    sleep(1)
    display_cards_and_totals
  end

  def display_cards_and_totals
    puts
    display_cards(@computer)
    display_total(@computer)
    puts
    display_cards(@human)
    display_total(@human)
    puts
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

Game.new.play
