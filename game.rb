# -*- coding: utf-8 -*-
class ScreenInfo
  def initialize width, height
    @width = width
    @height = height

    # 画面全体をクリア
    printf "\e[2J"
    # カーソルを非表示
    printf "\e[?25l"

    at_exit {
      # カーソル位置を変更
      printf "\e[#{height + 1};0H"
      # カーソルを表示
      printf "\e[?25h"
    }

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
  def initialize width, y, cursorInstance, screenInfoInstance
    @width = width
    @line = y
    @cursorInstance = cursorInstance
    @screenInfoInstance = screenInfoInstance
    @charX = 0

    backText = ""
    for x in 0..@width do
      backText += getBack x
    end
    @cursorInstance.write 0, @line, backText
  end

  def spawnChar
    @charX = 0
    updateChar
  end

  def moveChar
    @charX += 1
    updateChar
  end

  private
  def updateChar
    if @charX > 0 then
      @cursorInstance.write (@charX - 1), @line, getBack(@charX - 1)
    end
    @cursorInstance.write @charX, @line, ">"
  end

  def getBack x
    if x > @screenInfoInstance.getWidth - 2 then
      return "|"
    end
    return "-"
  end
end

lines = []
for y in 0..screen.getHeight do
  lines.push Line.new(screen.getWidth, y, cursor, screen)
end
lines[0].spawnChar

loop do
  lines.each do |line|
    line.moveChar
  end
  sleep 0.05
end

