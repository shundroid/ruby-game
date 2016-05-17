# -*- coding: utf-8 -*-

class ScreenInfo
  def initialize width, height
    @width = width
    @height = height
  end
  def getWidth
    return @width
  end
  def getHeight
    return @height
  end
end
screen = ScreenInfo.new 100, 10

class Cursor
  def initialize
    @cursorColumn = 0
    @cursorRow = 0

    # 画面全体をクリア
    printf "\e[2J"

    # カーソルを非表示
    printf "\e[?25l"

    at_exit {
      # 画面全体をクリア
      printf "\e[2J"

      # カーソルを表示
      printf "\e[?25h"
    }
  end

  def write column, row, text
    @cursorColumn = column
    @cursorRow = row
    updateCursor
    print text
  end

  private
  def updateCursor
    printf "\e[#{@cursorRow};#{@cursorColumn}H"
  end

end

cursor = Cursor.new

class Line
  def initialize width, y, cursorInstance
    @width = width
    @line = y
    @cursorInstance = cursorInstance

    backText = ""
    for x in 0..@width do
      backText += "-"
    end
    @cursorInstance.write 0, @line, backText
  end

  def spawnChar
    @charX = 0
    @charY = 0
    updateChar
  end

  def moveChar

  end

  private
  def updateChar
    @cursorInstance.write @charX, @charY, ">"
  end
end

lines = []
for y in 0..screen.getHeight do
  lines.push Line.new(screen.getWidth, y, cursor)
end
lines[0].spawnChar

sleep 1

