class Knight < Piece
  include SteppingPiece

  def initialize(color = "white", board, curr_pos)
    super(color, board, curr_pos)
  end

  def moves(board)
    @board = board
    move_knight(@curr_pos)
  end

  def inspect
    to_s
  end

  def to_s
    return "\u2658".encode("utf-8") if color == 'white'
    "\u265E".encode('utf-8')
  end
end