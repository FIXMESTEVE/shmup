pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--player stuff
p1={}
p1.up=false
p1.down=false
p1.left=false
p1.right=false
p1.btn1=false
p1.btn2=false
p1.lives=3
p1.score=0
p1.sprite=1
p1.w=1
p1.h=1
p1.x=0
p1.y=0
p1.fire1clk=0 --can shot when 0
p1.beam={}
p1.beam.active=false
p1.beam.ysize=0
p1.beam.xsspr=8*1 --x coordinate on the spritesheet
p1.beam.ysspr=8*4 --y coordinate on the spritesheet
p1.beam.wpx=8 --width in px (not cells)
p1.beam.x=p1.x
p1.beam.ystart=p1.y
p1.beam.ssproffsets={0,1,2,3,4,5,6,7}
p1.beam.clk=0
p1.draw=function()
    spr(p1.sprite,p1.x,p1.y,p1.w,p1.h)
end
p1.move=function()
    p1.up=btn(2)
    p1.down=btn(3)
    p1.left=btn(0)
    p1.right=btn(1)
    p1.btn1=btn(4)
    p1.btn2=btn(5)

    if(p1.up)then
        p1.y=p1.y-1
    end
    if(p1.down)then
        p1.y=p1.y+1
    end
    if(p1.left)then
        p1.x=p1.x-1
    end
    if(p1.right)then
        p1.x=p1.x+1
    end
    if(p1.btn1)then
       p1.fire1() 
    end
    if(p1.btn2)then
        p1.beam.active=true 
    else
        p1.beam.active=false
    end

    if(p1.x<0)p1.x=0
    if(p1.x+p1.w*8>128)p1.x=128-p1.w*8
    if(p1.y<0)p1.y=0
    if(p1.y+p1.h*8>128)p1.y=128-p1.h*8

    if(p1.fire1clk<0)then
        p1.fire1clk=p1.fire1clk+1
    end
end
p1.fire1=function()
    if(p1.fire1clk>-1)then
        --update the cooldown cloak
        p1.fire1clk=p1.fire1clk-10
        --center bullet
        local bw=0.5 --bullet width and height
        local bh=0.5
        local spawnx=(p1.x+8*p1.w/2)-(8*bw/2)
        local spawny=p1.y-(8*bh/2)
        local b=make_bullet(64,1,spawnx,spawny,bw,bh,0)
        b.update=function()
            local yspeed=2
            b.y=b.y-yspeed
        end
        b.draw=function()
            spr(b.sprite,b.x,b.y,b.w,b.h)
        end
        add(p1_bullets, b)
        --left bullet
        local b=make_bullet(64,1,spawnx,spawny,bw,bh,0)
        b.update=function()
            local yspeed=2
            b.y=b.y-yspeed
            local xspeed=0.45
            b.x=b.x-xspeed
        end
        b.draw=function()
            spr(b.sprite,b.x,b.y,b.w,b.h)
        end
        add(p1_bullets, b)
        --right bullet
        local b=make_bullet(64,1,spawnx,spawny,bw,bh,0)
        b.update=function()
            local yspeed=2
            b.y=b.y-yspeed
            local xspeed=0.45
            b.x=b.x+xspeed
        end
        b.draw=function()
            spr(b.sprite,b.x,b.y,b.w,b.h)
        end
        add(p1_bullets, b)
    end
end



-->8
--bullet and beams stuff
p1_bullets={}
e_bullets={}

function make_bullet(sprite,frames,x,y,w,h,rot)
    b={}
    b.sprite=sprite
    b.frames=frames
    b.x=x
    b.y=y
    b.w=w
    b.h=h
    b.rot=rot
    b.clk=0
    return b
end

function update_p1_bullets()
    for b in all(p1_bullets) do
        --bullet movement
        b.update()
        

        --enemy hit
        for e in all(enemies)do
            local bOverlap=overlap(b,e)
            if(bOverlap)then
                e.hp-=1
                --todo bullet explosion
                e.blink=true
                del(p1_bullets,b)

                if(e.hp<=0)then
                    del(enemies,e)
                end
            end
        end

        --clean gone bullet
        if(b.x<-20 or b.y<-20 or b.x>140 or b.y>140)then
            del(p1_bullets,b)
        end
    end
end

function update_e_bullets()
    for b in all(e_bullets) do
        --bullet movement
        b.update()
        if(b.x<-20 or b.y<-20 or b.x>140 or b.y>140)then
            del(e_bullets,b)
        end
    end
end

function update_p1_beam()
    p1.beam.ystart=p1.y

    if(p1.beam.active==false)then
        p1.beam.ysize=0
    else
        local bEnemyHit=false
        p1.beam.clk=p1.beam.clk+1
        if(p1.beam.clk>1)then
            p1.beam.clk=0
            local tmp=p1.beam.ssproffsets[1]
            del(p1.beam.ssproffsets,tmp)
            add(p1.beam.ssproffsets,tmp)
        end

        --enemy hit
        for e in all(enemies)do
            local b={}
            b.x=p1.x
            b.y=p1.beam.ystart-p1.beam.ysize -- this is kinda fucked because the beam is thought "upside-down"
            b.w=p1.beam.wpx/8
            b.h=p1.beam.ysize/8
            
            local bOverlap=overlap(b,e)
            if(bOverlap)then
                bEnemyHit=true
                p1.beam.ysize=p1.beam.ystart-(e.y+e.h*8)
                e.hp-=1
                --todo beam explosion thing
                e.blink=true

                if(e.hp<=0)then
                    del(enemies,e)
                end
            end
        end

        if(bEnemyHit==false)p1.beam.ysize+=2
    end
end

function draw_p1_bullets()
    for b in all(p1_bullets) do
        b.draw()
    end
end

function draw_e_bullets()
    for b in all(e_bullets) do
        b.draw()
    end
end

function draw_beam(redraw_offset)
    print("beamxsspr "..p1.beam.xsspr,64,64,6)
    print("beamysspr "..p1.beam.ysspr,64,100,6)
    print("p1.beam.ssproffsets[1] "..p1.beam.ssproffsets[1],10,30,6)

    -- sspr(p1.beam.xsspr,p1.beam.ysspr,8,8,64,64)
    local i=redraw_offset
    for of in all(p1.beam.ssproffsets)do
        i=i+1
        if(i>=p1.beam.ysize)then
            break
        end
        sspr(p1.beam.xsspr,p1.beam.ysspr+of,p1.beam.wpx
    ,1,p1.x,p1.y-i)
    end
    if(i<p1.beam.ysize)draw_beam(redraw_offset+8)
end
-->8
--init draw update utils
cpu=0
mem=0

function _init()
    make_levels()
    make_bg_stars()
    load_level(1)
end

function _draw()
    cls()
    draw_bg_stars()
    p1.draw()
    draw_enemies()
    draw_p1_bullets()
    draw_e_bullets()
    draw_beam(0)
    draw_debug()
end

function _update60()
    p1.move()
    update_p1_bullets()
    update_p1_beam()
    update_enemies()
    update_e_bullets()
    update_bg_stars()
    update_debug()
end

function draw_debug()
    print("mem "..mem,0,128-7*1,6)
    print("cpu "..cpu.."%",0,128-7*2,6)
    print("p1.x "..p1.x,50,128-7*1,6)
    print("p1.y "..p1.y,50,128-7*2,6)
    
    print("#enemies "..#enemies,50,128-7*3,6)
end

function update_debug()
    mem=stat(0)
    cpu=stat(1)/100
end

--utils
function overlap(a,b)
    --thanks @MBoffin
    local a_x1=a.x
    local a_x2=a.x+a.w*8
    local b_x1=b.x
    local b_x2=b.x+b.w*8
    local a_y1=a.y
    local a_y2=a.y+a.h*8
    local b_y1=b.y
    local b_y2=b.y+b.h*8

    if(a_x1>b_x2)return false
    if(a_y1>b_y2)return false
    if(a_x2<b_x1)return false
    if(a_y2<b_y1)return false
    
    return true
end
-->8
--enemy spawn and behavior stuff
enemies={}

function make_enemy(type,frames,x,y,w,h)
    local e={}
    e.type=type
    e.frames=frames
    e.x=x
    e.y=y
    e.w=w
    e.h=h
    e.hp=1
    e.blink=false
    e.clk=0
    --default draw function
    e.draw=function()
        spr(e.type,e.x,e.y,e.w,e.h)
    end

    if(e.type==1)then
        e.hp=20
        --this one moves down slowly
        --and shots a bullet sometimes
        e.update=function()
            e.clk+=1
            e.y+=0.05 
            if(e.clk>60)then
                e.clk=0
                --TODO: define params
                local bw=0.5 --bullet width and height
                local bh=0.5
                local spawnx=(e.x+8*e.w/2)-(8*bw/2)
                local spawny=e.y+(8*bh/2)
                local b=make_bullet(67,1,spawnx,spawny,bw,bh,0)
                b.update=function()
                    local yspd=0.5
                    b.y+=yspd
                end
                b.draw=function()
                    spr(b.sprite,b.x,b.y,b.w,b.h)
                end
                add(e_bullets,b)
            end
        end
    end

    return e
end

function update_enemies()
    for e in all(enemies)do
        e.update()
    end
end

function draw_enemies()
    for e in all(enemies)do
        if(e.blink)then
            --briefly make whole palette white to blink injured enemy
            for c=0,15 do
                pal(c,7)
            end
            e.draw()
            e.blink=false
            pal()
        else
            e.draw()
        end
    end
end
-->8
--level scripting stuff
--manually indenting make_levels so i don't get lost
levels={}

function make_levels()
    local l={}
        l.n=1
        l.prelude=3 --seconds before lvl begin, for cinematic or pause
        l.enemies={}
        local e1=make_enemy(1,1,90,10,1,1)
        add(l.enemies,e1)
        local e2=make_enemy(1,1,50,10,1,1)
        add(l.enemies,e2)
    add(levels,l)
end

function load_level(n)
    lvl=levels[n]
    enemies=lvl.enemies
end
-->8
--background stuff
bg_stars={}

function make_bg_stars()
    for x=0,127 do
        for y=0,127 do
            local r=rnd(10000)
            if(r<20)then
                local star={}
                star.x=x
                star.y=y 
                add(bg_stars, star)
            end
        end
    end
end

function draw_bg_stars()
    for s in all(bg_stars)do
        pset(s.x,s.y,7)
    end
end

function update_bg_stars()
    local respawn=0

    for s in all(bg_stars)do
        local r=0
        s.y+=1
        if(s.y>128)then
            del(bg_stars,s)
            r=s.y-128
            if(r>respawn)respawn=r
        end
    end

    for i=0,respawn do
        for x=0,127 do
            local r=rnd(10000)
            if(r<20)then
                local star={}
                star.x=x
                star.y=1-i
                add(bg_stars, star)
            end
        end
    end
end
-->8
--score stuff
-->8
--title screen stuff
__gfx__
00000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666886660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700628888260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770006f7787f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700068ffff860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700688888860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000622222260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08800000888588850088880002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8998000008888858088888802ee20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8998000008888588828282822ee20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08800000028868802020202002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888688800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000887882800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000878888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000788878880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
