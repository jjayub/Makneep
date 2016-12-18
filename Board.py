from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
from game_init import *
from Piece import *
from pyswip import Prolog


class Board:
    def __init__(self):
        self.board = self.gen_board()
        self.eat_list = []
        self.prolog = Prolog()
        self.prolog.consult("test.pl")

    def gen_board(self):
        """
        Create a board
        """
        # Initialize board matrix
        board = [[None] * 8 for i in range(8)]

        for row in range(8):
            for col in range(8):
                if row == 0:
                    board[row][col] = Piece(color=RED)
                elif row == 7:
                    board[row][col] = Piece(color=BLUE)
        return board

    def ai_move_prolog(self):
        """
        consult hoe to move with AI
        """
        output = list(self.prolog.query("alphabeta(%s, -100, 100, Board, _, 3)" % (str(self.__get_board(self.board)))))[0]['Board']
        start, end = self.__find_move(output)
        self.move_piece(start, end)
        self.check_eat(pos=end, color=RED)
        self.eat_piece(color=RED)

    def __find_move(self, newBoard):
        temp = list(self.prolog.query("getAItoMove(" + str(self.__get_board(self.board)) + "," + str(newBoard) + " , X)"))[0]['X']
        pos1 = temp[0][0]
        pos2 = temp[1][0]
        return (pos1 % 8, pos1 // 8), (pos2 % 8, pos2 // 8)

    def __get_side_list(self, color):
        """
        Get list of all piece for color side
        """
        board = []
        for y in range(8):
            for x in range(8):
                if self.board[y][x] is not None and self.board[y][x].color == color:
                    board.append(y * 8 + x)
        return board

    def move_piece(self, start, end):
        """
        Move piece from (start_x, start_y) to (end_x, end_y)
        """
        start_x, start_y = start
        end_x, end_y = end

        self.board[end_y][end_x] = self.board[start_y][start_x]
        self.remove_piece((start_y, start_x))
        source_coord = start_y * 8 + start_x
        dest_coord = end_y * 8 + end_x
        self.move_piece_prolog(source_coord, dest_coord)

    def __get_board(self, board_state):
        """
        get board for prolog ; None = 0, RED = 1, BLUE = 2
        """
        board = [None] * 64

        for y in range(8):
            for x in range(8):
                if board_state[y][x] is None:
                    board[y * 8 + x] = 0
                elif board_state[y][x].color == RED:
                    board[y * 8 + x] = 1
                elif board_state[y][x].color == BLUE:
                    board[y * 8 + x] = 2
        return board

    def retract_board(self):
        redP = list(self.prolog.query("getPieces(red,X)"))[0]['X']
        blueP = list(self.prolog.query("getPieces(blue,X)"))[0]['X']
        for p in redP:
            self.prolog.retract("onBoard(red, " + str(p) + ")")
        for p in blueP:
            self.prolog.retract("onBoard(blue, " + str(p) + ")")

    def get_move(self, pos):
        """
        Get all valid move from prolog
        """
        x, y = pos
        # send board and focus element to prolog to compile
        coord = "[" + str(y * 8 + x) + "]"
        move_list = list(self.prolog.query("getPosMoves(" + coord + ", Result)"))
        move_list = move_list[0]["Result"]
        return [[coord % 8, coord // 8] for coord in move_list]

    def move_piece_prolog(self, source, dest):
        color = list(self.prolog.query("onBoard(Color, " + str(source) + ")"))[0]['Color']
        self.prolog.assertz('onBoard(' + str(color) + ',' + str(dest) + ')')
        self.prolog.retract('onBoard(' + str(color) + ',' + str(source) + ')')

    def check_eat(self, pos, color):
        """
        Check from prolog if it eat
        """
        x, y = pos
        if color == BLUE:
            board_enemy = str(self.__get_side_list(RED))
            board_ally = str(self.__get_side_list(BLUE))
        else:
            board_enemy = str(self.__get_side_list(BLUE))
            board_ally = str(self.__get_side_list(RED))
        coord = str(y * 8 + x)
        ans = list(self.prolog.query("check_to_eat(" + board_enemy + "," + board_ally + "," + coord + ", Eat_list)"))
        self.eat_list = ans[0]["Eat_list"]
        return self.eat_list is not []

    def eat_piece(self, color):
        """
        remove piece get from check_eat
        """
        eaten_piece = [(coord % 8, coord // 8) for coord in self.eat_list]
        for piece_coord in eaten_piece:
            x, y = piece_coord
            self.remove_piece(tuple([y, x]))
        # convert to 0 - 63 before use below
        temp = []
        for i in eaten_piece:
            x, y = i
            temp.append(y * 8 + x)
        self.remove_piece_prolog(temp, color)
        self.eat_list = []

    def remove_piece_prolog(self, remove_list, turn):
        if turn == RED:
            color = 'blue'
        else:
            color = 'red'
        for p in remove_list:
            self.prolog.retract("onBoard(" + str(color) + "," + str(p) + ")")

    def location(self, pos):
        """
        Get of object of (x,y) coordinates from board
        """
        x, y = pos
        return self.board[y][x]

    def getAllOnBoard(self):
        return list(self.prolog.query("getPieces(X)"))[0]['X']

    def remove_piece(self, pos):
        """
        Remove piece according to that coordinate
        """
        x, y = pos
        self.board[x][y] = None

    def count_piece(self):
        """
        Count remaining piece each player for check game over
        :returns red and blue amount
        """
        red = 0
        blue = 0
        for row in self.board:
            for col in row:
                if col is not None:
                    if col.color == RED:
                        red += 1
                    elif col.color == BLUE:
                        blue += 1
        return red, blue
