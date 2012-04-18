html ->
  head ->
    script type:'text/javascript', src:'akihabara/gbox.js'
    script type:'text/javascript', src:'akihabara/iphopad.js'
    script type:'text/javascript', src:'akihabara/trigo.js'
    script type:'text/javascript', src:'akihabara/toys.js'
    script type:'text/javascript', src:'akihabara/help.js'
    script type:'text/javascript', src:'akihabara/tool.js'
    script type:'text/javascript', src:'akihabara/gamecycle.js'
    link rel:'stylesheet', href:'style.css'
    
    meta
      name:'viewport'
      content:'width:device-width; initial-scale:1.0; maximum-scale:1.0; user-scalable:0;'
  body ->
    div class:'directions', ->
      span 'MOVE: LEFT/RIGHT'
      br ''
      span 'SHOOT: Z/X'
  coffeescript ->
    frand = (min, max) -> min + Math.random()*(max-min)
    rand = (min, max) -> Math.round(frand(min, max))

    maingame = undefined

    loadResources = ->
      help.akihabaraInit
        title: 'ASTROSMASH!'
        width: 162
        height: 102
        zoom: 4

      gbox.setFps 60

      gbox.addImage 'logo', 'logo.png'
      gbox.addImage 'bg', 'bg.png'
      gbox.addImage 'bullet', 'bullet.png'

      gbox.addImage 'font', 'font.png'
      gbox.addFont
        id: 'small'
        image: 'font'
        firstletter: '!'
        tileh: 8
        tilew: 8
        tilerow: 20
        gapx: 0
        gapy: 0

      gbox.addImage "player_sprite", "player_sprite.png"

      gbox.addImage "spinner", "spinner.png"
      gbox.addTiles
        id: "spinner_tiles"
        image: "spinner"
        tileh: 8
        tilew: 8
        tilerow: 4
        gapx: 0
        gapy: 0

      gbox.addImage "spinner_big", "spinner_big.png"
      gbox.addTiles
        id: "spinner_big_tiles"
        image: "spinner_big"
        tileh: 16
        tilew: 16
        tilerow: 1
        gapx: 0
        gapy: 0

      gbox.loadAll main

    spinner_speed_mult = 1
    LEFT_WALL = 1
    RIGHT_WALL = 161
    CEILING = 1
    FLOOR = 89

    addSpinner = ->
      gbox.addObject
        group: "spinners"
        frame: 0
        init: ->
          if rand(0,1) is 0
            @tileset = 'spinner_tiles'
            @w = 8
            @h = 8
          else
            @tileset = 'spinner_big_tiles'
            @w = 16
            @h = 16
          @y = -@h
          @x = frand 0, gbox.getScreenW()
          @vx = frand(-0.25, 0.25) * spinner_speed_mult
          @fliph = @vx < 0
          @vy = frand(0.125, 1) * spinner_speed_mult
          @active = true
        initialize: ->
          @init()

        first: ->
          if @active
            @x += @vx
            @y += @vy
            
            @frame = Math.floor(@y/4) % 4

            if @x < LEFT_WALL
              @init()
            if @x + @w > RIGHT_WALL
              @init()

            if @y + @h > FLOOR
              # TODO EXPLODEEEE
              @init()

        blit: ->
          if @active
            gbox.blitTile gbox.getBufferContext(),
              tileset: @tileset
              tile: @frame
              dx: Math.round @x
              dy: Math.round @y
              fliph: @fliph

    addBullet = ->
      gbox.addObject
        group: 'bullets'
        active: false
        x: 0
        y: 0
        h: 12
        w: 2
        speed: 4
        first: ->
          if @active
            @y -= @speed
            if @y + @h < CEILING
              @active = false

        blit: ->
          if @active
            gbox.blitAll gbox.getBufferContext(), gbox.getImage('bullet'),
              dx: Math.round @x
              dy: Math.round @y

    addPlayer = ->
      gbox.addObject
        id: "player_id"
        group: "player"
        speed: 2
        bullets: []
        initialize: ->
          @w = gbox.getImage('player_sprite').width
          @h = gbox.getImage('player_sprite').height
          @x = gbox.getScreenW()/2 - @w/2
          @y = FLOOR - @h

        first: ->
          vx = 0
          if gbox.keyIsPressed 'left'
            vx -= @speed
          if gbox.keyIsPressed 'right'
            vx += @speed

          if gbox.keyIsHit('a') or gbox.keyIsHit('b')
            for bullet in @bullets
              if !bullet.active
                bullet.active = true
                bullet.x = @x + @w/2 - 2
                bullet.y = @y - 4
                break

          @x += vx

          if @x < 1
            @x = 1
          if @x > gbox.getScreenW() - @w - 1
            @x = gbox.getScreenW() - @w - 1

        blit: ->
          gbox.blitAll gbox.getBufferContext(), gbox.getImage('player_sprite'),
            dx: Math.round @x
            dy: Math.round @y

    main = ->
      gbox.setGroups ['background', 'bullets', 'spinners', 'player', 'game']
      maingame = gamecycle.createMaingame('game', 'game')
      maingame.gameMenu = -> true
 
      maingame.gameIntroAnimation = -> true

      maingame.gameTitleIntroAnimation = ->
        gbox.blitFade gbox.getBufferContext(),
          alpha:1
        gbox.blitAll gbox.getBufferContext(), gbox.getImage('logo'),
          dx:1
          dy:1

        gbox.keyIsHit 'a'

      maingame.pressStartIntroAnimation = (reset) ->
        gbox.keyIsHit 'a'

      maingame.initializeGame = ->
        player = addPlayer()
        player.bullets.push addBullet()
        player.bullets.push addBullet()
        addSpinner()

        gbox.addObject
          id: 'bg_id'
          group: 'background'
          color: 'rgb(0,0,0)'
          blit: ->
            gbox.blitFade gbox.getBufferContext(),
              color:@color
              alpha:1

            gbox.blitAll gbox.getBufferContext(), gbox.getImage('bg'),
              dx:1
              dy:1

      gbox.go()

    window.addEventListener 'load', loadResources, false
