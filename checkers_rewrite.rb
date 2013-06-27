class Board
  attr_accessor :grid, :pieces
  
  def initialize
    @grid = Array.new(8){Array.new(8)}  
    @pieces = []
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
    pos = set_pos(color,i)
    add_piece(pos,Piece.new(color,pos,board))
  end
  
  def set_pos(color,i)
    if color == :black 
      return [i/4,i * 2 % 8] if (i/4).even?
      [i/4,i * 2 % 8 + 1]
    else 
      return [7 - i/4,i * 2 % 8 + 1]  if (i/4).even?
      [7 - i/4, i * 2 % 8]
    end
  end

  
  def add_piece(pos,piece)
    self[pos] = piece
    @pieces << piece
  end

  def render
    letters = (0..7).to_a
    print "   0  1  2  3  4  5  6  7\n"
    @grid.each_with_index do |row,index|
      display_row = row.map do |piece| 
        if piece.nil?
          '_' 
        elsif piece.color == :black
          'b'
        elsif piece.color == :red
          'r'
        end
      end
      print 
      print "#{letters[index]}  #{display_row.join("  ")}\n" if @grid.index(row).even?
      print "#{letters[index]}  #{display_row.join("  ")}\n" if @grid.index(row).odd?
    end
  end
  
  def perform_jump(move)
    #raise ArgumentError.new "InvalidMove" 
    
    piece = self[move.first]
    spot = self[move.last]
    piece_killed = self[move.last.zip(move.first).map{|a| a.inject(:+)/2}]
    if piece.jump_moves.include?(move.last)
      self[move.last] = piece
      self[move.first] = nil
      self[move.last.zip(move.first).map{|a| a.inject(:+)/2}] = nil
      piece.position = move.last
      @pieces - [piece_killed]
    end
  end
  
  def perform_step(move)
    self[move.first],self[move[1]] = nil,self[move.first]
    self[move[1]].position = move[1]
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
  
  def game_over?
    color = @pieces[0].color
    @pieces.each do |piece|
      return false if color != piece.color
      color = piece.color
    end
    true
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
      [[1,1],[1,-1]] 
    else
      [[-1,1],[-1,-1]]
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
  
  def moves_on_board
    moves = []
    directions.each do |direction|
      move = move_coords(position,direction)
      moves << move if on_board?(move) && !opponents_piece?(move)
    end
    moves
  end
  
  def on_board?(coord)
    (0..7).include?(coord[0]) && (0..7).include?(coord[1])
  end
  
  def remove_blocked_moves(moves)
    moves.select do |move|
      @board[move].nil? #|pie| @board[move].color != self.color
    end
  end
  
  def opponents_piece?(move)
    return false if @board[move].nil? || @board[move].color == @color
    true
  end
  
  def move_coords(array1,array2)
    array1.zip(array2).map{|array| array.inject(:+)}
  end
  
end
  
class Checkers
  
  def initialize
    @board = Board.new
    @player1 = Player.new(:red)
    @player2 = Player.new(:black)
  end
  
  def turn
    [@player1,@player2].each do |player|
      begin
        @board.render
        moves = player.move
        unless @board[moves.first].color == player.color
          raise ArgumentError.new "wrong piece"
        end
        @board.perform_moves!(moves) 
      rescue ArgumentError => e
        puts "Error: #{e}"
        retry
      end
    end
  end
  
  def play
    
    until @board.game_over?
      turn
    end
    
    "gameover"
    
  end
  
end

class Player
  
  attr_accessor :color
  
  def initialize(color)
    @color = color
  end
  
  def move
    puts "move:"
    string_moves = gets.split(' ')
    raise ArgumentError.new "type something!" if string_moves == []
    moves = string_moves.map{|move| move.split(',').map{|n| n.to_i}}
    moves
  end
  
  
end
# 
# board = Board.new
# piece = Piece.new(:red,[5,1],board)
# piece2 = Piece.new(:black,[4,2],board)
# board[[5,1]] = piece
# board[[4,2]] = piece2
# board[[1,1]] = nil
# print piece.jump_moves
# board.render
# print board.perform_moves!([[5,1],[3,3],[1,1]])
# print piece.jump_moves
# board.render