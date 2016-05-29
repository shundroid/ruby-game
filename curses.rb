require "curses"

Curses.init_screen

begin
  s = "Hello World!, こんにちは"
  win = Curses::Window.new 7, 40, 5, 10
  win.box ?|, ?-, ?*
  win.setpos win.maxy / 2, win.maxx / 2 - s.bytesize / 2
  win.addstr s
  win.refresh
  win.getch
  win.close
ensure
  Curses.close_screen
end
