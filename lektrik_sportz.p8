pico-8 cartridge // http://www.pico-8.com
version 34
-- lektrik sportz game
-- by bikibird
-- a captain neat-o adventure
-- 3d functions borrowed from @mot https://www.lexaloffle.com/bbs/?tid=37982
-- some functions heavily modified by me to add camera orientations for this specific game.
__lua__

--[[
The story so far:

captain neat-o floats helplessly in space. Out of nowhere Doctor Lamento's ray gun fires: freeze! shrink!  mimeo! drop!

captain neat-o is forced to become a pawn in the Doctor's evil game and fight his most formidable opponent, himself.  

if only he can reach home...  

under the doctor's control, our hero can only set his intention and await his fate as the game plays out.

Electricity!

]]

left,right,up,down,fire1,fire2=0,1,2,3,4,5
orientation =up
move,base,veer,scrimmage=0,1,2,3,4
wedge,round,block=0,1,2
ascending_x,ascending_y=4,5 
comparators=
{
	[up]=function(a,b) return a.y < b.y end,
	[down]=function(a,b) return a.y > b.y end,
	[left]=function(a,b) return a.x > b.x end,
	[right]=function(a,b) return a.x < b.x end,
	[ascending_x]=function(a,b) return a.x < b.x end,
	[ascending_y]=function(a,b) return a.x < b.x end,
}

palettes=
{
	{[0]=0,1,2,3,11,5,6,7,8,9,10,131,12,13,140,139}
}	

gs_update=
{
	intro=function()

	end,
	strategize =function()
		if btnp(fire1) then
			if mode==scrimmage then
				_update=gs_update.play
				_draw=gs_draw.play
				steady_cam_select(left)
				sfx(0)
			else
				player=player%6+1
				if player==1 then 
					go3d()
					sfx(1)
					mode=scrimmage
				end
			end	
		elseif btnp(fire2) then
			if mode==scrimmage then
				go2d()
				sfx(1)
				scrimaage=false
				mode=move
			else
				mode=(mode+1)%3
			end
		elseif btnp(down) then
			if mode==move then
				if (team[player].y<111) team[player].y+=1
			elseif mode==base then
				team[player].base=(team[player].base+1)%3	
			end	
		elseif btnp(up) then
			if mode==move then
				if (team[player].y>-11) team[player].y-=1
			elseif mode==base then
				team[player].base=(team[player].base-1)%3	
			end	
		elseif btnp(left) then
			if mode==move then
				if (team[player].x>0) team[player].x-=1
			elseif mode==veer then
				if team[player].dx==0 and team[player].dy==0 then
					team[player].angle=0 
					dx=1 --any non-zero value
				else	
					team[player].angle+=5	
				end		
				
				if (team[player].angle > 100) then
					team[player].dx,team[player].dy=0,0
					team[player].angle = 100
				else	
					team[player].dx=cos(team[player].angle/100)
					team[player].dy=sin(team[player].angle/100)
				end	
			end	
		elseif btnp(right) then
			if mode==move then
				if (team[player].x<scrimmage_line-8) team[player].x+=1
			elseif mode==veer then
				if team[player].dx==0 and team[player].dy==0 then
					team[player].angle=100 
					dx=1 --any non-zero value
				else	
					team[player].angle-=5	
				end		
				if (team[player].angle < 0) then
					team[player].dx,team[player].dy=0,0
					team[player].angle = 100
				else	
					team[player].dx=cos(team[player].angle/100)
					team[player].dy=sin(team[player].angle/100)
				end	
			end	
		end
		if mode==move then
			team[player].tick=(team[player].tick+1)%team[player].step
			if (team[player].tick==1) team[player].frame=(team[player].frame+1)%2
		end
	end,
	play=function()
		if (btnp(fire1)) steady_cam_height(1)
		if (btnp(fire2)) steady_cam_height(-1)
		if btnp(down) then
			steady_cam_select(down)
		elseif btnp(up) then
			p3d.camyoff+=1
			steady_cam_select(up)
		elseif btnp(left) then
			steady_cam_select(left)
		elseif btnp(right) then
			steady_cam_select(right)
		end
		for player in all(team) do
			player.x+=rnd(4)-2+player.dx/4
			player.y+=rnd(4)-2+player.dy/4	
		end
		sort_depth()
		steady_cam(.8)
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
		--❎🅾️⬅️➡️⬆️⬇️
		cls()
		map(0,0)
		camera(scrimmage_line-64)
		for i=1,#team do
			if i==player then
				animate_player(team[i]) 
				
			else
				spr(team[i].s+4,team[i].x,team[i].y,2,2)
			end	
		end
		local x,y,player_base,dx,dy=team[player].x,team[player].y,team[player].base,team[player].dx,team[player].dy
		if player==1 and mode!=scrimmage then
			rectfill(x-30,y+10,x+2,y+15,6)
			print("\f0OUR HERO", x-29,y+10)
		end	
		if mode==base then
			spr(player_base+18,x,y-3)
			if player_base == block then
				print("\#6\f0 block ", 172,7)
			elseif player_base==wedge then
				print("\#6\f0 push aside ", 152,7)
			else
				print("\#6\f0 sidestep ", 160,7)
			end	
		elseif mode==veer then
			local x0,y0=x,y
			local x1,y1=x0+dx*5,y0+dy*5
			rectfill(x0-6,y0-6,x0+6,y0+6,0)
			circfill(x0,y0,7,6)
			circ(x0,y0,7,0)
			line(x0,y0,x1,y1,3)
			palt(0,false)
			pset(x0,y0,0) 
			palt()
			if dx==0 and dy==0 then
				print("\#6\f0stay", x+2,y-2) 
			end	
		end	
		local neat= (player==1 and "o" or player)	
		if mode==move then

			print("\#6\f0 ❎neat-"..neat.."  🅾️mode  ⬅️➡️⬆️⬇️move ",72,1, black)
		elseif mode==base then
			print("\#6\f0 ❎neat-"..neat.."  🅾️mode      ⬆️⬇️base ",72,1, black)
		elseif mode==veer then
			print("\#6\f0 ❎neat-"..neat.."  🅾️mode      ⬅️➡️veer  ",72,1, black)
		else --mode=scrimmage
			print("\#6\f0 ❎scrimmage         🅾️strategy " ,0,1, black)
		end
	
	end
	,
	play=function()
		cls()
		map(0,0)
		for i=1,#team do
			if i==player then
				stand_player(team[i],.8,true)
			else
				stand_player(team[i],.8,false)

			end	
		end
		
	end,
	lose=function()
	end,
	win=function()
	end

}
function animate_player(player)
	if (player.frame ==1) pal(15,4)
	spr(player.s+4,player.x,player.y,2,2)
	pal(15,15) 
end
function steady_cam_select(angle)
	orientation=angle
end

function stand_player(player,scale,qb)
	local n,x,y,w,h =player.s,player.x,player.y,16,16
	if (qb and player.frame ==1) pal(15,4)
		if orientation==up then
			sspr((n+orientation*2)%16*8,n\16*8,w,h,x,y,w*scale,h*scale)
		elseif orientation==down then
			sspr((n+orientation*2)%16*8,n\16*8,w,h,288-x-w*scale,128-y-1.5*h,w*scale,h*scale)
		elseif orientation==left then
			sspr((n+orientation*2)%16*8,n\16*8,w,h,y+.25*w,288-x-1.25*h,h*scale,w*scale)
		elseif orientation==right then
			sspr((n+orientation*2)%16*8,n\16*8,w,h,288-y-1.25*w,x-.625*h,h*scale,w*scale)
		end	
	pal(15,15) 
end
function steady_cam(scale)
	local dx,dy=(steady_cam_x-team[qb].x)*.1,(steady_cam_y-team[qb].y)*.1
	if (abs(dx) >.5) steady_cam_x-=dx
	if (abs(dy) >.5) steady_cam_y-=dy
	local offset=64-16*scale/2
	if orientation==up then
		camera(steady_cam_x-offset,steady_cam_y-offset)	
	elseif orientation==down then
		camera(144-steady_cam_x+offset,steady_cam_y-offset)
	elseif orientation==left then 
		camera(steady_cam_y-offset, 144-steady_cam_x+offset)	
	elseif orientation==right then 
		camera(144-steady_cam_y+offset, steady_cam_x-offset)
	end
end
function steady_cam_height(dz)
	p3d.camheight+=dz
	if p3d.camheight>64 then
		p3d.camheight=64
	elseif p3d.camheight<5 then
		p3d.camheight=5
	end		
end
function form_scrimmage()
	team=
	{
		{x=scrimmage_line-32,y=56,s=32,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line-16,y=24,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line-16,y=40,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line-16,y=56,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line-16,y=72,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line-16,y=88,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line+16,y=16,s=96,dx=0,dy=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line+16,y=32,s=96,dx=0,dy=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line+16,y=48,s=96,dx=0,dy=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line+16,y=64,s=96,dx=0,dy=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line+16,y=80,s=96,dx=0,dy=0,base=block,tick=0,frame=0,step=5},
		{x=scrimmage_line+16,y=96,s=96,dx=0,dy=0,base=block,tick=0,frame=0,step=5},
	}
	qb=1
end
function _init()
	pal(palettes[1],1)
	scrimmage_line=136
	form_scrimmage()
	offx=56
	offy=56
	mode=0
	player=1
	-- enable 3d mode  DEFECT remove prior to publication
	menuitem(3,"3d",go3d)
	menuitem(2,"2d",go2d)

	steady_cam_x=team[qb].x
	steady_cam_y=team[qb].y
	
	--go3d()
	_update=gs_update.strategize
	_draw=gs_draw.strategize
end
function sort_depth()
	sort(team,comparators[orientation])
	for i=1,#team do
		if team[i].s==32 then 
			qb=i
			break
		end	
	end
end	
function sort(table, comparator)
    for i=1,#table do
        local j = i
		while j > 1 and not comparator(table[j-1],table[j]) do
			table[j],table[j-1] = table[j-1],table[j]
			j = j - 1
		end
    end
end

-- @mot's instant 3d+! heavily modified for this specific game.

do
	-- parameters
	p3d=
	{
		vanish={x=64,y=0}, -- vanishing pt
		d=128,             -- screen dist in pixels
		near=1,            -- near plane z
		camyoff=0,        -- added to cam y pos
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
			if orientation==up or orientation==right then
				
				my=(-fy-d)/8+cy 
			elseif orientation==left then
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
			if orientation==up or orientation==left  then
				mx= cx+(l-lpx)*dx
			else 
				mx=36-cx+(l-lpx)*dx
			end	
			
		-- render
		
			if (orientation==up or orientation==down) tline(l,py,r,py,mx,my,dx,0,lyr)
			if (orientation==left or orientation==right) tline(l,py,r,py,my,mx,0,dx,lyr)
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
	 steady_cam_select(up)
	end
   
	-- defaults
	icamera()
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
7ffffff409000000000880000088880099999998000000000000000000000000333333377333333377777777777777777777777777bbbbbbbbbbbb7777777777
f5f5f5f4009009f0008988000888888098888882000000000000000000000000333333377333333377777777777777777777777777bbbbbbbbbbbb7777777777
f555f5f40b77bb90089888808888888898888882000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
f5f5f5f40b7b3300898888888889988898888882000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
fffffff400bb3000888888888889988898888882000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
44444444000b0000088888808888888898888882000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
ccc44ccc000b0000008888000888888098888882000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
cccffccc00bb3000000880000088880082222222000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
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
0000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbbbcc777777777777cccc777777777777cccc777777777777cc
00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd00000bb777bbbbb7b77bbc76777776655665cc76777776655665cc76777776655665c
0000daaffaad00000000daaffaad00000000daaaaaad00000000daaaaaad0000b77777bbb77777bbc76700076650065cc76770006655005cc76777000655605c
000daaaffaaad000000daaaffaaad000000daffffffad000000daffffffad000b7bbb7bbb7b7bbbbc76700000000065cc76770000000005cc76777000000005c
000daaaffaaad000000daaaffaaad000000dfaaaaaafd000000dfaaaaaafd000b7bbb7bbb7b7bbbbc76700076650065cc76770006655005cc76777000655605c
000daaaffaaad000000daaaffaaad000000daaaaaaaa50000005aaaaaaaad000b77777bbb77777bbc76777776655665cc76777776655665cc76777776655665c
0005aaaffaaa50000005666666665000000daaaaa66650000005666aaaaad000bb777bbbb77777bbcc777776655555cccc777776655555cccc777776655555cc
0005aaaffaaa50000005671771765000000daaa661765000000567166aaad000bbbbbbbbbbbbbbbbcccccc0000cccccccccccc0000cccccccccccc0000cccccc
0025daaffaad52000025671771765200000566677176500000056717766650000000000800000000ccc7767666665cccccc7767666665cccccc7767666665ccc
00725dddddd527000072577777752700000056777775000000005777776500000800000800000800cc766666666665cccc766666666665cccc766666666665cc
00772555555277000077255555527700000025555552000000002555555200000080008e80088000c555777777777755c555577777777755c555557777777755
0077222222227700007722222222770000002277222200000000222277220000008e888e888e8000565557676767675556655567676767555666555767676755
0077c222222c77000077c222222c7700000002772220000000000222772000000008ee8e8ee80000565556666666665556655566666666555666555666666655
0000cccccccc00000000cccccccc000000000c77c11000000000011c77c000000008e7e7e7e80000565556666666655556655566666665555666555666666555
0006ccc00ccc600000077880088770000000088876600000000006678880000000888e777e888000060005555555500006600055555550000666000555555000
000666000066600000066600006660000000066660000000000000066660000088eee77777eee880c000cccccccc000cc0000cccccc0000cc00000cccc00000c
000000000000000000000000000000000000000000000000000000000000000000888e777e888000cc777777777777cccc777777777777cccc777777777777cc
00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd000000008e7e7e7e80000c56655667777767cc56655667777767cc56655667777767c
0000daaffaad00000000daaffaad00000000daaaaaad00000000daaaaaad00000008ee8e8ee80000c50655600077767cc50055660007767cc56005667000767c
000daaaffaaad000000daaaffaaad000000daffffffad000000daffffffad000008e888e888e8000c50000000077767cc50000000007767cc56000000000767c
000daaaffaaad000000daaaffaaad000000dfaaaaaafd000000dfaaaaaafd0000088008e80088000c50655600077767cc50055660007767cc56005667000767c
000daaaffaaad000000daaaffaaad0000005aaaaaaaad000000daaaaaaaa50000800000800000800c56655667777767cc56655667777767cc56655667777767c
00056666666650000005aaaffaaa50000005666aaaaad000000daaaaa66650000000000800000000cc555556677777cccc555556677777cccc555556677777cc
00056717717650000005aaaffaaa5000000567166aaad000000daaa6617650000000000000000000cccccc0000cccccccccccc0000cccccccccccc0000cccccc
00d5671771765d0000d5daaffaad5d0000056717766650000005666771765000000000000d0d0d00ccc5666667677cccccc5666667677cccccc5666667677ccc
007d57777775d700007d5dddddd5d70000005777776500000000567777750000000dddddd7171700cc566666666667cccc566666666667cccc566666666667cc
0077d555555d77000077d555555d77000000d555555d00000000d555555d0000ddd1111115151510557777777755555c557777777775555c557777777777555c
0077dddddddd77000077dddddddd77000000dddd77dd00000000dd77dddd00000d1111111d1d1d00557676767555666555767676765556655576767676755565
00775dddddd5770000775dddddd5770000000ddd77d0000000000d77ddd00000011105000d0d0d00556666666555666555666666665556655566666666655565
00005555555500000000555555550000000005557750000000000577555000000110005000000000555666666555666555566666665556655556666666655565
00077880088770000006555005556000000006678880000000000888766000000110000000000000000555555000666000055555550006600005555555500060
00066600006660000006660000666000000000066660000000000666600000000111000000000000c00000cccc00000cc0000cccccc0000cc000cccccccc000c
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
cc777777777777cccc777777777777cccc777777777777cccc777777777777cccc777777777777cccc777777777777cc00000000000000000000000000000000
c56655667777767cc56655667777767cc56655667777767cc76777776655665cc76777776655665cc76777776655665c00000000000000000000000000000000
c50655600077767cc50055660007767cc56005667000767cc76700076650065cc76770006655005cc76777000655605c00000000000000000000000000000000
c50000000077767cc50000000007767cc56000000000767cc76700000000065cc76770000000005cc76777000000005c00000000000000000000000000000000
c50655600077767cc50055660007767cc56005667000767cc76700076650065cc76770006655005cc76777000655605c00000000000000000000000000000000
c56655667777767cc56655667777767cc56655667777767cc76777776655665cc76777776655665cc76777776655665c00000000000000000000000000000000
cc555556677777cccc555556677777cccc555556677777cccc777776655555cccc777776655555cccc777776655555cc00000000000000000000000000000000
cccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccc00000000000000000000000000000000
ccc5666667677cccccc5666667677cccccc5666667677cccccc7767666665cccccc7767666665cccccc7767666665ccc00000000000000000000000000000000
cc566666666667cccc566666666667cccc566666666667cccc766666666665cccc766666666665cccc766666666665cc00000000000000000000000000000000
557777777755555c557777777775555c557777777777555cc555777777777755c555577777777755c55555777777775500000000000000000000000000000000
55767676755566655576767676555665557676767675556556555767676767555665556767676755566655576767675500000000000000000000000000000000
55666666655566655566666666555665556666666665556556555666666666555665556666666655566655566666665500000000000000000000000000000000
55566666655566655556666666555665555666666665556556555666666665555665556666666555566655566666655500000000000000000000000000000000
00055555500066600005555555000660000555555550006006000555555550000660005555555000066600055555500000000000000000000000000000000000
c00000cccc00000cc0000cccccc0000cc000cccccccc000cc000cccccccc000cc0000cccccc0000cc00000cccc00000c00000000000000000000000000000000
cccccccccccccccc77776cccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000
ccccccccccccccc7777776cccccccccc33bbbbbbb33333b33bbb33b3bb33bb3333bb33bb3b33bbb33b33333bbbbbbb3300000000000000000000000000000000
ccccccccccc77777777776cccccccccc333333333355333353335335335533555533553353353335333355333333333300000000000000000000000000000000
cccccccccc777777777776cccccccccc555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000000000
cccccc77777777777777667777776ccc555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000000000
ccccc77777777776766666677777766c445544555544554445554554554455444455445545545554445544555544554400000000000000000000000000000000
ccccc77777777777676666677777766c454445444454444454444544445444444444454444544445444445444454445400000000000000000000000000000000
cccccc77777777777776666767676666444444444444444444444444444444444444444444444444444444444444444400000000000000000000000000000000
ccccccccc77767677777766666666667444444444445555544444444445555555555554444444444555554444444444400000000000000000000000000000000
cccc776cccc77676767666667676767c444444444445555544444444445444455444454444444444555554444444444400000000000000000000000000000000
cc777776ccccc77767676767c7c7c7cc444444444445555555555544445444455444454444555555555554444444444400000000000000000000000000000000
c7777776cccccccc7c7c7c7ccccccccc444444444445555555555544445555555555554444555555555554444444444400000000000000000000000000000000
c6667776cccccccccccccccccccccccc444444444444444455555544444444444444444444555555444444444444444400000000000000000000000000000000
cc67666ccccccc777777cccccccccccc444444445555544444444444455554444445555444444444444555554444444400000000000000000000000000000000
cccccccccccccc77777ccccccccccccc444444445555544444445555454454444445445455554444444555554444444400000000000000000000000000000000
ccccccccccccccccc777cccccccccccc444444444444444444445555455554444445555455554444444444444444444400000000000000000000000000000000
ccccccc777ccccccccccccccc776cccc444444444444444444444444444444444444444444444444444444444444444400000000000000000000000000000000
cccccc77776ccc776ccccccc77776ccc444444444444455545555554455555544555555445555554555444444444444400000000000000000000000000000000
c777c7777776c77776cccccc77776ccc445444445554444445555554454444544544445445555554444445554444454400000000000000000000000000000000
777777777776777776cccccc67766ccc444444455554444445555554454444544544445445555554444445555444444400000000000000000000000000000000
777777777767777776ccccccc666cccc444444444444444444444444455555555555555444444444444444444444444400000000000000000000000000000000
67777777666777776cccccccccccc77c444444444455555444455544444544455444544444555444455555444444444400000000000000000000000000000000
c777777777767776c666ccccccccc77c454445444455555444444444444555555555544444444444455555444454445400000000000000000000000000000000
cc7c7c7777777777777766cccccccccc444444444444444444444444444444444444444444444444444444444444444400000000000000000000000000000000
cccccccc777777777777776ccccccccc444544444445444444445444444444444444444444454444444454444444544400000000000000000000000000000000
ccccccccc77776777777776ccccccccc444444544444444445444444444444444444444444444454444444444544444400000000000000000000000000000000
ccccc7ccc7676666676776666ccccccc445444445444445444444544444444444444444444544444454444454444454400000000000000000000000000000000
cccccc7ccc767676667666666ccccccc444444444444444444444444444444444444444444444444444444444444444400000000000000000000000000000000
ccccccccccc7c7c76666666667cccccc444444444444444444444444444444444444444444444444444444444444444400000000000000000000000000000000
c77ccccccccccccc767676767cc77ccc544444555544444445444454554444455444445545444454444444555544444500000000000000000000000000000000
77ccccccccccccccc7c7c7c7cc7777cc454555555554444455444445555554544545555554444455444445555555545400000000000000000000000000000000
7c7cccccccccccccccccccccccc77cc7555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0c1c2c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0d1d2d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000e0e1e2e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000f0f1f2f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c4c5c6c7c4c5c6c7c4c5c6c7c4c5c6c400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ebd5d6d7ebebd6eae4d7d6d7e4e6d6e400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e4e8e6e5e4d7e6e7e4e5e6e7e4e5e6e800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f4f5f6fbf4f7f6f7f4f5f6f7f4f5f6f400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200021021304611102230462110223046311023304631102430464110253046511026304661102630465110253046511024304641102430463110233046211022304621102130461110213046111021304611
000100000c0150c0050c005110350c0050c0050c00516055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000100001b3501b2501c1511d1411f141211312313127121371213b1101b3301b2301c1311d1311f131211312312127121371113b1101b3101b2101c1111d1111f111211112311127111371113b1100000000000
012000001474014731147211471516740167311672116715197401973119721197151b7401b7311b7211b7111b7101b7121b7121b7121b7151970019700197001970019700197001b7001b7001b7001b7001b700
012000001272012720127251270510720107201072510705117201172011725117051572015720157201572015722157221572215725057000570005700007000070006705087050970009700097000970009700
012000000102001020010200102506020060200602006025080200802008020080250402004020040200402004020040200402204022040250400500000000000000000000000000000000000000000000000000
__music__
04 03040544