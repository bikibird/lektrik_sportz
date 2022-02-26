pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- lektrik sportz game
-- by bikibird
-- a captain neat-o adventure
-- 3d functions borrowed from @mot https://www.lexaloffle.com/bbs/?tid=37982
-- some functions heavily modified by me to add camera orientations for this specific game.

-- submitted to toy box jam 3 
-- just before the deadline on 2/22/2022.  
-- what were you doing 30 years ago on this date?

--[[

--the story so far--

captain neat-o floats in space,
so helpless and out of place.

his situation is dire...
suddenly there's ray gun fire!

freeze! shrink! mimeo! and drop!
doctor lamento wont stop...

pawn neato-o battles his clones!
"too formidable!" he groans.

"then i will give you teammates.
strategize while fate awaits...

i act with hostility!
engage the utility!"

honest neat-o, head crowned gold, 
propels toward home. behold...

hero, his green band flashing,
cuts a figure so dashing.

lektrik electrickery!
oh, what wicked wickery!

-- The End? --
stout hearted captain neat-o,
his story not finito, 
enlarged by experience, 
mastered fate imperious.

so, on to new adventures...
despite the past's vast treasures,
hidden futures still unfold
awesome epics to be told.
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
	{[0]=0,1,2,3,11,5,6,7,8,9,10,131,12,13,14,139},
	{[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,140,140},
	{[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
}	
months={"january","february","march","april","may","june","july","august","september","october","november","december"}
dance_moves=
{ [0]=
	66,68,64,70, 66,66,66,66, 128,130,128,130 ,128,130,128,130,
	66,68,64,64, 132,134,132,134, 132,134,132,134, 64,68,128,130
}
dance_dx=
{ [0]=
	0,0,0,0, 0,0,0,0, -1,-1,-1,-1, 1,1,1,1,
	0,0,0,0, 1,1,1,1, -1,-1,-1,-1, 0,0,0,0
}
dance_dy=
{ [0]=
	-1,-1,-1,-1, 1,1,1,1, 0,0,0,0, 0,0,0,0,
	0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
}

dance_tick=0
dance_frame=0
dance_step=4
gs_update=
{
	space=function()
		
		spaceman.tick=(spaceman.tick+1)%spaceman.step
		if (spaceman.tick==1) spaceman.frame=(spaceman.frame+1)%2
		spaceman.y+=spaceman.dy
		if (spaceman.y>49 or spaceman.y<40) spaceman.dy=-spaceman.dy
		spaceman.x+=spaceman.dx
		if (spaceman.x>48 or spaceman.x<41) spaceman.dx=-spaceman.dx
		update_stars()
		if btnp(fire2) then
			_update=gs_update.dire
			_draw=gs_draw.dire
		end
	end,
	dire=function()
		if btnp(fire2) and ray_gun.y>49 then
			draw_shrink =cocreate
			(
				function()
					local i,j,k,l,x,y
					for i=1,10 do
						sspr(16*(spaceman.frame),64,16,16,spaceman.x,spaceman.y,32,32)
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						print("\#6\f0FREEZE! SHRINK! MIMEO! AND DROP!", 1,101)	
						yield()
					end	
					blast.x=ray_gun.x-8
					blast.y=ray_gun.y
					sfx(2)
					while blast.x >spaceman.x+16 do 
						fire_blast(true,false,spaceman.x,spaceman.y)
						print("\#6\f8FREEZE!\f0 SHRINK! MIMEO! AND DROP!", 1,101)	
						yield() 
					end
					for i=2,8,.4 do
						sspr(16*(spaceman.frame),64,16,16,spaceman.x,spaceman.y,32,32)
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						size=24*i/8
						pal()
						sspr(64,40,16,16,spaceman.x+16-size/2,spaceman.y+16-size/2,size,size,true)
						pal(palettes[1],1)
						print("\#6\f8FREEZE!\f0 SHRINK! MIMEO! AND DROP!", 1,101)	
						yield()
					end
					x,y=spaceman.x,spaceman.y
					for i=1,30 do
						sspr(16,64,16,16,x,y,32,32)
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						print("\#6\f8FREEZE!\f0 SHRINK! MIMEO! AND DROP!", 1,101)		
						yield()
					end	
					blast.x=ray_gun.x-8
					blast.y=ray_gun.y
					sfx(2)
					while blast.x > x+16 do 
						fire_blast(false,false,x,y)
						print("\#6\f0FREEZE! \f8SHRINK!\f0 MIMEO! AND DROP!", 1,101)
						yield() 
					end
					for i=1,8,.4 do
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						size=24*i/8
						shrinkage=32*(9-i)/8
						sspr(16,64,16,16,x+16-shrinkage/2,y+16-shrinkage/2,shrinkage,shrinkage)
						pal()
						sspr(64,40,16,16,x+16-size/2,y+16-size/2,size,size,true)
						pal(palettes[1],1)
						print("\#6\f0FREEZE! \f8SHRINK!\f0 MIMEO! AND DROP!", 1,101)		
						yield()
					end
					for i=1,30 do
						sspr(16,64,16,16,x+16-shrinkage/2,y+16-shrinkage/2,8,8)
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						print("\#6\f0FREEZE! \f8SHRINK!\f0 MIMEO! AND DROP!", 1,101)
						yield()
					end	
					blast.x=ray_gun.x-8
					blast.y=ray_gun.y
					sfx(2)
					while blast.x > x+16 do 
						fire_blast(false,true,x,y)
						print("\#6\f0FREEZE! SHRINK! \f8MIMEO!\f0 AND DROP!", 1,101)	
						yield() 
					end
					for i=1,8,.4 do
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						size=24*i/8
						if i <2 then
							pal()
							sspr(64,40,16,16,x+16-size/2,y+16-size/2,size,size,true)
							pal(palettes[1],1)
						else
							for k=0,1 do --print 4 neatos
								for l=0,1 do
									sspr(16,64,16,16,x+12+k*8-shrinkage/2,y+12+l*8-shrinkage/2,shrinkage,shrinkage)
								end
							end
						end	
						pal()
						sspr(64,40,16,16,x+16-size/2,y+16-size/2,size,size,true)
						pal(palettes[1],1)
						print("\#6\f0FREEZE! SHRINK! \f8MIMEO!\f0 AND DROP!", 1,101)		
						yield()
					end
					for i=1,30 do
						for k=0,2 do
							for l=0,3 do
								sspr(16,64,16,16,x+8+k*8-shrinkage/2,y+4+l*8-shrinkage/2,shrinkage,shrinkage)
							end
						end	
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						print("\#6\f0FREEZE! SHRINK! \f8MIMEO!\f0 AND DROP!", 1,101)
						yield()
					end	
					local dy=1
					while y <128 do
						y+=dy
						for k=0,2 do
							for l=0,3 do
								sspr(16,64,16,16,x+8+k*8-shrinkage/2,y+4+l*8-shrinkage/2,shrinkage,shrinkage)
							end
						end	
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						print("\#6\f0FREEZE! SHRINK! MIMEO! AND \f8DROP!\f0", 1,101)
						dy*=1.2
						yield()
					end
					dropped=true
					while true do
						
						sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
						print("\#6\f0FREEZE! SHRINK! MIMEO! AND \f8DROP!\f0", 1,101)
						print("\#6\f0                                ", 1,115)
						print("\#6\f0                        NEXT ❎ ", 1,122)
						yield()
					end
				end
			)
			_update=gs_update.shrink
			_draw=gs_draw.shrink	
		end
		spaceman.tick=(spaceman.tick+1)%spaceman.step
		if (spaceman.tick==1) spaceman.frame=(spaceman.frame+1)%2
		spaceman.y+=spaceman.dy
		if (spaceman.y>49 or spaceman.y<40) spaceman.dy=-spaceman.dy
		spaceman.x+=spaceman.dx
		if (spaceman.x>48 or spaceman.x<41) spaceman.dx=-spaceman.dx
		ray_gun.y+=ray_gun.dy
		if (ray_gun.y>52) ray_gun_ready=true
		if (ray_gun_ready) then
			if (ray_gun.y>60 or (ray_gun.y<52)) ray_gun.dy=-ray_gun.dy
		end
		ray_gun.x+=ray_gun.dx
		if (ray_gun.x>98 or ray_gun.x<94) ray_gun.dx=-ray_gun.dx
		update_stars()
		
	end,
	shrink=function()
		
		spaceman.tick=(spaceman.tick+1)%spaceman.step
		if (spaceman.tick==1) spaceman.frame=(spaceman.frame+1)%2
		spaceman.y+=spaceman.dy
		if (spaceman.y>49 or spaceman.y<40) spaceman.dy=-spaceman.dy
		spaceman.x+=spaceman.dx
		if (spaceman.x>48 or spaceman.x<41) spaceman.dx=-spaceman.dx
		ray_gun.y+=ray_gun.dy
		if (ray_gun.y>49 or ray_gun.y<40) ray_gun.dy=-ray_gun.dy
		ray_gun.x+=ray_gun.dx
		if (ray_gun.x>98 or ray_gun.x<94) ray_gun.dx=-ray_gun.dx
		update_stars()
		if btnp(fire2) and dropped then
			form_scrimmage()
			--panner=cocreate(pan)
			_update=gs_update.pawn
			_draw=gs_draw.pawn

		end
	end,
	pawn=function()
	--	coresume(panner)
		if btnp(fire2) then
			_update=gs_update.teammates
			_draw=gs_draw.teammates
			drop_teammates=cocreate
			(
				function()
					i=1
					while i<=75 do
						for j=6,2,-1 do
							if team[j].bounce then
								spr(team[j].s+4,team[j].x,team[j].y*easeoutbounce(i/75),2,2)
							else
								spr(team[j].s+4,team[j].x,team[j].y,2,2)
							end	
						end	
						yield()
						i+=1
					end	
					while true do
						for i=2,6 do
							spr(team[i].s+4,team[i].x,team[i].y,2,2)
						end
						yield()
					end	
				end
			)	
		end
	end,
	teammates=function()
		if btnp(fire2) then
			scrimmage=false
			mode=move
			_update=gs_update.strategize
			_draw=gs_draw.strategize
		--	panner=cocreate(pan)
			music(-1, 300)
			music(1,500)
		end
	end,
	strategize =function()
	--	coresume(panner)
		if btnp(fire2) then
			if mode==scrimmage then
				_update=gs_update.hostility
				_draw=gs_draw.hostility
				--sfx(0)
				music(-1, 300)
				music(2,500) 
			else
				player=player%6+1
				if player==1 then
					music(-1, 300)
					arrow_message=true
					_draw=gs_draw.hostility
					_update=gs_update.hostility
				end
			end	
		elseif btnp(fire1) then
			if mode==scrimmage then
				go2d()
				sfx(1)
				scrimmage=false
				mode=move
			else
				mode=(mode+1)%3
			end
		elseif btnp(down) then
			if mode==move then
				if (team[player].y<111) team[player].y+=1
			elseif mode==base then
				team[player].base=(team[player].base+1)%3	
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
		elseif btnp(up) then
			if mode==move then
				if (team[player].y>-11) team[player].y-=1
			elseif mode==base then
				team[player].base=(team[player].base-1)%3	
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
		elseif btnp(left) then
			if mode==move then
				if (team[player].x>0) team[player].x-=1
			else
				cam_x,cam_y=camera()
				cam_x-=16
				if (cam_x < -64) cam_x=-64
			end	
		elseif btnp(right) then
			if mode==move then
				if (team[player].x<scrimmage_line-8) team[player].x+=1
			else
				cam_x,cam_y=camera()
				cam_x+=16
				if (cam_x > 216) cam_x=216
			end	
		end
		if mode==move then
			team[player].tick=(team[player].tick+1)%team[player].step
			if (team[player].tick==1) team[player].frame=(team[player].frame+1)%2
		end
	end,
	hostility=function()
		if btnp(fire2) then
			go3d()
			steady_cam_select(up)
			gold_animation=cocreate
			(
				function()
					local i=32
					while (steady_cam_x <270) do
						steady_cam(.8,i)
						i+=4
						yield()
					end
					for i=1,15 do  -- pause .5 seconds
						yield()
					end
					i=32
				--[[	while (steady_cam_x >32) do --reverse
						steady_cam(.8,270-i)
						i+=4
						yield()
					end]]
					while (steady_cam_x > scrimmage_line-24) do --reverse
						steady_cam(.8,270-i)
						i+=4
						yield()
					end
					while true do
						team[qb].x+=1
						yield()
						for i=1,3 do
							yield()
						end	
						team[qb].x-=1
						yield()
					end
					return
				end	
			)
			music(-1, 300)
			music(19,500)
			show_home = true
		
			_draw=gs_draw.gold
			_update=gs_update.gold
		elseif btnp(fire1) then
			go2d()
			music(-1, 300)
			music(1,500)
			_draw=gs_draw.strategize
			_update=gs_update.strategize
		--	panner=cocreate(pan)
		end
	end,	
	gold=function()
		team[qb].tick=(team[qb].tick+1)%team[qb].step
		if (team[qb].tick==1) team[qb].frame=(team[qb].frame+1)%2
		coresume(gold_animation)
		
		if btnp(fire2) then
			_update=gs_update.play
			_draw=gs_draw.play
			steady_cam_select(left)
			--sfx(0)
		elseif btnp(fire1) then
			go2d()
			music(-1, 300)
			music(1,500)
			mode=move
			_update=gs_update.strategize
			_draw=gs_draw.strategize
			
		--	panner=cocreate(pan)
		end	
			
	end,
	play=function()
		if (btnp(fire2)) then
			 --slo_mo= not slo_mo
		elseif btnp(left) then
			team[qb].dy=-1
			dx=0
			arrow_message=false
		elseif btnp(right) then
			team[qb].dy=1
			dx=0
			arrow_message=false
		elseif btnp(up) then
			team[qb].dx=1
			dy=0
			arrow_message=false
		elseif btnp(down) then
			team[qb].dx=-1
			dy=0
			arrow_message=false	
		end
		team[qb].tick=(team[qb].tick+1)%team[qb].step
		if (team[qb].tick==1) team[qb].frame=(team[qb].frame+1)%2
		frame=(frame+1)%4
		--[[if frame!=1 and slo_mo then
			return
		end]]
		steady_cam(.8)
		shake()
		sort_depth()
		if team[qb].x >270 then
			music(-1)
			steady_cam_select(up)
			steady_cam(.8,270)
			scrimmage_line=team[qb].x
			downs+=1
			embiggen_count=1
			_update=gs_update.embiggen
			_draw=gs_draw.embiggen
		end

	end,
	tackled=function()
		if (btnp(fire2)) then
			go2d()
			form_scrimmage()
			camera(team[qb].x-51,0)	
			scrimmage=false
			mode=move
			_update=gs_update.strategize
			_draw=gs_draw.strategize
			music(-1, 300)
			music(1,500)
		--	panner=cocreate(pan)
		end
	end,
	out_of_bounds=function()
		if (btnp(fire2)) then
			go2d()
			form_scrimmage()
			camera(team[qb].x-51,0)	
			scrimmage=false
			mode=move
			reload()
			_init()
		end
	end,
	embiggen=function()
		local x,y=team[qb].x,team[qb].y
		local dx,dy
		local i
		if embiggen_count<12 then
			for i=1,#team do
				if i != qb and not team[i].hide then
					dx=x - team[i].x 
					dy=y - team[i].y
					if abs(dx) >3 or abs(dy) >3 then
						team[i].x+=sgn(dx)*3
						team[i].y+=sgn(dy)*3
					else
						team[qb].x=x- team[qb].heart*1.6 --16*.1
						team[qb].y=y- team[qb].heart*1.6 --16*.1
						team[qb].heart *= 1.1
						team[i].hide=true
						if stat(46)==-1 then
							music(18)
						end	
						embiggen_count+=1
					end
				end
			end
		else
			_update=gs_update.epilog
			_draw=gs_draw.epilog
		end	
	end,
	epilog=function()
		if btnp(fire2) then
			music(8,1000)
			_update=gs_update.fly
			_draw=gs_draw.fly
		end
	end,
	fly=function()
		if team[qb].x <1000 then
			team[qb].x+=2
			team[qb].y+=2
		
		else
			
			go2d()
			_update=gs_update.hover
			_draw=gs_draw.drop
			camera(0,0)
			team[qb].x,team[qb].y=32,0
			win_offset=0
			music(-1)
			return
		end
		steady_cam(.8,team[qb].x, team[qb].y)
	end,
	hover=function()
		team[qb].hover+=1
		if team[qb].hover>20 then
			_update=gs_update.drop
			
		end
	end,
	drop=function()
		if team[qb].y <128 then
			
			team[qb].y+=3
		
		else
			team[qb].y=16
			_update=gs_update.win
			_draw=gs_draw.win
		
		end
		camera(0,0)
		--steady_cam(.8,team[qb].x+12.8*team[qb].heart/2)
		
	end,
	win=function()
		if btnp(fire2) then
			ray_gun.y=1
			drop_ray_gun=cocreate(
				function()
					for i =1, 100 do
						ray_gun.y=121*easeoutbounce(i/100)
						yield()
					end
					for i=1,10 do
						yield()
					end
					for i=0,5 do
						for j=1,2 do
							yield()
						end
						robot.s=160+i*2
						yield()
					end	
					for i=5,3,-1 do
						for j=1,2 do
							yield()
						end
						robot.s=160+i*2
						yield()
					end
					for i =1, 20 do
						ray_gun.y= 121 + 10*easeoutbounce(i/20)
						yield()
					end
					for i=2,0,-1 do
						for j=1,2 do
							yield()
						end
						robot.s=160+i*2
						yield()
					end	
					music(14)
				end
			)
			
			ray_gun.x=96
			_update=gs_update.stats
			_draw=gs_draw.stats
		end
		if win_offset <64 then
			win_offset+=2
		end	
		if team[qb].y < 120 then
			team[qb].y+=1
		end	

		camera(0,win_offset)
	end,
	stats=function()
		coresume(drop_ray_gun)
		music_num=stat(46)
		if music_num > -1 then
			note_num=stat(50)
			if resync and note_num==0 then
				dance_tick=0
				dance_frame=0
			elseif note_num> 0 then
				resync=true	
			end
		
			dance_tick=(dance_tick+1)%dance_step
			if (dance_tick==1) dance_frame=(dance_frame+1)%32
			dance_x+=dance_dx[dance_frame]
			team[qb].y+=dance_dy[dance_frame]
		end	
		if btnp(fire2) then
			reload()
			_init()
		end
	end
	
}
gs_draw=
{
	space=function()
		cls()
		draw_stars()
		sspr(16*(spaceman.frame),64,16,16,spaceman.x,spaceman.y,32,32)
		print("\#6\f0CAPTAIN NEAT-O FLOATS IN SPACE, ", 1,101)
		print("\#6\f0SO HELPLESS AND OUT OF PLACE.   " , 1,108)
		print("\#6\f0                                ", 1,115)
		print("\#6\f0                        NEXT ❎ ", 1,122)
	
	end,
	dire=function()
		cls()
		draw_stars()
		sspr(16*(spaceman.frame),64,16,16,spaceman.x,spaceman.y,32,32)
		sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
		
		print("\#6\f0HIS SITUATION IS DIRE...        ", 1,101)
		print("\#6\f0SUDDENLY THERE'S RAY GUN FIRE!  " , 1,108)
		print("\#6\f0                                ", 1,115)
		if ray_gun.y<49 then
			print("\#6\f0                                ", 1,122)
		else	
			print("\#6\f0                        NEXT ❎ ", 1,122)
		end	
	end,
	shrink=function()
		cls()
		draw_stars()
		rectfill(0,101,128,128,8)
		--print("\#6\f0                                ", 1,122)
		coresume(draw_shrink)
		print("\#6\f0DOCTOR LAMENTO WONT STOP...     " , 1,108)
		--print("\#6\f0                                ", 1,115)
		
	end,	
	pawn=function()
		camera(scrimmage_line-48,0)
		cls()
		map(0,0)
		animate_player(team[qb])

		for i=7,#team do
				spr(team[i].s+4,team[i].x,team[i].y,2,2)
		end
		local x,y=team[qb].x,team[qb].y
		print("\#6\f0 OUR", x-14,y+4)--x-14
		print("\#6\f0HERO", x-14,y+10)
		cam_x,cam_y=camera()
		print("\#6\f0PAWN NEATO-O BATTLES HIS CLONES!", 1,101)
		print('\#6\ff"too formidable!" '.."\#6\f0HE GROANS.    " , 1,108)
		print("\#6\f0                                ", 1,115)
		print("\#6\f0                        NEXT ❎ ", 1,122)
		camera(cam_x,cam_y)
	end,
	teammates=function()
		camera(scrimmage_line-48,0)
		cls()
		map(0,0)
		animate_player(team[qb])
		coresume(drop_teammates)
		for i=7,#team do
			spr(team[i].s+4,team[i].x,team[i].y,2,2)
		end
		local x,y=team[qb].x,team[qb].y
		print("\#6\f0 OUR", x-14,y+4)--x-14
		print("\#6\f0HERO", x-14,y+10)
		cam_x,cam_y=camera()
		print('\#6\f8"THEN I WILL GIVE YOU TEAMMATES.', 1,101)
		print('\#6\f8STRATEGIZE WHILE FATE AWAITS."  ' , 1,108)
		print("\#6\f0                                ", 1,115)
		print("\#6\f0                        NEXT ❎ ", 1,122)
		camera(cam_x,cam_y)
	end,
	strategize =function()
		camera(scrimmage_line-48,0)
		cls()
		map(0,0)
		for i=1,#team do
			if i==player then
				animate_player(team[i]) 
				
			else
				spr(team[i].s+4,team[i].x,team[i].y,2,2)
			end	
		end
		local x,y,player_base,dx,dy=team[player].x,team[player].y,team[player].base,team[player].dx,team[player].dy
		if player==1 then
			print("\#6\f0 OUR", x-14,y+4)--x-14 team[qb].x-51
			print("\#6\f0HERO", x-14,y+10)
		end	
		if mode==base then
			
			spr(player_base+18,x,y-3)
			cam_x,cam_y=camera()
			if player_base == block then
				print("\#6\f0 block ", 100,7)
			elseif player_base==wedge then
				print("\#6\f0 push aside ", 80,7)
			else
				print("\#6\f0 sidestep ", 88,7)
			end	
			camera(cam_x,cam_y)
		elseif mode==veer then
			draw_bearing(x,y,dx,dy)
		end	
		local neat=team[player].name	
		cam_x,cam_y=camera()
		if mode==move then
			print("\#6\f0 ❎"..neat.."  🅾️mode  ⬅️➡️⬆️⬇️move ",0,1, black)
		elseif mode==base then
			print("\#6\f0 ❎"..neat.."  🅾️mode      ⬆️⬇️base ",0,1, black)
			print("\#6\f0 ⬅️ pan ➡️ ", 42,122)
			--print("\#6\f0 "..cam_x, 1,122)
		elseif mode==veer then
			print("\#6\f0 ❎"..neat.."  🅾️mode      ⬆️⬇️veer  ",0,1, black)
			print("\#6\f0 ⬅️ pan ➡️ ", 42,122)
		end
		camera(cam_x,camy)
	end,
	hostility=function()
		cls()
		map(0,0)
		for i=1,#team do
			spr(team[i].s+4,team[i].x,team[i].y,2,2)
		end
		cam_x,cam_y=camera()
		print("\#6\f0 🅾️ BACK                        ", 1,101)
		print('\#6\f8        "i act with hostility!  ', 1,108)
		print('\#6\f8          engage the utility!"  ' , 1,115)
		print("\#6\f0                        NEXT ❎ ", 1,122)
		camera(cam_x,cam_y)
	end,
	gold=function()
		cls()
		map(0,0)
		for i=1,#team do
			if i==player then
				stand_player(team[i],.8,true)
			else
				stand_player(team[i],.8,false)
			end	
		end
		--cam_x,cam_y=camera()
		print("\#6\f0 🅾️ BACK                         " ,1,1, black)
		print("\#6\f0HONEST NEAT-O,                   ",1,101)
		print("\#6\f0HEAD CROWNED",58,101)
		print("\#6\f0GOLD,",109,101)
		print("\#6\f0PROPELS TOWARD HOME. BEHOLD...   ",1,108)
		print("\#6\f0HERO, HIS GREEN BAND FLASHING,   ", 1,115)
		print("\#6\f0CUTS A FIGURE SO DASHING. ❎     " , 1,122)
		--camera(cam_x,cam_y)
	end,
	play=function()
		draw_players()
		--draw_bearing(117,10,team[qb].dx,team[qb].dy,true)
		--if (slo_mo) print("\#6\f0 slo-mo ", 1,1)
		--print("\#6\f0 "..team[qb].x, 1,10)
		--print("\#6\f0 "..team[qb].y, 1,20)
		if (arrow_message)print("\#6\f0       ⬆️⬇️⬅️➡️ to exert will      ", 1,122)	
	end,
	tackled=function()
		draw_players()
		print("\#6\f0 down #"..downs.."  yardage gain: "..yardage_gained.."         ", 1,1)
		print("\#6\f0 ",1,122)
		print("\#6\f0TACKLED BY "..tackled_by.." STRATEGIZE ❎        " , 2,122)	
		
	end,
	out_of_bounds=function()
		draw_players()
		cam_x,cam_y=camera2d()
		print("\#6\f0 down #"..downs.."  yardage gain: "..yardage_gained.."          ", 1,1)
		print("\#6\f0                                 ", 1,101)
		print("\#6\f0TRYING TO ESCAPE THE HORDE,    ", 2,101)
		print("\#6\f0                                 ", 1,108)
		print("\#6\f0POOR NEAT-O FALLS OFF THE BOARD", 2,108)
		palt(0,false)
		pset(126,112,0)
		palt()
		print("\#6\f0                                  " , 1,115)
		print("\#6\f0                                  ", 1,122)
		print("\#6\f0out of bounds!        replay ❎ " , 2,122)
		camera2d(cam_x,cam_y)
	end,
	embiggen=function()
		cls()
		map(0,0)
		for i=1,#team do
			if i==qb then
				stand_player(team[i],.8,true,true)
			else
				stand_player(team[i],.8,false,true)
			end	
		end
	end,
	epilog=function()
		cls()
		map(0,0)
		for i=1,#team do
			if i==qb then
				stand_player(team[i],.8,true,true)
			else
				stand_player(team[i],.8,false,true)
			end	
		end
		print("\#6\f0 STOUT HEARTED CAPTAIN NEAT-O,  ", 1,101)
		print("\#6\f0 HIS STORY NOT FINITO,          ", 1,108)
		print("\#6\f0 ENLARGED BY EXPERIENCE,        " , 1,115)
		print("\#6\f0 MASTERED FATE IMPERIOUS.    ❎ ", 1,122)
	end,
	fly=function()
		cls()
		map(0,0)
		stand_player(team[qb],.8,true,false,true)
	end,
	drop=function()
		cls()
		sspr(16,16,16,16,team[qb].x-8,team[qb].y,80,80)
	end,
	win=function()
		pal()
		cls()
		map(72,0)
		pal(palettes[2],1)
		spr(173,64,team[qb].y,2,2)
		palt(0,false) palt(12,true)
		spr(robot.s,robot.x,robot.y,2,2)
		palt()
		pal()
		rectfill(0,164,127,191,6)
		
		print("\#6\f0SO, ON TO NEW ADVENTURES...    ", 2,165)
		print("\#6\f0                                ", 2,172)
		print("\#6\f0DESPITE                        ", 2,172)
		print("\#6\f0THE", 32,172)
		print("\#6\f0PAST'", 47,172)
		print("\#6\f0S", 66,172)
		print("\#6\f0VAST", 72,172)
		print("\#6\f0TREASURES,", 89,172)

		print("\#6\f0HIDDEN FUTURES STILL UNFOLD    " , 2,179)
		print("\#6\f0AWESOME EPICS TO BE TOLD.   ❎ ", 2,186)
	end,
	stats=function()
		pal()
		cls()
		map(72,0)
		pal(palettes[2],1)
		
		palt(0,false) palt(12,true)
		spr(robot.s,robot.x,robot.y,2,2)
		palt()
		spr(142,ray_gun.x,ray_gun.y,2,1)
		pal()
		print("\^pTHE END?",32,96,7)
		if stat(46)>0 then --dancing
			pal(12,1) pal(15,3)
			spr(dance_moves[dance_frame],dance_x,team[qb].y,2,2)
			pal(12,12) pal(15,15)
		else -- standing
			spr(173,64,team[qb].y,2,2)
		end
		
		print("\#6\f0 "..sys_date.."                " , 0,165)
		print("\#6\f0 home safe after "..downs.." downs            ", 0,172)
		print("\#6\f0                                ", 0,179)
		print("\#6\f0                      replay ❎ ", 0,186)
		--print("\#6\f8 "..dance_frame.." "..dance_tick.." "..dance_step.." "..dance_moves[dance_frame]..stat(46),1,186)
	end,
}
function _init()
	
	sys_date=months[stat(91)].." "..stat(92)..", "..stat(90)
	pal(palettes[1],1)
	scrimmage_line=64
	offx=56
	offy=56
	mode=0
	player=1  --for strategize
	qb=1
	--menuitem(3,"3d",go3d)
	--menuitem(2,"2d",go2d)
	ray_gun_ready=false
	dropped=false
	robot={s=160, x=32,y=122,dx=0,dy=0,tick=0,frame=0,step=5}
	spaceman={x=46,y=46,dx=.25,dy=-.25,tick=0,frame=0,step=10}
	ray_gun={x=96,y=-8,dx=.5,dy=.5}
	blast={s=21,tick=0,frame=0,step=5}
	init_stars()
	camera(scrimmage_line-64)
	_update=gs_update.space
	_draw=gs_draw.space
	will=up
	nudge_y=sin(.02)
	nudge_x=cos(.02)
	dance_x=64
	slo_mo=false
	frame=0
	downs=0
	yardage=0
	cam_x,cam_y=0,0
	music(2)
end
function animate_player(player)
	if (player.frame ==1) pal(15,4)
	spr(player.s+4,player.x,player.y,2,2)
	pal(15,15) 
end
function steady_cam_select(angle)
	orientation=angle
end
function stand_player(player,scale,qb,embiggen,fly)
	local n,x,y,w,h =player.s,player.x,player.y,16,16
	if (player.hide) return
	if (qb and player.frame ==1) then
		pal(15,4)
	end	
	if orientation==up then
		if embiggen then
			if qb then
				sspr(48,16,w,h,x,y,w*scale*player.heart,h*scale*player.heart)
			else	
				sspr(32,16,w,h,x,y,w*scale,h*scale)
			end
		elseif fly then
			sspr(64,64,w,h,x,y,w*scale*player.heart,h*scale*player.heart)	
		else
			sspr((n+orientation*2)%16*8,n\16*8,w,h,x,y,w*scale,h*scale)
		end	
	elseif orientation==down then
		sspr((n+orientation*2)%16*8,n\16*8,w,h,288-x-w*scale,128-y-1.5*h,w*scale,h*scale)
	elseif orientation==left then
		sspr((n+orientation*2)%16*8,n\16*8,w,h,y+.25*w,288-x-1.25*h,h*scale,w*scale)
	elseif orientation==right then
		sspr((n+orientation*2)%16*8,n\16*8,w,h,288-y-1.25*w,x-.625*h,h*scale,w*scale)
	end	
	pal(15,15)
end
function steady_cam(scale,x,y)
	local dx
	if y then 
		camera(x-64+12.8*team[qb].heart/2,y-64+12.8*team[qb].heart/2)
		return
	end
	if x then
		dx=(steady_cam_x-x)*.1 
	else
		dx=(steady_cam_x-team[qb].x)*.1
	end		
	local dy=(steady_cam_y-team[qb].y)*.1
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

function init_scrimmage(players)
end
function form_scrimmage(players)
	team=
	{
		{x=scrimmage_line-32,y=56,s=32,dx=0,dy=0,angle=0,base=block,tick=0,frame=0,step=5,name="neat-o",heart=.8,hover=0},
		{x=scrimmage_line-16,y=24,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5,name="doppel",bounce=true},
		{x=scrimmage_line-16,y=40,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5,name="zeroxa",bounce=true},
		{x=scrimmage_line-16,y=56,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5,name="mimeo ",bounce=true},
		{x=scrimmage_line-16,y=72,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5,name="aclona",bounce=true},
		{x=scrimmage_line-16,y=88,s=64,dx=1,dy=0,angle=0,base=block,tick=0,frame=0,step=5,name="nate-o",bounce=true}
	}
	local i,dx,dy,x,y,base,target,a,b,c
	srand(stat(90)*365+stat(91)*31+stat(92))  -- different strategy everyday, but same every play.
	for i=1, 6 do
		x=scrimmage_line+6+rnd(90)
		y=16*i+8-rnd(8)
		dx=-rnd(.5)
		dy=rnd(1)-.5
		base=rnd({1,2,3})
		target=rnd({2,3,4,5,6})
		a=team[target].x-x
		b=team[target].y-y
		c=sqrt(a*a+b*b)
		add(team,{x=x,y=y,s=96,dx=a/c,dy=b/c,base=base,tick=0,frame=0,step=5})
	end
	team[7].name="ersass"
	team[8].name="shaddo"
	team[9].name="simul"
	team[10].name="eko"
	team[11].name="shammo"
	team[12].name="teona"
	team[rnd({7,8,9,10,11,12})].sacker=true
	team[rnd({7,8,9,10,11,12})].sacker=true
	team[rnd({7,8,9,10,11,12})].sacker=true
	qb=1
	steady_cam_x=team[qb].x
	steady_cam_y=team[qb].y
end

function shake()
	local base_a,base_b,dx,dy
	for a=1, #team do
		base_a=team[a].base
			if team[a].sacker then  -- sacker is slightly faster than qb because allowed diagonal moves.
				delta_x=team[a].x-team[qb].x
				delta_y=team[a].x-team[qb].y
				if delta_x<0 then  
					team[a].dx=1
				else
					team[a].dx=-1
				end	
				if delta_y<0 then
					team[a].dy=1
				else
					team[a].dy=-1
				end	
			end	
		for b=1, #team do
			base_b=team[b].base
			distance =
			{
				x=team[a].x+rnd(1)-.5+team[a].dx/64-team[b].x,
				y=team[a].y+rnd(1)-.5+team[a].dy/64-team[b].y
			}
			if distance.x>=-3 and distance.x<=3 and distance.y>=-8 and distance.y<=8 then
				--hit
				if (a!=b) then  --if not self
					if (a==qb and team[b].s==96) then --tackled
						sfx(2)
						tackled_by=team[b].name
						yardage_gained=(team[qb].x-(scrimmage_line))/2.4 --10 yards= 24 pixels
						downs+=1
						if team[qb].x< 24 then
							scrimmage_line=24
							team[qb].x=24
						else	
							scrimmage_line=team[qb].x
						end	
						if scrimmage_line < 260 then
							_update=gs_update.tackled
							_draw=gs_draw.tackled
						end	

					else -- Trig facts: sin(a+b)=sin(a)cos(b)+cos(a)sin(b) cos(a+b)=cos(a)cos(b)-sin(a)sin(b)
						if (base_a==round) then
							if distance.y <0 then
								team[a].dx=team[a].dx*nudge_x+team[a].dy*nudge_y
								team[a].dy=team[a].dy*nudge_x-team[a].dx*nudge_y
							else
								team[a].dx=team[a].dx*nudge_x-team[a].dy*nudge_y
								team[a].dy=team[a].dy*nudge_x+team[a].dx*nudge_y
							end
							--change angle slightly dx, dy only no actual movement this turn.
						elseif (base_a==wedge)then	--pushes opponent asside
							if distance.y <0 then
								team[b].dx=team[b].dx*nudge_x+team[b].dy*nudge_y
								team[b].dy=team[b].dy*nudge_x-team[b].dx*nudge_y
							else
								team[b].dx=team[b].dx*nudge_x-team[b].dy*nudge_y
								team[b].dy=team[b].dy*nudge_x+team[b].dx*nudge_y
							end
						end  --block does not move
					end
				else  --path is clear
					team[a].x=distance.x+team[b].x
					team[a].y=distance.y+team[b].y
				end
			else
				team[a].x=distance.x+team[b].x
				team[a].y=distance.y+team[b].y
			end		
			if a==qb and (team[a].y<-14 or team[a].y>125 or team[a].x <-14) then --out_of_bounds

				sfx(2)
				yardage_gained=(team[qb].x-(scrimmage_line))/2.4
				if team[qb].x< 24 then
					scrimmage_line=24
					team[qb].x=24
				else	
					scrimmage_line=team[qb].x
				end	
				if scrimmage_line < 260 then
					downs+=1
					_update=gs_update.out_of_bounds
					_draw=gs_draw.out_of_bounds
				end
			else
			end		
		end 

	end
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
function init_stars()
	stars={}
	for i=0,3 do
		for j=0,6 do
			local star={x=flr(rnd(30))+(30*i)+4,y=flr(rnd(14))+(14*j)+4,c=6}
			add(stars,star)		
		end
	end
end
function update_stars()
	if star==nil then
		star=flr(rnd(8)+1)
		twinkle_time=time()
		twinkle_wait=rnd(3)+.5
	end	
	if time()-twinkle_time>twinkle_wait then
		if stars[star].c==6 then
			stars[star].c=0
		else
			stars[star].c=6
			star=nil
		end	
	end	
end	
function draw_stars()
	for star in all(stars) do
		pset(star.x,star.y,star.c)
	end
end	
function fire_blast(animate,shrink,x,y)
	cls()
	draw_stars()
	if animate then
		sspr(16*(spaceman.frame),64,16,16,x,y,32,32)
	elseif shrink then
		sspr(16,64,16,16,x+16-shrinkage/2,y+16-shrinkage/2,8,8)
	else
		sspr(16,64,16,16,x,y,32,32)
	end	
	sspr(64,56,16,8,ray_gun.x,ray_gun.y,16,8,true)
	pal()
	spr(blast.s+blast.frame,blast.x,blast.y)
	pal(palettes[1],1)
	blast.x-=2
	blast.tick=(blast.tick+1)%blast.step
	if (blast.tick==1) blast.frame=(blast.frame+1)%2
end
function draw_players()
	cls()
	map(0,0)
	for i=1,#team do
		if i==qb then
			stand_player(team[i],.8,true)
		else
			stand_player(team[i],.8,false)

		end	
	end
end		
function draw_bearing(x,y,dx,dy,rotate)
	local x0,y0=x,y
	local x1,y1=x0+dx*5,y0+dy*5
	if (not rotate) rectfill(x0-6,y0-6,x0+6,y0+6,0)
	circfill(x0,y0,7,6)
	circ(x0,y0,7,0)
	if rotate then
		line(x0,y0,x0+y1-y0,y0-x1+x0,3)
	else
		line(x0,y0,x1,y1,3)
	end	
	palt(0,false)
	pset(x0,y0,0) 
	palt()
	if dx==0 and dy==0 then
		print("\#6\f0stay", x+2,y-2) 
	end	
end	
function pan()
	local cam_x,cam_y=camera()
	
	while cam_x < 216 do
		cam_x+=4
		camera(cam_x,cam_y)
		yield()
	end
	while cam_x> scrimmage_line-48 do
		cam_x-=4
		camera(cam_x,cam_y)
		yield()
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
	function easeoutbounce(t)
		local n1=7.5625
		local d1=2.75
	
		if (t<1/d1) then
			return n1*t*t;
		elseif(t<2/d1) then
			t-=1.5/d1
			return n1*t*t+.75;
		elseif(t<2.5/d1) then
			t-=2.25/d1
			return n1*t*t+.9375;
		else
			t-=2.625/d1
			return n1*t*t+.984375;
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
f5f5f5f40b7b3300898888888889988898888882000880000002200000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
fffffff400bb3000888888888889988898888882008ee8000028820000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
44444444000b0000088888808888888898888882000880000002200000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
ccc44ccc000b0000008888000888888098888882000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
cccffccc00bb3000000880000088880082222222000000000000000000000000333333377333333377bbbbbbbbbbbb773333333377bbbbbbbbbbbb777bbbbbb7
0000000000000000000000000000000000000000000000000000000000000000777777777777777777bbbbbbbbbbbb7733333333bbbbbbbb7777777773333337
0000099999900000000009999990000000000999999000000000099999900000777777777777777777bbbbbbbbbbbb7733333333bbbbbbbb7777777773333337
00009aaffaa9000000009aaffaa9000000009aaaaaa9000000009aaaaaa90000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0009aaaffaaa90000009aaaffaaa90000009affffffa90000009affffffa9000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0009aaaffaaa90000009aaaffaaa90000009faaaaaaf90000009faaaaaaf9000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0009aaaffaaa90000009aaaffaaa90000009aaaaaaaa50000005aaaaaaaa9000773333337333333777bbbbbbbbbbbb7733333333bbbbbbbbbbbbbbbb73333337
0009aaaffaaa500000056666666650000009aaaaa66650000005666aaaaa9000773333337333333777777777777777777777777777777777bbbbbbbb77777777
0009aaaffaaa500000056717717650000009aaa661765000000567166aaa9000773333337333333777777777777777777777777777777777bbbbbbbb77777777
00259aaffaa95200002567177176520000056667717650000005671776665000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0072599999952700007257777775270000005677777500000000577777650000bb77777bbbb777bbbb77777bbbb777bbb777bbbbbbbbbbbbb7bb7bbbb7bbbbbb
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
0000d44aa44d00000000d44aa44d00000000d444444d00000000d444444d00000008ee8e8ee80000c50655600077767cc50055660007767cc56005667000767c
000d444aa444d000000d444aa444d000000d4aaaaaa4d000000d4aaaaaa4d000008e888e888e8000c50000000077767cc50000000007767cc56000000000767c
000d444aa444d000000d444aa444d000000da444444ad000000da444444ad0000088008e80088000c50655600077767cc50055660007767cc56005667000767c
000d444aa444d000000d444aa444d000000544444444d000000d4444444450000800000800000800c56655667777767cc56655667777767cc56655667777767c
00056666666650000005444aa4445000000566644444d000000d4444466650000000000800000000cc555556677777cccc555556677777cccc555556677777cc
00056717717650000005444aa4445000000567166444d000000d4446617650000000000000000000cccccc0000cccccccccccc0000cccccccccccc0000cccccc
00d5671771765d0000d5d44aa44d5d0000056717766650000005666771765000000000000d0d0d00ccc5666667677cccccc5666667677cccccc5666667677ccc
007d57777775d700007d5dddddd5d70000005777776500000000567777750000000dddddd7171700cc566666666667cccc566666666667cccc566666666667cc
0077d555555d77000077d555555d77000000d555555d00000000d555555d0000ddd1111115151510557777777755555c557777777775555c557777777777555c
0077dddddddd77000077dddddddd77000000dddd77dd00000000dd77dddd00000d1111111d1d1d00557676767555666555767676765556655576767676755565
00775dddddd5770000775dddddd5770000000ddd77d0000000000d77ddd00000011105000d0d0d00556666666555666555666666665556655566666666655565
00005555555500000000555555550000000005557750000000000577555000000110005000000000555666666555666555566666665556655556666666655565
00077880088770000006555005556000000006678880000000000888766000000110000000000000000555555000666000055555550006600005555555500060
00066600006660000006660000666000000000066660000000000666600000000111000000000000c00000cccc00000cc0000cccccc0000cc000cccccccc000c
00000dddddd0000000000dddddd0000000000dddddd0000000000dddddd000000000099999900000000000000d0d0d0000000008000000000000000000001110
0000daaffaad00000000daaffaad00000000daaffaad00000000daaffaad000000009aaaaaa90000000dddddd717170008000008000008000000000000000110
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad0000009affffffa9000ddd11111151515100080008e800880000000000005000110
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad0000009faaaaaaf90000d1111111d1d1d00008e888e888e800000d0d0d000501110
000daaaffaaad000000daaaffaaad000000daaaffaaad000000daaaffaaad0000009aaaaaaaa5000011105000d0d0d000008ee8e8ee8000000d1d1d1111111d0
000566666666500000056666666650000005aaaffaaa50000005aaaffaaa50000009aaaaa666500001100050000000000008e7e7e7e800000151515111111ddd
006567177176500000056717717656000065aaaffaaa50000005aaaffaaa56000009aaa661765000011000000000000000888e777e8880000071717dddddd000
006567177176520000256717717656000065daaffaad52000025daaffaad56000005666771765000011100000000000088eee77777eee88000d0d0d000000000
0062577777757720027757777775260000625dddddd5272002725dddddd526000066567777750000000000000000000000888e777e88800000d0d0d000000000
0002255555577770077775555552200000022555555277700777255555522000006625555550077000000000000000000008e7e7e7e800000071717dddddd000
0000222222277700007772222222000000002222222277000077222222220000000022222777777000000000000000000008ee8e8ee800000151515111111ddd
0000ccc222221000000122222ccc00000000ccc222221000000122222ccc000000002222227770000000000000000000008e888e888e800000d1d1d1111111d0
0000cccc1111000000001111cccc00000000cccc1111000000001111cccc0000068c22222210000000000000000000000088008e8008800000d0d0d000501110
00778cc000000000000000000cc87700000066c000000000000000000c660000068ccccc11100000000000000000000008000008000008000000000005000110
0066680000000000000000000086660000066600000000000000000000666000068ccc0000000000000000000000000000000008000000000000000000000110
00000000000000000000000000000000000666000000000000000000006660000670000000000000000000000000000000000000000000000000000000001110
cc777777777777cccc777777777777cccc777777777777cccc777777777777cccc777777777777cccc777777777777cc00049aa9000000000000000000000000
c56655667777767cc56655667777767cc56655667777767cc76777776655665cc76777776655665cc76777776655665c0049aa94000009999990000000000000
c50655600077767cc50055660007767cc56005667000767cc76700076650065cc76770006655005cc76777000655605c049aa94000009aa33aa9000000000000
c50000000077767cc50000000007767cc56000000000767cc76700000000065cc76770000000005cc76777000000005c49a77a940009aaa33aaa900000000000
c50655600077767cc50055660007767cc56005667000767cc76700076650065cc76770006655005cc76777000655605c49a77a940009aaa33aaa900000000000
c56655667777767cc56655667777767cc56655667777767cc76777776655665cc76777776655665cc76777776655665c049aa9400009aaa33aaa900000000000
cc555556677777cccc555556677777cccc555556677777cccc777776655555cccc777776655555cccc777776655555cc49aa9400000566666666500000000000
cccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccc9aa94000000567177176500000000000
ccc5666667677cccccc5666667677cccccc5666667677cccccc7767666665cccccc7767666665cccccc7767666665ccc00000000002567177176520000000000
cc566666666667cccc566666666667cccc566666666667cccc766666666665cccc766666666665cccc766666666665cc00000000007257777775270000000000
557777777755555c557777777775555c557777777777555cc555777777777755c555577777777755c55555777777775500000000007725555552770000000000
55767676755566655576767676555665557676767675556556555767676767555665556767676755566655576767675500000000007722222222770000000000
55666666655566655566666666555665556666666665556556555666666666555665556666666655566655566666665500000000007712222221770000000000
55566666655566655556666666555665555666666665556556555666666665555665556666666555566655566666655500000000000011111111000000000000
00055555500066600005555555000660000555555550006006000555555550000660005555555000066600055555500000000000000778800887700000000000
c00000cccc00000cc0000cccccc0000cc000cccccccc000cc000cccccccc000cc0000cccccc0000cc00000cccc00000c00000000000666000066600000000000
cccccccccccccccc77776cccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccc000000000000000000000000
ccccccccccccccc7777776cccccccccc33bbbbbbb33333b33bbb33b3bb33bb3333bb33bb3b33bbb33b33333bbbbbbb33cccccccc000000000000000000000000
ccccccccccc77777777776cccccccccc3333333333553333533353353355335555335533533533353333553333333333cccccccc000000000000000000000000
cccccccccc777777777776cccccccccc5555555555555555555555555555555555555555555555555555555555555555cccccccc000000000000000000000000
cccccc77777777777777667777776ccc5555555555555555555555555555555555555555555555555555555555555555cccccccc000000000000000000000000
ccccc77777777776766666677777766c4455445555445544455545545544554444554455455455544455445555445544cccccccc000000000000000000000000
ccccc77777777777676666677777766c4544454444544444544445444454444444444544445444454444454444544454cccccccc000000000000000000000000
cccccc777777777777766667676766664444444444444444444444444444444444444444444444444444444444444444cccccccc000000000000000000000000
ccccccccc777676777777666666666674444444444455555444444444455555555555544444444445555544444444444ccccccccccc67777cccccccccccccccc
cccc776cccc77676767666667676767c4444444444455555444444444454444554444544444444445555544444444444cccccccccc6777777ccccccccccccccc
cc777776ccccc77767676767c7c7c7cc4444444444455555555555444454444554444544445555555555544444444444cccccccccc67777777777ccccccccccc
c7777776cccccccc7c7c7c7ccccccccc4444444444455555555555444455555555555544445555555555544444444444cccccccccc677777777777cccccccccc
c6667776cccccccccccccccccccccccc4444444444444444555555444444444444444444445555554444444444444444ccc67777776677777777777777cccccc
cc67666ccccccc777777cccccccccccc4444444455555444444444444555544444455554444444444445555544444444c66777777666666767777777777ccccc
cccccccccccccc77777ccccccccccccc4444444455555444444455554544544444454454555544444445555544444444c66777777666667677777777777ccccc
ccccccccccccccccc777cccccccccccc444444444444444444445555455554444445555455554444444444444444444466667676766667777777777777cccccc
ccccccc777ccccccccccccccc776cccc444444444444444444444444444444444444444444444444444444444444444476666666666777777676777ccccccccc
cccccc77776ccc776ccccccc77776ccc4444444444444555455555544555555445555554455555545554444444444444c76767676666676767677cccc677cccc
c777c7777776c77776cccccc77776ccc4454444455544444455555544544445445444454455555544444455544444544cc7c7c7c76767676777ccccc677777cc
777777777776777776cccccc67766ccc4444444555544444455555544544445445444454455555544444455554444444ccccccccc7c7c7c7cccccccc6777777c
777777777767777776ccccccc666cccc4444444444444444444444444555555555555554444444444444444444444444cccccccccccccccccccccccc6777666c
67777777666777776cccccccccccc77c4444444444555554444555444445444554445444445554444555554444444444cccccccccccc777777ccccccc66676cc
c777777777767776c666ccccccccc77c4544454444555554444444444445555555555444444444444555554444544454ccccccccccccc77777cccccccccccccc
cc7c7c7777777777777766cccccccccc4444444444444444444444444444444444444444444444444444444444444444cccccccccccc777ccccccccccccccccc
cccccccc777777777777776ccccccccc444544444445444444445444444444444444444444454444444454444444544400000000000000000000000000000000
ccccccccc77776777777776ccccccccc444444544444444445444444444444444444444444444454444444444544444400000000000000000000000000000000
ccccc7ccc7676666676776666ccccccc445444445444445444444544444444444444444444544444454444454444454400000000000000000000000000000000
cccccc7ccc767676667666666ccccccc444444444444444444444444444444444444444444444444444444444444444400000000000000000000000000000000
ccccccccccc7c7c76666666667cccccc444444444444444444444444444444444444444444444444444444444444444400000000000000000000000000000000
c77ccccccccccccc767676767cc77ccc544444555544444445444454554444455444445545444454444444555544444500000000000000000000000000000000
77ccccccccccccccc7c7c7c7cc7777cc454555555554444455444445555554544545555554444455444445555555545400000000000000000000000000000000
7c7cccccccccccccccccccccccc77cc7555555555555555555555555555555555555555555555555555555555555555500000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000007jjjjjjjjjjjjjjjjjjjjjjj7j7jj77j7j7jj77jjjjjjjjjjjjjjjjjjjjjjjj700000000000000000000000000
00000000000000000000000000000000000073333333333333333333333333333333333333333333333333333333333333333337000000000000000000000000
00000000000000000000000000000000000333333333333333333737333333333333333333333333333377733333333333333333370000000000000000000000
00000000000000000000000000000000073333333333333333333773333333333333333333333333333333333333333333333333333770000000000000000000
00000000000000000000000000000007333333333333333333337333333333333333333333333333333333377333333333333333333333700000000000000000
00000000000000000000000000000033333333333333333333377773333333333333333333333333333333337773333333333333333333337000000000000000
00000000000000000000000000007333333333333333333333333333333333333333333333333333333333333333333333333333333333333370000000000000
00000000000000000000000000733333333333333333333333733733333333333333333333333333333333333333333333333333333333333333770000000000
00000000000000000000000007333333333333333333333333333333333333333333333333333333333333333337737333333333333333333333333700000000
00000000000000000000000733333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337000000
00000000000000000000077777733333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337777777000
00000000000000000000733333333333333333333333333377773333333333333333333333333333333333333333333777333333333333333333333333333770
00000000000000000073333333333333333333333333333733373333333333333333333333333333333333333333333733733333333333333333333333333333
00000000000000007777777333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337777
0000000000ddddddd333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
000000000daarrraad333333333333333333333333333ddddddd333333333333333333333333333333333333333333333333773333333333333dddddddd33333
000000000daarrraad333333333333333333333333333ddddddd333333333333333333333333333333333333333333333333777773333333333dddddddd33333
00000000daaarrraaad333333333333333333333333ddbbaaabbdd33333333333333333333dddddddd33333333333333333337337333333333dbbbaabbbd3333
00000000daaarrraaad33333333333333333333333dbbbbaaabbbbd3333333333333333333dddddddd3333333333333333333377737333333dbbbbaabbbbd333
00000077daaarrraaad33333333333333333333333dbbbbaaabbbbd333333333333333333daaarraaadd33333333333333333333333333333dddddddddbbd333
000077335aaarrraaa533333333333333333333333dbbbbaaabbbbd3333333333333333ddaaaarraaaaad3333333333333333333333333333dddddddddbbd333
000777775aaarrraaa533333333333333333333333dbbbbaaabbbbd3333333333333333ddaaaarraaaaad333333333333333333333333333daaarrraaadbd333
077333335aaarrraaa5333333333333333333333335666666666665333ddddddddd3333ddaaaarraaaaad3333333333333333333337777ddaaaarrraaaadd333
733333225daarrraad52233333333333333333333356671777176653ddaaarrraaadddddddddddddddaad3333333333333333333333773ddaaaarrraaaadd333
7777777725ddddddd527777777777777777773333d5667177717665dddaaarrraaaddbbbaaabbbddbbdd57777777777777777777777333ddaaaarrraaaadd777
333333777255555552777333333333333333333777d55777777755ddaaaaarrraaaddbbbaaabbbddbbdd53333333333333333333333333ddaaaarrraaaadddd3
333333777222222222777333333333333333337737d55777777755ddaaaaarrraadbbbbbaaabbbbbdbbbd3333333333333333333333333ddaaaarrraaaadd773
333333777c2222222c7773333333333333333337777dd5555555dd7daaaaarrraadbbbbbaaabbbbbdbbbd233333333333333333333333355aaaarrraaaa55773
733333333ccccccccc3333333333333333333333377ddddddddddd7daaaaarrraadbbbbbaaabbbbbdbbbd733333333333333333333333355aaaarrraaaa55773
333333333ccccccccc333333333333333333333337755ddddddd5575aaaaarrraadbbbbbaaabbbbbdbbbd733333333333333333333333355aaaarrraaaa55773
333333336ccc333ccc63333333333333333333333335555555555535aaaaarrraa5666666666666656665733333333333333333333333255daaarrraaad55273
33333333666333336663333333333333333333333335555555555535aaaaarrraa56666666666666566699999999999933333333333337225ddddddddd522733
33333333333333333333333333333333333333333377788333887775aaaaarrraa56671177711766576699999999999933333333333337772555555555277733
33333333333333333333333333333333337733337766663333366225ddaaarrraa566711777117665769aaaarrrraaaa99333333333337772555555555277733
3333333333333333333333333333333333733733733333333333377255dddddddd566711777117665dd9aaaarrrraaaa99333333333337772222222222277773
3333333333333333333333333333333337777777733333333333377255dddddd77d5577777777755d99aaaaarrrraaaaaa93333333333777c222222222c77777
777777777777777777777777777773333333333333777777777777772255555577d5577777777755d99aaaaarrrraaaaaa97777777777777c222222222c77733
7777777777777777777777777777333333333333337777777777777722222222777dd555555555dd799aaaaarrrraaaaaa97777777777777ccccccccccc33333
3333333333333333333333333333333777777773333333333333377722222222777ddddddddddddd799aaaaarrrraaaaaa93333333333366cccc333cccc66777
33333333333333333333333333333377333337733333333333333777cc222222777ddddddddddddd799aaaaarrrraaaaaa93333333333366cccc333cccc66773
33333333333333333333333333333377333337733333333333333333cccccccc77755ddddddddd55755aaaaarrrraaaaaa533333333333666663333366666377
33333333333333333333333333333337777733333333333333333333ccccccccccc5555555555555555aaaaarrrraaaaaa533333333333333333333333333337
33333333333333333333333333333333333333333333333333333336ccccc333ccc5555555555555555aaaaarrrraaaaaa533333333333333333333333333333
33333333333333333333333333333333333333333333333333333336666333333377788878888877755aaaaarrrraaaaaa533333333333333333333333333333
33333333333333333333333333333333333333333333333333333336666333333366666666333662255daaaarrrraaaadd522333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333366666666333662255daaaarrrraaaadd522333333333333333333333333333
333333333333333333333333333333333333333333333333333333333333333333333333333333377225dddddddddddd55277333333333333333333333333333
333333333333333333333333333333333333333333333333333333333333333333333333333333377225dddddddddddd55277333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333337777255555555555522777333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333337777255555555555522777333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333337777222222222222222777333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333337777222222222222222777333333333333333333333333333
33333333333333333333337777733337733333333333333333333333333333333333333333333337777c222222222222cc777333333333333333333333333333
33333333333333333333337777773377333333333333333333333333333333333333333333333333333ccccccccccccccc333333333333333333333333333333
33333333333333333333377337773377333333333333333333333333333333333333333333333333333ccccccccccccccc333333333333333333333333333333
33333333333333333333777337733777333333333333333333333333333333333333333333333333366ccccc3333cccccc633333333333333333333333333333
33333333333333333333773377777773333333333333333333333333333333333333333333333333366ccccc3333cccccc633333333333333333333333333333
33333333333333333337773377777773333333333333333333333333333333333333333333333333366666333333336666633333333333333333333333333333
33333333333333333337733333773333333333333333333333333333333333333333333333333333366666333333336666633333333333333333333333333333
77777777777773333333333333333333777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777773333333333333333333777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777733333333333333333337777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
33333333333333333337777777333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333337777777777773333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333377777777777733333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333333333337773333333777333333333333333333333333333333dddddddddddddddddddd333333333333333333333333333333333333333333333333333
333333333333337733333333773333333333333333333333333333333dddddddddddddddddddd333333333333333333333333333333333333333333333333333
333333333333377733333337773333333333333333333333333333333dddddddddddddddddddd333333333333333333333333333333333333333333333333333
333333333333777777777777773333333333333333333333333333333dddddddddddddddddddd333333333333333333333333333333333333333333333333333
333333333333777777777777733333333333333333333333333333dddaaaaaaarrrrrraaaaaaaddd333333333333333333333333333333333333333333333333
333333333333337777777733333333333333333333333333333333dddaaaaaaarrrrrraaaaaaaddd333333333333333333333333333333333333333333333333
333333333333377777777333333333333333333333333333333333dddaaaaaaarrrrrraaaaaaaddd333333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333dddaaaaaaaaaarrrrrraaaaaaaaaaddd333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333555aaaaaaaaaarrrrrraaaaaaaaaa555333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333555aaaaaaaaaarrrrrraaaaaaaaaa555333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333555aaaaaaaaaarrrrrraaaaaaaaaa555333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333555aaaaaaaaaarrrrrraaaaaaaaaa555333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333555aaaaaaaaaarrrrrraaaaaaaaaa555333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333555aaaaaaaaaarrrrrraaaaaaaaaa555333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333222555dddaaaaaaarrrrrraaaaaaaddd555222233333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333222555dddaaaaaaarrrrrraaaaaaaddd555222233333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333222555dddaaaaaaarrrrrraaaaaaaddd555222233333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333777222555dddddddddddddddddddd555222777733333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333777222555dddddddddddddddddddd555222777733333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333777222555dddddddddddddddddddd555222777733333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333777222555dddddddddddddddddddd555222777733333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333377777722255555555555555555555222777777733333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333377777722255555555555555555555222777777733333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333377777722255555555555555555555222777777733333333333333333333333333333333333333333
33333777333333333333333333333333333333333333333377777722222222222222222222222222777777733333333333333333333333333333333333333333
33337777333333333333333333333333333333333333333377777722222222222222222222222222777777733333333333333333333333333333333333333333
33377773333333333333333333333333333333333333333377777722222222222222222222222222777777733333333333333333333333333333333333333333
333777733333333333333333333333333333333333333333777777ccc22222222222222222222ccc777777733333333333333333333333333333333333333333
777777777733333333333333333333333333333333333333777777ccc22222222222222222222ccc777777733333333333333333333333333333333333333333
777777777333333333333333333333333333333333333333777777ccc22222222222222222222ccc777777733333333333333333333333333333333333333333
777777777333333333333333333333333333333333333333333333cccccccccccccccccccccccccc333333333333333333333333333333333333333333333333
777777773333333333333333333333333333333333333333333333cccccccccccccccccccccccccc333333333333333333333333333333333333333333333333
777777773333333333333333333333333333333333333333333333cccccccccccccccccccccccccc333333333333333333333333333333333333333333333333
777777733333333333333333333333333333333333333333333333cccccccccccccccccccccccccc333333333333333333333333333333333333333333333333
777777733333333333333333333333333333333333333333333666cccccccccc333333cccccccccc666333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333666cccccccccc333333cccccccccc666333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333666cccccccccc333333cccccccccc666333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333366666666663333333333333666666666333333333333333333333333333333333333333333333

__map__
1a2e2e2929292929292929292929292929292929292929292929292929292929292e2e1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3e0e0d0d07080d07090d070a0d070b0d070c0d070b0d070a0d07090d07080d0d0e0e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d490e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e000000000000008c8d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d480e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e381e000000000000009c9d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3f0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e391e00000000000000acad0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3d0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e3a1e00000000000000bcbd000000000000000000000000000000000000000000000000000000ccc0c1c2c3cccccccccccce0e1e2e3cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e3b1e000000000000000000000000000000000000000000000000000000000000000000000000ccd0d1d2d3ccdcdddedfccf0f1f2f3cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3d0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccecedeeefcccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
1d3c0e0d0d02010d03010d04010d05010d06010d05010d04010d03010d02010d0d0e0e1e000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
1d0e0e0d0d18190d18190d18190d18190d18190d18190d18190d18190d18190d0d0e0e1e000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2d2d2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2d2d2b000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008c8d0000000000000000000000000000000000000000000000cc10cccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0c1c2c3000000000000000000000000000000000000000000000000000000000000000000000000000000009c9d0000000000000000000000000000000000000000000000c4c5c6c7c4c5c6c7c4c5c6c7c4cac7c800000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0d1d2d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ebd5d6d7ebebd6eae4d7d6d7e4dae8d800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000e0e1e2e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e4e8e6e5e4d7e6e7e4e5e6e7e4ead7ea00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000f0f1f2f300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f4f5f6fbf4f7f6f7f4f5f6f7f4faf9fa00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011e00000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011e00000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
011e000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011e00000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
011e000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011e00000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
000c07001075513755187451c7451f735247252b71512755157551a7451e74521735267252d71514755177551c7452074523735287252f7153472500000000000000000000000000000000000000000000000000
000c0700000001072513725187251c7251f725247252b70512725157251a7251e72521725267252d70514725177251c7252072523725287252f72534705000001ca051ca051ca051ca051ca051ca051ca051ca05
010e00002042524325293252c4251d3252032524425293252c3251d4252032524325294252c3251d3252042524325293252c4251d3252032524412293252c3251d4252032524325294252c3251d3252042524325
010e00000c0430544505435054450543505445054350544501435014450143501445014350144501435014450c0430344503435034450343503445034350344500435004450043500445004350c0430043500445
010e0000184251d3252032524425356152c325184251d32520325184251d3252c325356151d32520325184251d32520325184251d32535615244251d32520325184251d3252c3252442535615203251842529325
010e00000c043014350144501435014450143520415014350c04320415014350143501435014451d415204150c043014350144501435014450143501445014350c04300445004350044500435004350043500445
010e0000182151d3251d3251d325356151d325304201d3252e4202e4201d3251d325356151d325292202c2202c2201d3251d3251d325356151d3252e4201d325294201b3251b32527420356151b3251b3251b325
010e00000c043014450143501425034450343503425034150c04305445054350542508445084350842508415356150a4450a4350a425356150c4350c4250c4150c04300445004450044500445004450043500435
010e000029420294112941229415356152b4202b4112b4122d4202d4112d4122d4123561530420304123041232411324103241032412354113541235412294163541635416294162941635416354162941629416
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 03040544
03 06424344
01 07084344
00 07094344
00 07084344
00 07094344
00 0a0b4344
02 070c4344
01 0d0e4344
00 0d0e4344
00 0f104344
02 0f104344
00 0a0b4344
02 070c4344
01 11124344
00 11124344
00 13144344
02 15164344
04 17184344
01 191a4344
00 191a4344
00 1b1a4344
00 1b1a4344
00 1c1d4344
00 1c1d4344
00 1c1d4344
00 1a1d4344
02 1e1f4344