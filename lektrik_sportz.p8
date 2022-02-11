pico-8 cartridge // http://www.pico-8.com
version 34
-- lektrik sportz game
-- by bikibird
-- a captain neato adventure
-- 3d functions borrowed from @mot https://www.lexaloffle.com/bbs/?tid=37982
-- modified by me to add camera orientations of up, down,
__lua__

--[[
The story so far:

captain neato floats helplessly in space. Out of nowhere Doctor Tristosy's ray gun fires: shrink! freeze! mimeo! drop!

captain neato is forced to become a pawn in the Doctor's evil game and fight his most formidable opponent, himself.  

If only he can reach home...  

]]

left,right,up,down,fire1,fire2=0,1,2,3,4,5
steady_cam_select=function(orientation)
	p3d.orientation=orientation
end
draw_player=function(n,x,y)
	local orientation=p3d.orientation
	if (orientation==up) then
		sspr((n+orientation*2)%16*8,n\16*8,16,16,x,y,10,10)
	elseif (orientation==down) then
		sspr((n+orientation*2)%16*8,n\16*8,16,16,x-8,112-y,10,10)
	elseif (orientation==left) then
		sspr((n+orientation*2)%16*8,n\16*8,16,16,118-y,x-4,10,10)
	elseif (orientation==right) then
		sspr((n+p3d.orientation*2)%16*8,n\16*8,16,16,y+2,x-12,10,10)
	end	
end

function _init()
	pal({[0]=0,1,2,3,4,5,6,7,8,9,10,131,12,13,14,139},1)
	player_x=64
	player_y=80
end
function _update()
	if (btnp(fire1)) steady_cam_select(left)
	if (btnp(fire2)) steady_cam_select(right)
	if (btnp(down) ) then
		steady_cam_select(down)
		
	elseif (btnp(up) ) then
		steady_cam_select(up)
		
	elseif (btnp(left) ) then
		steady_cam_select(left)
		
	elseif (btnp(right) ) then
		steady_cam_select(right)
		
	end
	player_x+=.05-rnd()*.05
	player_y+=.05-rnd()*05
	camera()
end
function _draw()
	cls()
	map(0,0)
	print(offx,0,0)
	print(offy,0,10)
--	camera(60,60)
	--spr3d(16,20,20,2,2,2)
	--spr3d(16,20,40,2,2,2)

	draw_player(16,player_x,player_y)
	
end
-- instant 3d+!

do
	-- parameters
	p3d=
	{
		vanish={x=64,y=0}, -- vanishing pt
		d=128,             -- screen dist in pixels
		near=1,            -- near plane z
		camyoff=0,        -- added to cam y pos
		camheight=32,       -- camera height
		orientation=up
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
		fpy=max(fpy,-1)

	 
	 -- rasterise
		local py=flr(npy)
		local orientation=p3d.orientation
		while py>=fpy do
	
	  -- floor plane intercept
			local g=(py-p3d.vanish.y)/p3d.d
			local d=-nz/g  

	  -- map coords
			local mx,my
			if (orientation==up or orientation==left) then
				mx=cx
				my=(-fy-d)/8+cy 
			end	
			if (orientation==down or orientation==right) then
				mx=cx
				--my=15.999999999999999+(fy+d)/8-cy --weird rounding error with 16
				my=16+(fy+d)/8-cy
			end
			
   
	  -- project to get left/right
			local lpx,lpy,lscale=proj(nx,-d,nz)
			local rpx,rpy,rscale=proj(nx+w*8,-d,nz)
	
	  -- delta x
			local dx=w/(rpx-lpx) 
			if (orientation==down or orientation==left) dx = -dx
	  	-- sub-pixel correction
			local l,r=flr(lpx+0.5)+1,flr(rpx+0.5)
			if (orientation==up or orientation==right)  mx+=(l-lpx)*dx
			if (orientation==down or orientation==left) mx+=16+(l-lpx)*dx
			
		-- render
			
			if (orientation==up or orientation==down) tline(l,py,r,py,mx,my,dx,0,lyr)
			if (orientation==left or orientation==right) tline(l,py,r,py,my,mx,0,dx,lyr)
			py-=1
		end 
	end 
   
   
	-- "instant 3d" wrapper functions
	local function icamera(x,y)
		local orientation=p3d.orientation
	 cam.x=(x or 0)+64
	 cam.y=(y or 0)+128+p3d.camyoff
	 --if (orientation==down) cam.y=(y or 0)-128-p3d.camyoff
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
   
   -- enable 3d mode
   go3d()
   menuitem(3,"3d",go3d)
   menuitem(2,"2d",go2d)
   go3d()
   menuitem(3,"3d",go3d)
   menuitem(2,"2d",go2d)

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
0000099999900000000009999990000000000999999000000000099999900000333333377333333377777777777777777777777777bbbbbbbbbbbb7777777777
00009aaffaa9000000009aaffaa9000000009aaaaaa9000000009aaaaaa90000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0009aaaffaaa90000009aaaffaaa90000009affffffa90000009affffffa9000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0009aaaffaaa90000009aaaffaaa90000009faaaaaaf90000009faaaaaaf9000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0009aaaffaaa90000009aaaffaaa90000009aaaaaaaa50000005aaaaaaaa9000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
00056666666650000005aaaffaaa50000009aaaaa66650000005666aaaaa9000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
00056717717650000005aaaffaaa50000009aaa661765000000567166aaa9000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
00256717717652000025daaffaad520000056667717650000005671776665000777777777777777777bbbbbbbbbbbb7733333333bbbbbbbb7777777773333337
007257777775270000725dddddd5270000005677777500000000577777650000777777777777777777bbbbbbbbbbbb7733333333bbbbbbbb7777777773333337
0077255555527700007725555552770000002555555200000000255555520000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0077222222227700007722222222770000002277222200000000222277220000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0077c222222c77000077c222222c770000000277222000000000022277200000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0000cccccccc00000000cccccccc000000000c77c11000000000011c77c00000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
00077880088770000006ccc00ccc600000000888766000000000066788800000773333337333333777777777777777777777777777777777bbbbbbbb77777777
0006660000666000000666000066600000000666600000000000000666600000773333337333333777777777777777777777777777777777bbbbbbbb77777777
00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0000daaffaad00000000daaffaad00000000daaffaad00000000daaffaad0000bb77777bbbb777bbbb77777bbbb777bbb777bbbbbbbbbbbbb7bb7bbbb7bbbbbb
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad000bb77777bbb77777bbb7777bbbb77777bb7777bbbb7bbb7bbb7b777bbb7bbbbbb
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad000bbbb7bbbbb7bbb7bbbb77bbbbb7b7b7bbbbb77bbb77777bbb7b7b7bbb77777bb
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad000bbbb7bbbbb7bbb7bbbb77bbbbb7b7b7bbbbb77bbb77777bbb7b7b7bbb77777bb
000566666666500000056666666650000005aaaffaaa50000005aaaffaaa5000bb77777bbb77777bbb7777bbbb7b7b7bb7777bbbb7bbb7bbb777b7bbb7bbbbbb
006567177176500000056717717656000065aaaffaaa50000005aaaffaaa5600bb77777bbbb777bbbb77777bbb7bbb7bb777bbbbbbbbbbbbbb7bb7bbb7bbbbbb
006567177176520000256717717656000065daaffaad52000025daaffaad5600bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0062577777757720027757777775260000625dddddd5272002725dddddd52600bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
0002255555577770077775555552200000022555555277700777255555522000bb777bbbbb7b77bb000000000000000000000000000000000000000000000000
0000222222277700007772222222000000002222222277000077222222220000b77777bbb77777bb000000000000000000000000000000000000000000000000
0000ccc222221000000122222ccc00000000ccc222221000000122222ccc0000b7bbb7bbb7b7bbbb000000000000000000000000000000000000000000000000
0000cccc1111000000001111cccc00000000cccc1111000000001111cccc0000b7bbb7bbb7b7bbbb000000000000000000000000000000000000000000000000
00778cc000000000000000000cc87700000066c000000000000000000c660000b77777bbb77777bb000000000000000000000000000000000000000000000000
0066680000000000000000000086660000066600000000000000000000666000bb777bbbb77777bb000000000000000000000000000000000000000000000000
0000000000000000000000000000000000066600000000000000000000666000bbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000999999000000000099999900000000009999990000000000999999000000000000000000000000000000000000000000000000000000000000000000000
00009aaaaaa9000000009aaaaaa9000000009aaffaa9000000009aaffaa900000000000000000000000000000000000000000000000000000000000000000000
0009affffffa90000009affffffa90000009aaaffaaa90000009aaaffaaa90000000000000000000000000000000000000000000000000000000000000000000
0009faaaaaaf90000009faaaaaaf90000009aaaffaaa90000009aaaffaaa90000000000000000000000000000000000000000000000000000000000000000000
0009aaaaaaaa50000005aaaaaaaa90000009aaaffaaa90000009aaaffaaa90000000000000000000000000000000000000000000000000000000000000000000
0009aaaaa66650000005666aaaaa900000056666666650000005aaaffaaa50000000000000000000000000000000000000000000000000000000000000000000
0009aaa661765000000567166aaa900000056717717650000005aaaffaaa50000000000000000000000000000000000000000000000000000000000000000000
0005666771765000000567177666500000256717717652000025daaffaad52000000000000000000000000000000000000000000000000000000000000000000
00005677777500000000577777650000007257777775270000725dddddd527000000000000000000000000000000000000000000000000000000000000000000
00002555555200000000255555520000007725555552770000772555555277000000000000000000000000000000000000000000000000000000000000000000
00002277222200000000222277220000007722222222770000772222222277000000000000000000000000000000000000000000000000000000000000000000
000002772220000000000222772000000077c222222c77000077c222222c77000000000000000000000000000000000000000000000000000000000000000000
00000c77c11000000000011c77c000000000cccccccc00000000cccccccc00000000000000000000000000000000000000000000000000000000000000000000
0000088876600000000006678880000000077880088770000006ccc00ccc60000000000000000000000000000000000000000000000000000000000000000000
00000666600000000000000666600000000666000066600000066600006660000000000000000000000000000000000000000000000000000000000000000000
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