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
        title: 'BRASTROSMASH!'
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

      gbox.addImage 'font_green', 'font_green.png'
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

    LEFT_WALL = 1
    RIGHT_WALL = 161
    CEILING = 1
    FLOOR = 89

    _score = 0
    score_peak = 0

    score = (change) ->
      _score += change
      if _score > score_peak
        score_peak = _score

    BIG_ROCK_SHOT_SCORE = 10
    SMALL_ROCK_SHOT_SCORE = 20
    BIG_SPINNER_SHOT_SCORE = 40
    SMALL_SPINNER_SHOT_SCORE = 80
    MISSILE_SHOT_SCORE = 50
    UFO_SHOT_SCORE = 100
    BIG_ROCK_LAND_SCORE = -5
    SMALL_ROCK_LAND_SCORE = -10
    BIG_SPINNER_LAND_SCORE = 0
    SMALL_SPINNER_LAND_SCORE = 0
    MISSILE_LAND_SCORE = 0
    DEATH_SCORE = -100

    FRAME_LENGTH_MS = 17

    X1_RULES =
      max_rocks: 6
      max_spinners: 2
      max_missiles: 1
      max_ufos: 0
      
      max_rock_spawn: 3
      min_rock_rest: 0
      max_rock_rest: 3000

      max_spinner_spawn: 1
      min_spinner_rest: 2000
      max_spinner_rest: 15000
                                     
      min_missile_rest: 15000
      max_missile_rest: 60000
      
      min_ufo_rest: 2000
      max_ufo_rest: 15000

      ufo_speed: 0.5
      
      allow_missile_while_ufo: false

    X2_RULES =
      max_rocks: 6
      max_spinners: 2
      max_missiles: 1
      max_ufos: 0
          
      max_rock_spawn: 3
      min_rock_rest: 0
      max_rock_rest: 3000
      
      max_spinner_spawn: 2
      min_spinner_rest: 1500
      max_spinner_rest: 12000
          
      min_missile_rest: 10000
      max_missile_rest: 45000
                  
      min_ufo_rest: 2000
      max_ufo_rest: 15000
      
      ufo_speed: 0.5
      
      allow_missile_while_ufo: false

    X3_RULES =
      max_rocks: 6
      max_spinners: 3
      max_missiles: 1
      max_ufos : 0

      max_rock_spawn: 3
      min_rock_rest: 0
      max_rock_rest: 2200

      max_spinner_spawn: 3
      min_spinner_rest: 1000
      max_spinner_rest: 12000

      min_missile_rest: 8000
      max_missile_rest: 30000

      min_ufo_rest: 2000
      max_ufo_rest: 15000

      ufo_speed: 0.5

      allow_missile_while_ufo: false

    X4_RULES =
      max_rocks: 8
      max_spinners: 4
      max_missiles: 1
      max_ufos: 1

      max_rock_spawn: 3
      min_rock_rest: 0
      max_rock_rest: 1800

      max_spinner_spawn: 3
      min_spinner_rest: 500
      max_spinner_rest: 12000

      min_missile_rest: 8000
      max_missile_rest: 30000

      min_ufo_rest: 2000
      max_ufo_rest: 15000

      ufo_speed: 0.75

      allow_missile_while_ufo: false
    X5_RULES =
      max_rocks: 10
      max_spinners: 5
      max_missiles: 2
      max_ufos: 1

      max_rock_spawn: 3
      min_rock_rest: 0
      max_rock_rest: 1000

      max_spinner_spawn: 3
      min_spinner_rest: 250
      max_spinner_rest: 12000

      min_missile_rest: 8000
      max_missile_rest: 30000

      min_ufo_rest: 2000
      max_ufo_rest: 15000

      ufo_speed: 0.75

      allow_missile_while_ufo: false

    X6_RULES =
      max_rocks: 12
      max_spinners: 4
      max_missiles: 2
      max_ufos: 1

      max_rock_spawn: 3
      min_rock_rest: 0
      max_rock_rest: 800

      max_spinner_spawn: 4
      min_spinner_rest: 0
      max_spinner_rest: 12000

      min_missile_rest: 8000
      max_missile_rest: 20000

      min_ufo_rest: 2000
      max_ufo_rest: 15000

      ufo_speed: 0.85

      allow_missile_while_ufo: false
    
    RULES = [
      X1_RULES
      X2_RULES
      X3_RULES
      X4_RULES
      X5_RULES
      X6_RULES
    ]

    multiplyer = 1
    next_spinner = 0
    spinner_count = 0

    gameLogicInit = ->
      next_spinner = rand rules.min_spinner_rest, rules.max_spinner_rest

    gameLogic = ->
      rules = RULES[multiplyer-1]
      if next_spinner <= 0 and spinner_count < rules.max_spinners
        to_spawn = Math.min(
          rand(0,rules.max_spinner_spawn) + 1,
          rules.max_spinners - spinner_count
        )

        i = 0
        while i < to_spawn
          addSpinner()
          ++i
        next_spinner = rand rules.min_spinner_rest, rules.max_spinner_rest

      next_spinner -= FRAME_LENGTH_MS

    player = undefined

    death = ->
      score DEATH_SCORE
      player.init()


    addSpinner = ->
      ++spinner_count
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
          @vx = frand(-0.25, 0.25)
          @fliph = @vx < 0
          @vy = frand(0.125, 1)
          @active = true

        initialize: ->
          @init()

        die: ->
          --spinner_count
          gbox.trashObject @

        first: ->
          @x += @vx
          @y += @vy
          
          @frame = Math.floor(@y/4) % 4
          for bullet in player.bullets
            if bullet.active
              if gbox.collides @, bullet
                if @w > 8
                  score BIG_SPINNER_SHOT_SCORE
                else
                  score SMALL_SPINNER_SHOT_SCORE
                bullet.active = false
                @die()

          if @x < LEFT_WALL
            @die()
          if @x + @w > RIGHT_WALL
            @die()

          if @y + @h > FLOOR
            if @w > 8
              score BIG_SPINNER_LAND_SCORE
            else
              score SMALL_SPINNER_LAND_SCORE
            death()
            @die()

        blit: ->
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
        init: ->
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

        initialize: ->
          @init()

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
        gbox.addObject
          id: 'game_logic'
          group: 'game'
          init: gameLogicInit
          first: gameLogic

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
            
            gbox.blitText gbox.getBufferContext(),
              font: 'small'
              text: _score
              dx:16
              dy:92
              dw:8*7
              dh:8
              valign: gbox.ALIGN_TOP
              halign: gbox.ALIGN_RIGHT

      gbox.go()

    window.addEventListener 'load', loadResources, false
