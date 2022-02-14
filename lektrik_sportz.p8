pico-8 cartridge // http://www.pico-8.com
version 34
-- lektrik sportz game
-- by bikibird
-- a captain neato adventure
-- 3d functions borrowed from @mot https://www.lexaloffle.com/bbs/?tid=37982
-- some functions heavily modified by me to add camera orientations for this specific game.
__lua__

--[[
The story so far:

captain neato floats helplessly in space. Out of nowhere Doctor Lamento's ray gun fires: shrink! freeze! mimeo! drop!

captain neato is forced to become a pawn in the Doctor's evil game and fight his most formidable opponent, himself.  

if only he can reach home...  

]]

left,right,up,down,fire1,fire2=0,1,2,3,4,5
orientation =up



gs_update=
{
	intro=function()

	end,
	strategize =function()
	end,
	play=function()
	end,
	lose=function()
	end,
	win=function()
	end

}
gs_draw=
{
	intro=function()

	end,
	strategize =function()
	end,
	play=function()
	end,
	lose=function()
	end,
	win=function()
	end

}
steady_cam_select=function(angle)
	orientation=angle

end

stand_player=function(n,x,y,w,h,scale)
	if (orientation==up) then
		sspr((n+orientation*2)%16*8,n\16*8,w,h,x,y,w*scale,h*scale)
	elseif (orientation==down) then
		sspr((n+orientation*2)%16*8,n\16*8,w,h,288-x-w*scale,128-y-1.5*h,w*scale,h*scale)
	elseif (orientation==left) then
		sspr((n+orientation*2)%16*8,n\16*8,w,h,y+.25*w,288-x-1.25*h,h*scale,w*scale)
	elseif (orientation==right) then
		sspr((n+orientation*2)%16*8,n\16*8,w,h,288-y-1.25*w,x-.625*h,h*scale,w*scale)
	end	
end
steady_cam=function(scale)
	local dx,dy=(steady_cam_x-team[qb].x)*.1,(steady_cam_y-team[qb].y)*.1
	if (abs(dx) >.5) steady_cam_x-=dx
	if (abs(dy) >.5) steady_cam_y-=dy
	local offset=64-16*scale/2
	if (orientation==up) then
		camera(steady_cam_x-offset,steady_cam_y-offset)	
	elseif (orientation==down) then
		camera(144-steady_cam_x+offset,steady_cam_y-offset)
	elseif (orientation==left) then 
		camera(steady_cam_y-offset, 144-steady_cam_x+offset)	
	elseif (orientation==right) then 
		camera(144-steady_cam_y+offset, steady_cam_x-offset)
	end
end
steady_cam_height=function(dz)
	p3d.camheight+=dz
	if p3d.camheight>64 then
		p3d.camheight=64
	elseif p3d.camheight<5 then
		p3d.camheight=5
	end		
end
function _init()
	pal({[0]=0,1,2,3,4,5,6,7,8,9,10,131,12,13,140,139},1)
	team=
	{
		{x=96,y=64,s=32},
		{x=112,y=32,s=64},
		{x=112,y=48,s=64},
		{x=112,y=64,s=64},
		{x=112,y=80,s=64},
		{x=112,y=96,s=64}
	}
	qb=1
	offx=56
	offy=56
	-- enable 3d mode
	go3d()
	menuitem(3,"3d",go3d)
	menuitem(2,"2d",go2d)

	steady_cam_x=team[qb].x
	steady_cam_y=team[qb].y

--	_update=gs_update.intro
--	_draw=gs_draw.intro
end
function _update()
	if (btnp(fire1)) steady_cam_height(1)
	if (btnp(fire2)) steady_cam_height(-1)
	if (btnp(down) ) then
	--	p3d.camyoff-=1
	--	qb_y-=1
		steady_cam_select(down)
	elseif (btnp(up) ) then
		p3d.camyoff+=1
	--	offy+=3
	--	qb_y+=1
		steady_cam_select(up)
	elseif (btnp(left) ) then
	--	offx-=1
	--	qb_x-=1
		steady_cam_select(left)
	elseif (btnp(right) ) then
		--offx+=1
		--qb_x+=1
		steady_cam_select(right)
	end
	for player in all(team) do
		player.x+=rnd(3)-1.5
		player.y+=rnd(3)-1.5	
	end
	sort()
	steady_cam(.8)
--camera(offx,offy)
end
function _draw()
	cls()
	map(0,0)
	for player in all(team) do
		stand_player(player.s,player.x,player.y,16,16,.8)
	end	
	--print (p3d.camyoff, 0,0) print (offy, 64,0)
end
-- @mot's instant 3d+! heavily modified by bikibird for this specific game.

do
	-- parameters
	p3d=
	{
		vanish={x=64,y=0}, -- vanishing pt
		d=128,             -- screen dist in pixels
		near=1,            -- near plane z
		camyoff=32,        -- added to cam y pos
		camheight=32,       -- camera height
	}
   
	-- save 2d versions
	map2d,spr2d,sspr2d,pset2d,camera2d=map,spr,sspr,pset,camera
   
	-- 3d camera position
	local cam={x=0,y=0,z=0}
   
	-- is 3d mode enabled?
	is3d=false
   
	-- helper functions
   
	-- screen to camera space
	local function s2c(x,y,z)
	 return x-cam.x,y-cam.y,z-cam.z
	end
   
	-- perspective projection
	local function proj(x,y,z)
		if -y>=p3d.near then
			local scale=p3d.d/-y
			return x*scale+p3d.vanish.x,-z*scale+p3d.vanish.y,scale
		end
	end
   
	-- screen to projected
	local function s2p(x,y,z)
		local x,y,z=s2c(x,y,z)
		return proj(x,y,z)
	end
   
	-- 3d drawing fns
	function sspr3d(sx,sy,sw,sh,x,y,z,w,h,fx,fy)
		w=w or sw
		h=h or sh
		local px,py,scale=s2p(x,y,z)

		if(not scale)return
		local pw,ph=w*scale,h*scale
	
		-- sub pixel stuff
		local x0,x1=flr(px),flr(px+pw)
		local y0,y1=flr(py),flr(py+ph)
		sspr2d(sx,sy,sw,sh,x0,y0,x1-x0,y1-y0,fx,fy)
	end
   
	spr3d=function(n,x,y,z,w,h,fx,fy)
		if(not z)return
		-- convert to equivalent sspr() call
		w=(w or 1)*8
		h=(h or 1)*8
		local sx,sy=flr((n)%16)*8,flr((n)/16)*8
		sspr3d(sx,sy,w,h,x,y,z,w,h,fx,fy)
	end 
   
	function map3d(cx,cy,x,y,z,w,h,lyr)
		if(not h)return
		local dy=0
		-- near/far corners
		local fx,fy,fz=s2c(x,y,z)
		local nx,ny,nz=s2c(x,y+h*8,z)

		-- clip
		ny=min(ny,-p3d.near)
		if(fy>=ny)return

		-- project
		local npx,npy,nscale=proj(nx,ny,nz)
		local fpx,fpy,fscale=proj(fx,fy,fz)

		if npy<fpy then
			local tx,ty,ts=npx,npy,nscale
			npx,npy,nscale=fpx,fpy,fscale
			fpx,fpy,fscale=tx,ty,ts
		end
   
	 -- clamp
		npy=min(npy,128)
		fpy=max(fpy,0)

	 
	 -- rasterise
		local py=flr(npy)
		while py>=fpy do
	
	  -- floor plane intercept
			local g=(py-p3d.vanish.y)/p3d.d
			local d=-nz/g  

	  -- map coords
			local mx,my
			if (orientation==up or orientation==right) then
				
				my=(-fy-d)/8+cy 
			elseif (orientation==left)then
				my=(288+fy+d)/8-cy
			else  --down
				my=(128+fy+d)/8-cy
			end
   
	  -- project to get left/right
			local lpx,lpy,lscale=proj(nx,-d,nz)
			local rpx,rpy,rscale=proj(nx+w*8,-d,nz)
	
	  -- delta x
			local dx=w/(rpx-lpx) 
			if (orientation==down or orientation==right) dx = -dx
	  	-- sub-pixel correction
			local l,r=flr(lpx+0.5)+1,flr(rpx+0.5)
			if (orientation==up or orientation==left)  then
				mx= cx+(l-lpx)*dx
			else 
				mx=36-cx+(l-lpx)*dx
			end	
			
		-- render
		color(12)
		if (flr(py)==64) then
			--print (l,0,0) print(r,64,0) print(mx,0,10) print(my,64,10) print(dx,0,20)
		end
			if (orientation==up or orientation==down) tline(l,py,r,py,mx,my,dx,0,lyr)
			if (orientation==left or orientation==right) tline(l,py,r,py,my,mx,0,dx,lyr)
		--	mx+=(l-lpx)*dx

			py-=1
		end 
	end 
   
   
	-- "instant 3d" wrapper functions
	local function icamera(x,y)
		cam.x=(x or 0)+64
		cam.y=(y or 0)+128+p3d.camyoff
		cam.z=p3d.camheight
		
	end
   
	local function isspr(sx,sy,sw,sh,x,y,w,h,fx,fy)
	 z=h or sh
	 y+=z
	 sspr3d(sx,sy,sw,sh,x,y,z,w,h,fx,fy)
	end
   
	local function ispr(n,x,y,w,h,fx,fy)
	 z=(h or 1)*8
	 y+=z
	 spr3d(n,x,y,z,w,h,fx,fy)
	end
   
	local function imap(cx,cy,x,y,w,h,lyr)
	 cx=cx or 0
	 cy=cy or 0
	 x=x or 0
	 y=y or 0
	 w=w or 128
	 h=h or 64
	 map3d(cx,cy,x,y,0,w,h,lyr)
	end
   
	function go3d()
	 camera,sspr,spr,map=icamera,isspr,ispr,imap
	 camera2d()
	 is3d=true
	end
   
	function go2d()
	 map,spr,sspr,pset,camera=map2d,spr2d,sspr2d,pset2d,camera2d
	 is3d=false
	end
   
	-- defaults
	icamera()
   end
   
   --modified version of @impbox's merge sort https://www.lexaloffle.com/bbs/?tid=2477
   function sort()
    for i=1,#team do
        local j = i
		if orientation ==up then
			while j > 1 and team[j-1].y > team[j].y do
				team[j],team[j-1] = team[j-1],team[j]
				j = j - 1
			end
		elseif orientation ==down then	
			while j > 1 and team[j-1].y < team[j].y do
				team[j],team[j-1] = team[j-1],team[j]
				j = j - 1
			end
		elseif orientation ==left then	
			while j > 1 and team[j-1].x < team[j].x do
				team[j],team[j-1] = team[j-1],team[j]
				j = j - 1
			end	
		elseif orientation ==right then	
			while j > 1 and team[j-1].x > team[j].x do
				team[j],team[j-1] = team[j-1],team[j]
				j = j - 1
			end		
		end
    end
	for i=1,#team do
		if (team[i].s==32) then 
			qb=i
			break
		end	
	end
end
__gfx__
0000000033333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbbbb77777777
0000000033777733333773333777773337777733333777733777777333333333333333333333333333333333333333333333333333333333bbbbbbbb77777777
0070070037733773337773333333377333333773337737733773333333777733337777333777777333777773377333333377777333333333bbbbbbbb7bbbbbb7
0007700037733773333773333377773333377733377337733777773337733773333773333333377337733333377777733773333333333333bbbbbbbb7bbbbbb7
0007700037733773333773333773333333333773377777733333377337733773333773333377773333777333377337733377777333333333bbbbbbbb7bbbbbb7
0070070033777733337777333777777337777733333337733777773337733773333777333773333337733333377377333333377333333333bbbbbbbb7bbbbbb7
0000000033333333333333333333333333333333333333333333333333777733333773333377777333777773377773333777777333333333bbbbbbbb7bbbbbb7
0000000033333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333bbbbbbbb7bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000333333377333333377777777777777777777777777bbbbbbbbbbbb7777777777
0000000000000000000000000000000000000000000000000000000000000000333333377333333377777777777777777777777777bbbbbbbbbbbb7777777777
0000000000000000000000000000000000000000000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000777777777777777777bbbbbbbbbbbb7733333333bbbbbbbb7777777773333337
0000099999900000000009999990000000000999999000000000099999900000777777777777777777bbbbbbbbbbbb7733333333bbbbbbbb7777777773333337
00009aaffaa9000000009aaffaa9000000009aaaaaa9000000009aaaaaa90000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0009aaaffaaa90000009aaaffaaa90000009affffffa90000009affffffa9000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0009aaaffaaa90000009aaaffaaa90000009faaaaaaf90000009faaaaaaf9000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0009aaaffaaa90000009aaaffaaa90000009aaaaaaaa50000005aaaaaaaa9000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0005aaaffaaa500000056666666650000009aaaaa66650000005666aaaaa9000773333337333333777777777777777777777777777777777bbbbbbbb77777777
0005aaaffaaa500000056717717650000009aaa661765000000567166aaa9000773333337333333777777777777777777777777777777777bbbbbbbb77777777
0025daaffaad5200002567177176520000056667717650000005671776665000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00725dddddd52700007257777775270000005677777500000000577777650000bb77777bbbb777bbbb77777bbbb777bbb777bbbbbbbbbbbbb7bb7bbbb7bbbbbb
0077255555527700007725555552770000002555555200000000255555520000bb77777bbb77777bbb7777bbbb77777bb7777bbbb7bbb7bbb7b777bbb7bbbbbb
0077222222227700007722222222770000002277222200000000222277220000bbbb7bbbbb7bbb7bbbb77bbbbb7b7b7bbbbb77bbb77777bbb7b7b7bbb77777bb
0077c222222c77000077c222222c770000000277222000000000022277200000bbbb7bbbbb7bbb7bbbb77bbbbb7b7b7bbbbb77bbb77777bbb7b7b7bbb77777bb
0000cccccccc00000000cccccccc000000000c77c11000000000011c77c00000bb77777bbb77777bbb7777bbbb7b7b7bb7777bbbb7bbb7bbb777b7bbb7bbbbbb
0006ccc00ccc6000000778800887700000000888766000000000066788800000bb77777bbbb777bbbb77777bbb7bbb7bb777bbbbbbbbbbbbbb7bb7bbb7bbbbbb
0006660000666000000666000066600000000666600000000000000666600000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd00000bb777bbbbb7b77bb000000000000000000000000000000000000000000000000
0000daaffaad00000000daaffaad00000000daaaaaad00000000daaaaaad0000b77777bbb77777bb000000000000000000000000000000000000000000000000
000daaaffaaad000000daaaffaaad000000daffffffad000000daffffffad000b7bbb7bbb7b7bbbb000000000000000000000000000000000000000000000000
000daaaffaaad000000daaaffaaad000000dfaaaaaafd000000dfaaaaaafd000b7bbb7bbb7b7bbbb000000000000000000000000000000000000000000000000
000daaaffaaad000000daaaffaaad000000daaaaaaaa50000005aaaaaaaad000b77777bbb77777bb000000000000000000000000000000000000000000000000
0005aaaffaaa50000005666666665000000daaaaa66650000005666aaaaad000bb777bbbb77777bb000000000000000000000000000000000000000000000000
0005aaaffaaa50000005671771765000000daaa661765000000567166aaad000bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
0025daaffaad52000025671771765200000566677176500000056717766650000000000000000000000000000000000000000000000000000000000000000000
00725dddddd527000072577777752700000056777775000000005777776500000000099999900000000009999990000000000999999000000000099999900000
007725555552770000772555555277000000255555520000000025555552000000009aaffaa9000000009aaffaa9000000009aaaaaa9000000009aaaaaa90000
00772222222277000077222222227700000022772222000000002222772200000009aaaffaaa90000009aaaffaaa90000009affffffa90000009affffffa9000
0077c222222c77000077c222222c7700000002772220000000000222772000000009aaaffaaa90000009aaaffaaa90000009faaaaaaf90000009faaaaaaf9000
0000cccccccc00000000cccccccc000000000c77c11000000000011c77c000000009aaaffaaa90000009aaaffaaa90000009aaaaaaaa50000005aaaaaaaa9000
0006ccc00ccc600000077880088770000000088876600000000006678880000000056666666650000005aaaffaaa50000009aaaaa66650000005666aaaaa9000
000666000066600000066600006660000000066660000000000000066660000000056717717650000005aaaffaaa50000009aaa661765000000567166aaa9000
000000000000000000000000000000000000000000000000000000000000000000256717717652000025daaffaad520000056667717650000005671776665000
00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd00000007257777775270000725dddddd5270000005677777500000000577777650000
0000daaffaad00000000daaffaad00000000daaaaaad00000000daaaaaad00000077255555527700007725555552770000002555555200000000255555520000
000daaaffaaad000000daaaffaaad000000daffffffad000000daffffffad0000077222222227700007722222222770000002277222200000000222277220000
000daaaffaaad000000daaaffaaad000000dfaaaaaafd000000dfaaaaaafd0000077c222222c77000077c222222c770000000277222000000000022277200000
000daaaffaaad000000daaaffaaad0000005aaaaaaaad000000daaaaaaaa50000000cccccccc00000000cccccccc000000000c77c11000000000011c77c00000
00056666666650000005aaaffaaa50000005666aaaaad000000daaaaa666500000077880088770000006ccc00ccc600000000888766000000000066788800000
00056717717650000005aaaffaaa5000000567166aaad000000daaa6617650000006660000666000000666000066600000000666600000000000000666600000
00d5671771765d0000d5daaffaad5d00000567177666500000056667717650000000000000000000000000000000000000000000000000000000000000000000
007d57777775d700007d5dddddd5d700000057777765000000005677777500000000000000000000000000000000000000000000000000000000000000000000
0077d555555d77000077d555555d77000000d555555d00000000d555555d00000000000000000000000000000000000000000000000000000000000000000000
0077dddddddd77000077dddddddd77000000dddd77dd00000000dd77dddd00000000000000000000000000000000000000000000000000000000000000000000
00775dddddd5770000775dddddd5770000000ddd77d0000000000d77ddd000000000000000000000000000000000000000000000000000000000000000000000
00005555555500000000555555550000000005557750000000000577555000000000000000000000000000000000000000000000000000000000000000000000
00077220022770000006555005556000000006674440000000000444766000000000000000000000000000000000000000000000000000000000000000000000
00066600006660000006660000666000000000066660000000000666600000000000000000000000000000000000000000000000000000000000000000000000
00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000
0000daaffaad00000000daaffaad00000000daaffaad00000000daaffaad00000000000000000000000000000000000000000000000000000000000000000000
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad0000000000000000000000000000000000000000000000000000000000000000000
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad0000000000000000000000000000000000000000000000000000000000000000000
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad0000000000000000000000000000000000000000000000000000000000000000000
000566666666500000056666666650000005aaaffaaa50000005aaaffaaa50000000000000000000000000000000000000000000000000000000000000000000
006567177176500000056717717656000065aaaffaaa50000005aaaffaaa56000000000000000000000000000000000000000000000000000000000000000000
006567177176520000256717717656000065daaffaad52000025daaffaad56000000000000000000000000000000000000000000000000000000000000000000
0062577777757720027757777775260000625dddddd5272002725dddddd526000000000000000000000000000000000000000000000000000000000000000000
00022555555777700777755555522000000225555552777007772555555220000000000000000000000000000000000000000000000000000000000000000000
00002222222777000077722222220000000022222222770000772222222200000000000000000000000000000000000000000000000000000000000000000000
0000ccc222221000000122222ccc00000000ccc222221000000122222ccc00000000000000000000000000000000000000000000000000000000000000000000
0000cccc1111000000001111cccc00000000cccc1111000000001111cccc00000000000000000000000000000000000000000000000000000000000000000000
00778cc000000000000000000cc87700000066c000000000000000000c6600000000000000000000000000000000000000000000000000000000000000000000
00666800000000000000000000866600000666000000000000000000006660000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000666000000000000000000006660000000000000000000000000000000000000000000000000000000000000000000
__map__
1a2e2e2929292929292929292929292929292929292929292929292929292929292e2e1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3e0e0d0d07080d07090d070a0d070b0d070c0d070b0d070a0d07090d07080d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d490e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d480e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e381e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3f0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e391e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3d0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e3a1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e3b1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3d0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3c0e0d0d02010d03010d04010d05010d06010d05010d04010d03010d02010d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2d2d2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2d2d2b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
180100002c2502b6202c2502b6202a250296202825027620262502562024250236202225021620202500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001021304611102230462110223046311023304631102430464110253046511026304661102630465110253046511024304641102430463110233046211022304621102130461110213046111021304611