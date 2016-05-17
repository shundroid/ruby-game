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
screen = ScreenInfo.new 20, 10

class Cursor
  def initialize screenInfoInstance
    @screenInfoInstance = screenInfoInstance;
  end

  def write column, row, text
    updateCursor row, column
    print text
  end
  def writeDebugLog log
    clearText = " "
    (0..@screenInfoInstance.getWidth).each do
      clearText += " "
    end
    updateCursor @screenInfoInstance.getHeight + 1, 0
    print clearText
    updateCursor @screenInfoInstance.getHeight + 1, 0
    print log
  end

  private
  def updateCursor row, column
    printf "\e[#{row};#{column}H"
  end

end

cursor = Cursor.new screen

class Line
  def initialize width, y, cursorInstance, screenInfoInstance
    @width = width
    @line = y
    @cursorInstance = cursorInstance
    @screenInfoInstance = screenInfoInstance
    @charX = 0
    @charDirection = 1

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
    @charX += @charDirection
    updateChar
    updateCharDirection
  end

  private
  def updateChar
    if @charDirection == 1 && @charX > 0 then
      @cursorInstance.write @charX - 1, @line, getBack(@charX - 2)
    elsif @charDirection == -1 && @charX <= @screenInfoInstance.getWidth then
      @cursorInstance.write @charX + 1, @line, getBack(@charX)
    end
    @cursorInstance.write @charX, @line, getCharText
  end

  def updateCharDirection
    if @charDirection == 1 && @charX > @screenInfoInstance.getWidth then
      @charDirection = -1
    elsif @charDirection == -1 && @charX - 1 <= 0 then
      @charDirection = 1
    end
  end

  def getBack x
    if x > @screenInfoInstance.getWidth - 2 then
      return "|"
    end
    return "-"
  end

  def getCharText
    if @charDirection == 1 then
      return ">"
    end
    return "<"
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

