# -*- coding: utf-8 -*-
require "thread"
require "io/console"

class Screen
  def initialize width, height
    @width = width
    @height = height
    @screenLines = [""]

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

  def write column, row, text
    if row >= @screenLines.length then
      @screenLines.push ""
    end
    if column >= @screenLines[row].length then
      [@screenLines[row].length - 1 .. column - 1].each do
        @screenLines[row] << " ";
      end
    end
    @screenLines[row].slice column, text.length
    @screenLines[row].insert column, text
  end

  def draw
    updateCursor 0, 0
    print @screenLines.join "\n"
  end

  def writeDebugLog log
    clearText = " "
    (0..@screenInstance.getWidth).each do
      clearText << " "
    end
    updateCursor @screenInstance.getHeight + 1, 0
    print clearText
    updateCursor @screenInstance.getHeight + 1, 0
    print log
  end

  private
  def updateCursor row, column
    printf "\e[#{row};#{column + 1}H"
  end
end
screen = Screen.new 30, 30

class Line
  def initialize width, y, screenInstance
    @width = width
    @line = y
    @screenInstance = screenInstance
    @charX = 0
    @charDirection = 1
    @isDead = false

    backText = ""
    for x in 0..@width do
      backText += getBack x
    end
    @screenInstance.write 0, @line, backText
  end

  def moveChar
    if @charX > @screenInstance.getWidth then
      @isDead = true
      updateChar
    elsif !@isDead then
      updateCharDirection
      @charX += @charDirection
      updateChar
    end
  end

  def throwChar
    if @isDead then
      return
    end
    if @charX >= @screenInstance.getWidth - 3 then
      @charDirection = -1
    end
  end

  private
  def updateChar
    @screenInstance.write @charX - @charDirection, @line, getBack(@charX - @charDirection)
    @screenInstance.write @charX, @line, getCharText
  end

  def updateCharDirection
    if @charDirection == -1 && @charX <= 0 then
      @charDirection = 1
    end
  end

  def getBack x
    if x > @screenInstance.getWidth - 3 then
      return "|"
    end
    return " "
  end

  def getCharText
    if @isDead then
      return "X"
    elsif @charDirection == 1 then
      return ">"
    end
    return "<"
  end
end

lines = []
for y in 0..screen.getHeight do
  lines.push Line.new(screen.getWidth, y, screen)
end

Thread.new do
  while (key = STDIN.getch) != "\C-c"
    if key.inspect == "\"a\"" then
      lines.each do |line|
        line.throwChar
      end
    end
  end

  # C-c を押されたら終了
  exit
end

lastSpawnedLine = 0
loop do
  if lastSpawnedLine < lines.length then
    lastSpawnedLine += 1
  end
  lines.each_with_index do |line, index|
    if index <= lastSpawnedLine then
      line.moveChar
    end
  end
  screen.draw
  sleep 0.05
end

