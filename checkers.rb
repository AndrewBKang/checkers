class Board
  
  attr_accessor :grid
  
  def initialize
    @grid = Array.new(8){Array.new(8)}  
    set_board
    render
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
    pos = set_init_pos(color,i)
    add_to_board(pos,Piece.new(color,pos,board))
  end
  
  def set_init_pos(color,i)
    if color == :black 
      return [i/4,i % 8] if (i/4).even?
      [i/4,i % 8 +1]
    else 
      return [7-i/4,i%8+1]  if (i/4).even?
      [i/4,i%8]
    end
  end
  
  def add_to_board(pos,piece)
    self[pos] = piece
  end
  
  def render
    @grid.each do |row|
      display_row = row.map do |piece| 
        if piece.nil?
          ' ' 
        elsif piece.color == :black
          'b'
        elsif piece.color == :red
          'r'
        end
      end
      print "#{display_row.join("  ")}\n" if @grid.index(row).even?
      print "#{display_row.join("  ")}\n" if @grid.index(row).odd?
    end
  end
  
  def perform_jump(move)
    self[move.first] = piece
    self[move.last] = spot
    self[move.last.zip(move.first).map{|a| a.inject(:+)/2}] = opp_piece
    if piece.jump_moves.include?(move.last)
      self[move.last] = piece
      self[move.first] = nil
      opp_piece = nil
      piece.position = move.last
    end
  end
  
  def perform_step(move)
    self[move.first],self[moves[1]] = nil,self[move.first]
  end
  
  def perform_moves!(move_seq)
    if self[move_seq.first].step_moves.include?(move_seq.last)
      perform_step(move_seq)
    elsif self[move_seq.first].jump_moves.include?(move_seq[1])
      move_seq.each_index do |i|
        next if i == move_seq.length - 1
        perform_jump([move_seq[i],move_seq[i+1]])
      end
    else
      raise ArgumentError.new "InvalidMove"
    end
  end
  
  def valid_mov_seq?(piece,move_seq)
    trial_board = self.dup
    trial_piece = piece.dup
    begin
      perform_moves
    end
      
    
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
    row = position[0]
    if color == :black
      row.even? ? [[1,-1],[1,0]] : [[1,1],[1,0]] 
    else
      row.even? ? [[-1,-1],[-1,0]] : [[-1,1],[-1,0]]
    end
  end
  
  def step_moves
    moves = moves_on_board
    remove_blocked_moves(moves)
  end
  
  def jump_moves
    moves = []
    directions.each do |direction|
      check = move_coords(position,direction)
      next unless opponents_piece?(check)
      move = move_coords(check,direction)
      moves << move if @board[move].nil?
    end
    moves
  end
  
  def valid_moves
    return jump_moves unless jump_moves.nil?
    step_moves
  end
  
  def moves_on_board
    moves = []
    directions.each do |direction|
      move = move_coords(position,direction)
      moves << move if on_board?(move) && !opponents_piece?(move)
    end
    moves
  end
  
  def on_board?(coord)
    (0..7).include?(coord[0]) && (0..3).include?(coord[1])
  end
  
  def remove_blocked_moves(moves)
    moves.select do |move|
      @board[move].nil? #|pie| @board[move].color != self.color
    end
  end
  
  def opponents_piece?(move)
    return false if @board[move].nil?
    true
  end
  
  def move_coords(array1,array2)
    array1.zip(array2).map{|array| array.inject(:+)}
  end
  
end

# board = Board.new
# piece = Piece.new(:red,[5,1],board)
# piece2 = Piece.new(:black,[4,2],board)
# board[[5,1]] = piece
# board[[4,2]] = piece2
# board[[1,1]] = nil
# print piece.jump_moves
# print board.perform_moves!([[5,1],[3,3]])
# print piece.jump_moves
# board.render

class Checkers
  
  def initialize
    @board = Board.new
  end
  
  def play
    
  end
  
  
  
end