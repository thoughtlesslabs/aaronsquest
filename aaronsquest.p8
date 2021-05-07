pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- aaron's quest
-- a thoughtless labs experiment

function _init()
 _update60= update_menu
	_draw= draw_menu
	movable_items = {}
	keycode = {}
	init_player()
	init_map()
	add_keycode()
	add_movables()
	reading=false
end

function init_map()
 wall = {49,5,1,2,50,21}
 door = {5}
 opendoor ={6}
 key = {32,16}
end

function init_player()
	p = {}
	p.x = 1
	p.y = 1
	p.sprite = 8
	p.keys = 0
end

function init_code(x,y,k,sprite)
 code = {}
 code.x = x
 code.y = y
 code.key = k
 code.sprite = sprite
 code.show = false
 add(keycode,code)
end

function add_keycode()
	init_code(5,2,"a",53)
	init_code(12,2,"b",37)
	init_code(13,7,"c",37)
end

function init_movable(x,y,sprite)
	mi = {}
	mi.x = x
	mi.y = y
	mi.sprite = sprite
	add(movable_items,mi)
end

function add_movables()
	--add movable boxes
	init_movable(11,10,21)
	init_movable(7,8,21)
	
	-- add movable rocks
	init_movable(4,2,19)
	init_movable(12,2,35)
end	


	



-->8
-- update functions

function update_menu()
	if btnp(5) then
		_update60 = update_game
		_draw = draw_game
		tb_init(0,{"sir aaron...","a magical treasure awaits!","but, you must solve these\npuzzles to unlock your bounty.\ndo not hesitate.","go forth!"})
	end
end

function update_game()
 if reading then
  tb_update()
 else
  move_player()
  if btnp(4) then
  local chrs={"","",""}
  for i=1,#keycode do
  	if keycode[i].show then
  	 chrs[i] = keycode[i].key
  	else
  		chrs[i] = " "
  	end
  end
  showcode = chrs[1]..chrs[2]..chrs[3]		
	 	tb_init(0,{"inventory\nkeys: "..p.keys.."\ncode: "..showcode})
 	end
 end
end

function move_player()
	
	newx = p.x
	newy = p.y

	if btnp(0) then newx -=1 push="right" end
	if btnp(1) then newx +=1 push="left" end
	if btnp(2) then newy -=1 push="up" end
	if btnp(3) then newy +=1 push="down" end
	
	interact(newx,newy)
	
	if can_move(newx,newy) then
		p.x = mid(0,newx,127)
		p.y = mid(0,newy,63)
	else
		sfx(0)
	end
end
-->8
-- draw functions

function draw_menu()
	cls()
	spr(64,36,45,7,4)
	print("press ❎ to start",32,90,6)
end

function draw_game()
	cls()
	draw_map()
	draw_keycode()
	draw_player()
	draw_movables()
	tb_draw()
end

function draw_map()

	mapx = flr(p.x/16)*16
	mapy = flr(p.y/16)*16
	
	camera(mapx*8,mapy*8)
	
	map(0,0,0,0,128,64)
end

function draw_player()
	spr(p.sprite,p.x*8,p.y*8)
end

function draw_movables()
 for i=1, #movable_items do
 	spr(movable_items[i].sprite,movable_items[i].x*8,movable_items[i].y*8)
	end
end

function draw_keycode()
	ky = keycode
	for i=1, #ky do
		spr(ky[i].sprite,ky[i].x*8,ky[i].y*8)
	end
end
-->8
-- game functions

--  check if the player can move
function can_move(x,y)
	if is_tile(wall,x,y) or is_movable(x,y) then
		return false
	else
		return true
	end
end

-- check for tile type
function is_tile(tile_type,x,y)
	tile = mget(x,y)
	for i=1,#tile_type do
		if tile == tile_type[i] then
			return true
		end
	end
	return false
end

-- check if hit crate
function is_movable(x,y)
	for i=1,#movable_items do
		if x == movable_items[i].x and y==movable_items[i].y then
			return true
		end
	end
	return false
end

-- check if a keycode
function is_keycode(x,y)
	for i=1,#keycode do
		if not keycode[i].show then
		if x == keycode[i].x and y == keycode[i].y then
			return true
		end
	end
	end
	return false
end


-- interaction options based
-- on the tile
function interact(x,y)
	if is_tile(door,x,y) then
		if p.keys>0 then
	 	swap_tile(x,y)
	 	p.keys -=1
	 else
	 	tb_init(0,{"the door is locked"})
	 end
	elseif is_movable(x,y) then
		move_item(x,y)
	elseif is_tile(key,x,y) then
		p.keys+=1
		swap_tile(x,y)
		if is_keycode(x,y) then
			update_code(x,y)
			extranote = "\nand a piece of the puzzle\ncheck your inventory with 🅾️"
		else
			extranote = ""
		end
		tb_init(0,{"you found a key!"..extranote})
	elseif is_keycode(x,y) then
		tb_init(0,{"you found a piece of the puzzle"})
		update_code(x,y)
	end
end
		
		
-- swap and unswap tiles
function swap_tile(x,y)
	tile = mget(x,y)
	mset(x,y,tile+1)
end

-- push a crate
function move_item(x,y)

	nx = x
	ny = y
	
	for i=1,#movable_items do
		if nx == movable_items[i].x and ny==movable_items[i].y then
			if push == "left" then
				nx +=1
			elseif push == "right" then
			 nx -=1
			elseif push == "up" then
				ny -=1
			elseif push == "down" then
				ny +=1
			end
		end
		if can_move(nx,ny) then
			movable_items[i].x = mid(0,nx,127)
			movable_items[i].y = mid(0,ny,63)
		end
	end
end

-- update found code letters
function update_code(x,y)
	for i=1,#keycode do
		if x == keycode[i].x and y == keycode[i].y then
			keycode[i].show = true
			keycode[i].sprite += 1
		end
	end
end
-->8
-- text boxes

function tb_init(voice,string) -- this function starts and defines a text box.
 reading=true -- sets reading to true when a text box has been called.
 tb={ -- table containing all properties of a text box. i like to work with tables, but you could use global variables if you preffer.
 str=string, -- the strings. remember: this is the table of strings you passed to this function when you called on _update()
 voice=voice, -- the voice. again, this was passed to this function when you called it on _update()
 i=1, -- index used to tell what string from tb.str to read.
 cur=0, -- buffer used to progressively show characters on the text box.
 char=0, -- current character to be drawn on the text box.
 x=0, -- x coordinate
 y=106, -- y coordginate
 w=127, -- text box width
 h=21, -- text box height
 col1=0, -- background color
 col2=7, -- border color
 col3=7, -- text color
 }
end

function tb_update()  -- this function handles the text box on every frame update.
 if tb.char<#tb.str[tb.i] then -- if the message has not been processed until it's last character:
     tb.cur+=0.5 -- increase the buffer. 0.5 is already max speed for this setup. if you want messages to show slower, set this to a lower number. this should not be lower than 0.1 and also should not be higher than 0.9
     if tb.cur>0.9 then -- if the buffer is larger than 0.9:
         tb.char+=1 -- set next character to be drawn.
         tb.cur=0    -- reset the buffer.
         if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice) -- play the voice sound effect.
     end
     if (btnp(5)) tb.char=#tb.str[tb.i] -- advance to the last character, to speed up the message.
 elseif btnp(5) then -- if already on the last message character and button ❎/x is pressed:
     if #tb.str>tb.i then -- if the number of strings to disay is larger than the current index (this means that there's another message to display next):
         tb.i+=1 -- increase the index, to display the next message on tb.str
         tb.cur=0 -- reset the buffer.
         tb.char=0 -- reset the character position.
     else -- if there are no more messages to display:
         reading=false -- set reading to false. this makes sure the text box isn't drawn on screen and can be used to resume normal gameplay.
     end
 end
end

function tb_draw() -- this function draws the text box.
 if reading then -- only draw the text box if reading is true, that is, if a text box has been called and tb_init() has already happened.
     rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1) -- draw the background.
     rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2) -- draw the border.
     print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3) -- draw the text.
 end
end
__gfx__
00000000cccccccccccccccc00000000000000006655556655444444000000000806660000000000000000000000000000000000000000000000000000000000
00000000ccccccccc777cccc00000000000000006556d55655444444000000000086550700000000000000000000000000000000000000000000000000000000
00000000ccccccccccc77ccc00000000000000005566d65555444444000000000006657000000000000000000000000000000000000000000000000000000000
00000000cccccccccccccccc000000000000000056d6d66555444444000000000066674000000000000000000000000000000000000000000000000000000000
00000000ccccccccccccccc7000000000000000056d666655544444400000000006d754000000000000000000000000000000000000000000000000000000000
00000000ccccccccccccc777000000000000000056d6696555444444000000000097664000000000000000000000000000000000000000000000000000000000
00000000ccccccccc77ccccc00000000000000005666d96555444444000000000099d64000000000000000000000000000000000000000000000000000000000
00000000cccccccc77cccccc00000000000000005d66666555444444000000000006d60000000000000000000000000000000000000000000000000000000000
44444444444444444454444444444444000000009999999900000000000000000b8bbbb000000000000000000000000000000000000000000000000000000000
aaa4444444444444444449544444444400000000929222290000000000000000bbbbbb8b00000000000000000000000000000000000000000000000000000000
999aaaa4444444444444444444667644000000009494949900000000000000008bb8bbbb00000000000000000000000000000000000000000000000000000000
9499999444444444449445444467666400000000944494490000000000000000bbbbb8bb00000000000000000000000000000000000000000000000000000000
99949494444444445444444446666665000000009254949900000000000000000bbbbbb000000000000000000000000000000000000000000000000000000000
44444444444444444445449456666665000000009254944900000000000000000404440000000000000000000000000000000000000000000000000000000000
44444444444444444944444455566554000000009222942900000000000000000044500000000000000000000000000000000000000000000000000000000000
44444444444444444454445445555544000000009999999900000000000000000004400000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333000000003333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
aaa33333333333333b3b33333333333300000000dddddddd33333333000000000000000000000000000000000000000000000000000000000000000000000000
999aaaa33333333333b333333366763300000000d677776d33333333000000000000000000000000000000000000000000000000000000000000000000000000
9399999333333333333333333367666300000000d767767d33333333000000000000000000000000000000000000000000000000000000000000000000000000
9993939333333333333333333666666500000000d776677d33333333000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333b3b35666666500000000d777777d33333333000000000000000000000000000000000000000000000000000000000000000000000000
333333333333333333333b335556655300000000dddddddd33333333000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333335555533000000003333333333333333000000000000000000000000000000000000000000000000000000000000000000000000
000000006d6666663333333300000000000000004444444444444444000000000000000000000000000000000000000000000000000000000000000000000000
000000006d666666333333330000000000000000dddddddd44444444000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddd6dd336676330000000000000000d677776d44444444000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666d6336766630000000000000000d767767d44444444000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666d6366666650000000000000000d776677d44444444000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddd6ddd6666666650000000000000000d777777d44444444000000000000000000000000000000000000000000000000000000000000000000000000
0000000066d66666666665530000000000000000dddddddd44444444000000000000000000000000000000000000000000000000000000000000000000000000
0000000066d666665555553300000000000000004444444444444444000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000999090000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009009900000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009009990000000000000000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000090990000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000090999000000090009900999000900099009900000009090000000000000000000000000000000000000000000000000000000000000000000000000000
00099900099000000999990999900009999909990990000099900000000000000000000000000000000000000000000000000000000000000000000000000000
00000999999000009009900990909990099009900990000990000000000000000000000000000000000000000000000000000000000000000000000000000000
00009099999900099999900990000990099009900990000990990000000000000000000000000000000000000000000000000000000000000000000000000000
00099900009900099009909990000990099909900990009999990000000000000000000000000000000000000000000000000000000000000000000000000000
00999999009999999999999999000999090099990999000000990000000000000000000000000000000000000000000000000000000000000000000000000000
09000999900900000900900090009999900000900090000999009000000000000000000000000000000000000000000000000000000000000000000000000000
09000090000055555000000000000009000000000000009009000000000000000000000000000000000000000000000000000000000000000000000000000000
09990000000559995000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000599995500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005599999550000000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005999599950000000000000000000000599500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055995559955550555000555500555555599555000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005a9a555a9a5955595555599555595955999995000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005aa95559aa5aa5aaa955a9aa55aa955aaa9a55000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000057775557775775577577755757755555577550000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005a9a555a9a5a9559a55aa5aa59a9aa555aa500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055a95559a559a55a9559a9555a9aa9555a9555000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005999599955999999559955995559995599995000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005999999555599959999999959999999999955000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005559995559955555555999995595555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000055599555950000005555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000559999550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000055595500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3131313131313101022121212121212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3112121112123101012122222222212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3111121210123102022121222022212121212121213221212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3112111211123101012121222221212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3111121211113101022121212121212132212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3131310531313101012121212121212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102011101010201222121151515152121212121212121212121210101010101010101010101010101010101010101010101000038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102021101020101212121212121152121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121211211212121212121151515152121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212112212121212121212121212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222212112212121212121212121212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222111212121212121212121212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222111111212121212121211121211121112112121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122222121212121212121212121212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212132212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121322121212121212121212121212121212121212121212121210101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000e0500e0500e0500e0500d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
