class ComputerPlayer
  attr_accessor :color, :opp_color, :best_move, :board, :best_eval, :alpha, :beta,
    :non_captures, :mate_found, :k_castled, :q_castled, :queened, :moved_piece,
    :last_captured, :reverse_move, :disabled_castling

  include UndoMove

  def initialize(color)
    @color = color
    @opp_color = @color == COLORS[0] ? COLORS[1] : COLORS[0]
  end

  def play_turn(board)
    @board = board
    find_best_move
  end

  private

  def find_best_move
    @best_move, @best_eval, @alpha, @beta = nil, nil, -100000, 100000
    pieces = get_pieces
    @non_captures = []
    #search captures first more likely for alpha spikes allowing for early returns
    return_mate = test_captures(pieces)
    return return_mate unless return_mate.nil?

    return_mate = test_non_captures
    return return_mate unless return_mate.nil?

    best_move
  end

  def test_non_captures
    non_captures.each do |move|
      cur_eval = test_move(move)
      return cur_eval if mate_found
      alpha_beta_checker(cur_eval, move)
    end

    nil
  end

  def test_captures(pieces)
    pieces.each do |piece|
      moves = get_moves(piece)
      captures = sort_by_captures(moves)
      captures.each do |move|
        cur_eval = test_move(move)
        return cur_eval if mate_found
        alpha_beta_checker(cur_eval, move)
      end
    end

    nil
  end

  def get_moves(piece)
    piece_moves = piece.legal_moves(board)
    piece_moves.map do |target|
      [piece.curr_pos, target]
    end
  end


  def get_pieces
    board.get_pieces(color)
  end

  def get_opp_pieces
    board.get_pieces(opp_color)
  end

  def depth
    piece_count = get_pieces.count + get_opp_pieces.count

    depth = 2
    depth = 3 if piece_count < 10
    depth = 4 if piece_count < 5

    depth
  end

  def sort_by_captures(moves)
    captures = []

    moves.each_with_index do |move, idx|
      if board[move[1]].class < Piece
        captures << move
      else
        non_captures << move
      end
    end

    captures
  end

  def test_move(move)
    @mate_found, @k_castled, @q_castled, @queened = false, false, false, false
    #make move, get eval from child node, undo move
    save_move(move)
    check_special_move(board.make_any_move(move[0], move[1]))
    #if mate stop and return mate
    if board.is_mate?(opp_color)
      mate_move_found
      return move
    end

    cur_node = Node.new(board, opp_color, color)
    new_eval = -1 * cur_node.alpha_beta(depth, -beta, -alpha, 1)
    undo_move

    new_eval
  end

  def mate_move_found
    undo_move
    @mate_found = true
  end

  def alpha_beta_checker(cur_eval, move)
    if cur_eval > alpha
      @alpha = cur_eval
      @best_move = move
    end
  end

end
