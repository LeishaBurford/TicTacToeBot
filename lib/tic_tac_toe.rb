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
  CORNERS = [0, 2, 6, 8]
  SIDE_MIDDLE = [1, 3, 6, 7]
  
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
        if over?
          break
        end
        botTurn
      else
        # bot then player
        botTurn
        if over?
          break
        end
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
    # check if we can win with one move or need to block
    if positions = winOrBlock?(currentPlayer) || positions = winOrBlock?( (currentPlayer == 'X')? 'O' : 'X')
      takeLastSpot(positions)
    
      # check if there is a chance for bot to create a fork, or block oponent from making fork 
    elsif forks = possibleFork?(currentPlayer) || forks = possibleFork?((currentPlayer == 'X')? 'O' : 'X')
      
      
      if forks.size == 1
        # find the most common index and move there
        commonElement = forks.max_by {|i| forks.count(i)}
        move(commonElement, currentPlayer)
      else
        # more than one fork possible,
        # find optimal block point, move there
        move(blockPoint(forks), currentPlayer)
      end
    
      # take the center if its available
    elsif !position_taken?(4)
      move(4, currentPlayer)
    
      # take an opposite corner from the oponent. If not available, take any corner
    elsif corner = cornerMove
      move(corner, currentPlayer)
    
      # play in a middle square on any of the sides 
    else
      SIDE_MIDDLE.each do |position|
        if !position_taken?(position)
          move(position, currentPlayer)
          break
        end
      end
    end
    puts "#{(currentPlayer == 'X')? 'O': 'X'}'s move: "
    displayBoard
  end

  # helper methods for the bot

  
  # return the corner opposiite oponent. If taken, returns any available corner
  def cornerMove
    # corners are 0 2 6 8
    opponent = (currentPlayer == 'X')? 'O' : 'X' 
    CORNERS.each_with_index do |corner, index|
      if @board[corner] == opponent && !position_taken?(CORNER[( i + 2) % 4])
        return CORNER[( i + 2) % 4]
      end
    end

    # if here, then there is no opposite corner left to occupy, so any avaiable corner
    CORNERS.each do |corner| 
      if !position_taken?(corner) 
        return corner
      end
    end
    return false
  end

  # finds the optimal place to put tile when multiple forks are possible
  def blockPoint(forks)
    # this keeps track of the tiles that each fork has in common
    # the most frequent and unoccupied index will be returned
    commonIndicies = forks[0] # initializing
    # intersect each of the forks to find a the tile they all depend on
    for i in 1 ... forks.size
      commonIndicies &= forks[i]
    end
    validPositions = commonIndicies.select {|i| !position_taken?(i)}
    # finds the most frequent index
    return validPositions.max_by {|i| validPositions.count(i)}
  end

  def possibleFork?(token) 
    availableSpaces = (0...9).select {|i| !position_taken?(i)}
    forks = []
    for i in 0 ... availableSpaces.size
      # temporarily move to this position
      move(availableSpaces[i], token)
      fork = twoInARow?(token, true)
      if fork
        forks.append(fork) 
      end
      undoMove(availableSpaces[i])
    end
    
    return (forks.size == 0)? false : forks
  end

  # returns the indicated index to " "
  def undoMove(index)
    @board[index] = " "
  end

  # either win the game or block the opponent
  def winOrBlock?(token)
    positions = twoInARow?(token, false)
    if positions
      return positions
    end
    return false
  end

  # goes through the provided array and fills the available spot with specified token
  # assumes positions is an array with either two 'X' or two 'O' and one blank
  def takeLastSpot(positions)
    i = 0
    until validMove?(positions[i])
      i += 1
    end
    # now i is location of unfilled win combo
    move(positions[i], currentPlayer)
  end

  # check if there are two of the same letters within a row
  # flag is true when we are looking for forks
  def twoInARow?(token, flag)

    fork = []
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
        if flag 
          fork = fork + win_combination
          if fork.size == 6 # we found 2 possible win combinations
            return fork
          end
        else
          return win_combination
        end
      end
    end
    return false
  end
end

  