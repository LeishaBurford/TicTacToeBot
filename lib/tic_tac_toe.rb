class TicTacToe
  
  WIN_COMBINATIONS = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [6, 4, 2]
  ]
  
  def initialize
    @board = [" ", " ", " ", " ", " ", " ", " ", " ", " "]
  end
  
  def displayBoard
    puts " #{@board[0]} | #{@board[1]} | #{@board[2]} "
    puts "-----------"
    puts " #{@board[3]} | #{@board[4]} | #{@board[5]} "
    puts "-----------"
    puts " #{@board[6]} | #{@board[7]} | #{@board[8]} "
    puts "\n"
  end
  
  def inputToIndex(index)
    return index.to_i - 1
  end
  
  def move(index, token)
    @board[index] = token
  end
  
  def position_taken?(index)
    
    !(@board[index].nil? || @board[index] == " ")
  end
  
  def validMove?(index)
    if position_taken?(index) || !index.between?(0, 8)
      return false
    end
    return true
  end
  
  def turn
    puts "Please enter 1-9:"
    index = inputToIndex(gets.strip)
    while !validMove?(index)
      puts "Please enter 1-9:"
      index = inputToIndex(gets.strip)
    end
    move(index, currentPlayer)
    displayBoard
  end
  
  def turn_count
    counter = 0
    @board.each do |place| 
      if place == "X" || place == "O"
        counter += 1
      end
    end
    return counter
  end
  
  def currentPlayer
    return (turn_count % 2 == 0) ? "X" : "O"
  end
  
  def won?
    WIN_COMBINATIONS.each do |win_combination|
      win_index_1 = win_combination[0]
      win_index_2 = win_combination[1]
      win_index_3 = win_combination[2]
      position_1 = @board[win_index_1]
      position_2 = @board[win_index_2]
      position_3 = @board[win_index_3]
      
      if position_1 == "X" && position_2 == "X" && position_3 == "X"
        return win_combination
      end
      if position_1 == "O" && position_2 == "O" && position_3 == "O"
        return win_combination
      end
    end
    return false
  end

  def full?
    return !(@board.any? { |element| element == " " })
  end
      
  def draw?
    return !won? && full?
  end
  
  def over?
    return won?|| draw?
  end
  
  def winner
    if win_combination = won? 
      return @board[win_combination[0]]
    end
  end
  
  def play
    # player selects X or O
    player = ''
    until player.downcase == 'o' || player.downcase == 'x'
      puts "Pick your letter, X starts and O follows (X/O)"
      player = gets.strip
    end
    # might not need to worry about this, then again...
    robot = (player.downcase == 'x')? 'o' : 'x'
    player = player.downcase

    until over?
      if player == 'x'
        # player then bot
        turn
        botTurn
      else
        # bot then player
        botTurn
        turn
      end
    end
    if won?
      puts "Congratulations #{winner}!"
    else
      puts "Cat's Game!"
    end
  end


  # method to determine bot's optimal move
  def botTurn
    # check if we can win with one move
    if winOrBlock(currentPlayer)
      displayBoard
      return 
    # check if we need to block
    elsif winOrBlock( (currentPlayer == 'X')? 'O' : 'X')
      displayBoard
      return
    else
      # testing just pick the next avaliable move
      if !over?
        i = 0
        until validMove?(i) || over?
          i += 1
        end
        move(i, currentPlayer)
      end
      
      displayBoard
    end
  end

  # either win the game or block the opponent
  def winOrBlock(token)
    positions = twoInARow(token)
    if positions
      
      takeLastSpot(positions, currentPlayer)
      return true
    end
    return false
  end


  # helper methods for the bot

  # goes through the provided array and fills the available spot with specified token
  # assumes positions is an array with either two 'X' or two 'O' and one blank
  def takeLastSpot(positions, token)
    i = 0
    until validMove?(positions[i])
      i += 1
    end
    # now i is location of unfilled win combo
    move(positions[i], token)
  end

  # check if there are two of the same letters within a row
  def twoInARow(token)

    WIN_COMBINATIONS.each do |win_combination|
      win_index_1 = win_combination[0]
      win_index_2 = win_combination[1]
      win_index_3 = win_combination[2]
      position_1 = @board[win_index_1]
      position_2 = @board[win_index_2]
      position_3 = @board[win_index_3]
    
      positions = [position_1, position_2, position_3]
      countOfLetterInRow = positions.count(token)
      emptySpaceAvaliable = positions.count(" ")
      if countOfLetterInRow == 2 && emptySpaceAvaliable == 1
        return win_combination
      end
    end
    return false
  end
end

  