class Card
  attr_reader :rank, :suit
  include Comparable

  VALUES = { "Jack" => 11, "Queen" => 12, "King" => 13, "Ace" => 14 }.freeze
  SUIT_VALUES = { 'Diamonds' => 1, 'Clubs' => 2, 'Hearts' => 3, 'Spades' => 4 }.freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def value
    VALUES.fetch(@rank, @rank)
  end

  def suit_value
    SUIT_VALUES[@suit]
  end

  def <=>(other_card)
    if value == other_card.value
      suit_value <=> other_card.suit_value
    else
      value <=> other_card.value
    end
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

class Deck
  RANKS = (2..10).to_a + %w(Jack Queen King Ace).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  def initialize
    @deck = []
    shuffle
  end

  def shuffle
    @deck = RANKS.product(SUITS).map do |rank, suit|
      Card.new(rank, suit)
    end
    @deck.shuffle!
  end

  def draw
    shuffle if @deck.empty?
    @deck.pop
  end

  def to_s
    cards = ''
    @deck.each do |card|
      if card == @deck.last
        cards += "#{card}"
      else
        cards += "#{card}, "
      end
    end
    cards
  end
end

class PokerHand
  attr_reader :poker_hand, :rank_count
  VALUES = { 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6,
             7 => 7, 8 => 8, 9 => 9, 10 => 10,
             "Jack" => 11, "Queen" => 12, "King" => 13,
             "Ace" => 14 }.freeze
  HAND_VALUES = { 'Royal flush' => 10, 'Stright flush' => 9, 'Four of a kind' => 8,
                  'Full house' => 7, 'Flush' => 6, 'Straight' => 5,
                  'Three of a kind' => 4, 'Two pair' => 3, 'Pair' => 2,
                  'High card' => 1 }.freeze

  def initialize(deck)
    @poker_hand = []
    @rank_count = Hash.new(0)
    5.times do
      card = deck.draw
      @poker_hand << card
      @rank_count[card.rank] += 1
    end
  end

  def print
    poker_hand.each do |card|
      puts card.to_s
    end
  end

  def evaluate
    case
    when royal_flush?     then 'Royal flush'
    when straight_flush?  then 'Straight flush'
    when four_of_a_kind?  then 'Four of a kind'
    when full_house?      then 'Full house'
    when flush?           then 'Flush'
    when straight?        then 'Straight'
    when three_of_a_kind? then 'Three of a kind'
    when two_pair?        then 'Two pair'
    when pair?            then 'Pair'
    else                       'High card'
    end
  end

  def to_s
    cards = ''
    poker_hand.each do |card|
      if card == poker_hand.last
        cards += "#{card}"
      else
        cards += "#{card}, "
      end
    end
    cards
  end

  def best_hand?(other_hand)
    if HAND_VALUES[evaluate] > HAND_VALUES[other_hand.evaluate]
      poker_hand
    elsif HAND_VALUES[evaluate] < HAND_VALUES[other_hand.evaluate]
      other_hand
    elsif evaluate == other_hand.evaluate && !flush? &&
          rank_count.values.max > 1 &&
          VALUES[rank_count.key(rank_count.values.max)] > VALUES[other_hand.rank_count.key(rank_count.values.max)]
      poker_hand
    elsif evaluate == other_hand.evaluate && !flush? &&
          rank_count.values.max > 1 &&
          VALUES[rank_count.key(rank_count.values.max)] < VALUES[other_hand.rank_count.key(rank_count.values.max)]
      other_hand
    elsif evaluate == other_hand.evaluate &&
          poker_hand.max.value > other_hand.max.value
      poker_hand
      elsif evaluate == other_hand.evaluate &&
            poker_hand.max.value < other_hand.max.value
        other_hand
    end
  end

  private

  def n_of_a_kind?(num)
    rank_count.one? { |_, count| count == num }
  end

  def royal_flush?
    true if straight_flush? && poker_hand.min.rank == 10
  end

  def straight_flush?
    true if flush? && straight?
  end

  def four_of_a_kind?
    n_of_a_kind?(4)
  end

  def full_house?
    true if n_of_a_kind?(2) && n_of_a_kind?(3)
  end

  def flush?
    suit = poker_hand.first.suit
    poker_hand.all? { |card| card.suit == suit }
  end

  def straight?
    return false if rank_count.any? { |_, count| count > 1 }
    poker_hand.min.value == poker_hand.max.value - 4
  end

  def three_of_a_kind?
    n_of_a_kind?(3)
  end

  def two_pair?
    rank_count.select { |_, count| count == 2 }.size == 2
  end

  def pair?
    n_of_a_kind?(2)
  end
end

hand = PokerHand.new(Deck.new)
hand.print
puts hand.evaluate

# Danger danger danger: monkey
# patching for testing purposes.
class Array
  alias_method :draw, :pop
end

hand = PokerHand.new([Card.new(10,      'Hearts'),
                      Card.new('Ace',   'Hearts'),
                      Card.new('Queen', 'Hearts'),
                      Card.new('King',  'Hearts'),
                      Card.new('Jack',  'Hearts')])

puts hand.evaluate == 'Royal flush'

hand = PokerHand.new([Card.new(8,       'Clubs'),
                      Card.new(9,       'Clubs'),
                      Card.new('Queen', 'Clubs'),
                      Card.new(10,      'Clubs'),
                      Card.new('Jack',  'Clubs')])

puts hand.evaluate == 'Straight flush'

hand = PokerHand.new([Card.new(3, 'Hearts'),
                      Card.new(3, 'Clubs'),
                      Card.new(5, 'Diamonds'),
                      Card.new(3, 'Spades'),
                      Card.new(3, 'Diamonds')])

puts hand.evaluate == 'Four of a kind'

hand = PokerHand.new([Card.new(3, 'Hearts'),
                      Card.new(3, 'Clubs'),
                      Card.new(5, 'Diamonds'),
                      Card.new(3, 'Spades'),
                      Card.new(5, 'Hearts')])

puts hand.evaluate #== 'Full house'

hand = PokerHand.new([Card.new(10, 'Hearts'),
                      Card.new('Ace', 'Hearts'),
                      Card.new(2, 'Hearts'),
                      Card.new('King', 'Hearts'),
                      Card.new(3, 'Hearts')])

puts hand.evaluate == 'Flush'

hand = PokerHand.new([Card.new(8,      'Clubs'),
                      Card.new(9,      'Diamonds'),
                      Card.new(10,     'Clubs'),
                      Card.new(7,      'Hearts'),
                      Card.new('Jack', 'Clubs')])

puts hand.evaluate == 'Straight'

hand = PokerHand.new([Card.new(3, 'Hearts'),
                      Card.new(3, 'Clubs'),
                      Card.new(5, 'Diamonds'),
                      Card.new(3, 'Spades'),
                      Card.new(6, 'Diamonds')])

puts hand.evaluate == 'Three of a kind'

hand = PokerHand.new([Card.new(9, 'Hearts'),
                      Card.new(9, 'Clubs'),
                      Card.new(5, 'Diamonds'),
                      Card.new(8, 'Spades'),
                      Card.new(5, 'Hearts')])

puts hand.evaluate == 'Two pair'

hand = PokerHand.new([Card.new(2, 'Hearts'),
                      Card.new(10, 'Clubs'),
                      Card.new(5, 'Diamonds'),
                      Card.new(9, 'Spades'),
                      Card.new(3, 'Diamonds')])

puts hand.evaluate == 'Pair'

hand = PokerHand.new([Card.new(2,      'Hearts'),
                      Card.new('King', 'Clubs'),
                      Card.new(5,      'Diamonds'),
                      Card.new(9,      'Spades'),
                      Card.new(3,      'Diamonds')])

puts hand.evaluate == 'High card'

hand1 = PokerHand.new([Card.new(3, 'Hearts'),
                       Card.new(3, 'Clubs'),
                       Card.new(5, 'Diamonds'),
                       Card.new(10, 'Spades'),
                       Card.new(3, 'Diamonds')])

hand3 = PokerHand.new([Card.new(10, 'Hearts'),
                       Card.new('Jack', 'Clubs'),
                       Card.new('Queen', 'Diamonds'),
                       Card.new('King', 'Spades'),
                       Card.new('Ace', 'Diamonds')])
puts hand3.best_hand?(hand1)
