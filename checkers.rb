class Board
  
  attr_accessor :grid
  
  def initialize
    @grid = Array.new(8){Array.new(4)}  
  end
  
  def [](pos)
    i,j = pos
    @grid[i][j]
  end
  
  def []=(pos,piece)
    i,j = pos
    @grid[i][j] = piece
  end
  
  def set_board
    [:red,:black].each do |color|
      12.times do |i|
        set_pieces(color,i,self)
      end
    end
  end
  
  def set_pieces(color,i,board)
    pos = set_pos(color)
    add_piece(pos,Piece.new(color,pos,board))
  end
  
  def set_pos(color)
    color == :black ? [i/4,i%4] : [7-i/4,i%4]
  end
  
  def add_piece(pos,piece)
    self[pos] = piece
  end
  
end



class Piece
  
  attr_accessor :color, :position
  
  def initialize(color,pos,board)
    @color = color
    @position = pos
    @board = board
  end
  
  def directions 
    if color == :black
      position.even? ? [[1,-1],[1,0]] : [[1,1],[1,0]] 
    else
      position.even? ? [[-1,-1],[-1,0]] : [[-1,1],[-1,0]]
    end
  end
  
  def valid_moves
    moves = moves_on_board
    moves = remove_blocked_moves(moves)
    
    #check if opponent piece in the way
  end
  
  def moves_on_board
    moves = []
    directions.each do |direction|
      move = move_coords(position,direction)
      moves << move if on_board?(move)
    end
    moves
  end
  
  def on_board?(coord)
    (0..7).include?(coord[0]) && (0..3).include?(coord[1])
  end
  
  def remove_blocked_moves(moves)
    moves.select do |move|
      @board[move].nil? || @board[move].color != self.color
    end
  end
  
  def opponents_piece?(move)
    return false if @board[move].nil?
    true
  end
  
  private
  
  def move_coords(array1,array2)
    array1.zip(array2).map{|array| array.inject(:+)}
  end
  
end



class Checkers
  
  def initialize
  end
  
  
  
end