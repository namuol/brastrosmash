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
    window.rand = (min, max) -> Math.round(frand(min, max))
    choose = (array) -> array[rand(0,array.length-1)]

    maingame = undefined

    loadResources = ->
      help.akihabaraInit
        title: 'BRASTROSMASH!'
        width: 322
        height: 202
        zoom: 2

      gbox.setFps 60

      gbox.addImage 'logo', 'logo.png'
      gbox.addImage 'bg', 'bg.png'
      gbox.addImage 'bullet', 'bullet.png'

      gbox.addImage 'font', 'font.png'
      gbox.addFont
        id: 'small'
        image: 'font'
        firstletter: '!'
        tileh: 16
        tilew: 16
        tilerow: 20
        gapx: 0
        gapy: 0

      gbox.addImage 'font_green', 'font_green.png'
      gbox.addFont
        id: 'small_green'
        image: 'font_green'
        firstletter: '!'
        tileh: 16
        tilew: 16
        tilerow: 20
        gapx: 0
        gapy: 0

      gbox.addImage 'player_sprite', 'player_sprite.png'

      gbox.addImage 'explosion', 'explosion.png'
      gbox.addTiles
        id: 'explosion_tiles'
        image: 'explosion'
        tileh: 16
        tilew: 16
        tilerow: 1
        gapx: 0
        gapy: 0

      gbox.addImage 'spinner', 'spinner.png'
      gbox.addTiles
        id: 'spinner_tiles'
        image: 'spinner'
        tileh: 16
        tilew: 16
        tilerow: 4
        gapx: 0
        gapy: 0

      gbox.addImage 'spinner_big', 'spinner_big.png'
      gbox.addTiles
        id: 'spinner_big_tiles'
        image: 'spinner_big'
        tileh: 32
        tilew: 32
        tilerow: 1
        gapx: 0
        gapy: 0

      gbox.addImage 'small_rocks', 'small_rocks.png'
      gbox.addTiles
        id: 'small_rock_tiles'
        image: 'small_rocks'
        tilew: 16
        tileh: 8
        tilerow: 3
        gapx: 0
        gapy: 0

      gbox.addImage 'large_rocks', 'large_rocks.png'
      gbox.addTiles
        id: 'large_rock_tiles'
        image: 'large_rocks'
        tilew: 32
        tileh: 16
        tilerow: 3
        gapx: 0
        gapy: 0

      gbox.loadAll main

    LEFT_WALL = 1
    RIGHT_WALL = 321
    CEILING = 1
    FLOOR = 177

    _score = 0
    multiplyer = 1
    speed_scale = MIN_SPEED_SCALE
    
    score_peak = 0
    one_up_total = 0

    score = (change) ->
      return if lives < 0

      _score += change*multiplyer
      if _score > score_peak
        score_peak = _score

      if _score > 0
        one_up_total += change*multiplyer
        if one_up_total >= ONE_UP_SCORE
          one_up_total = one_up_total - ONE_UP_SCORE
          ++lives

      if _score >= X6_LEVEL_SCORE
        multiplyer = 6
      else if _score >= X5_LEVEL_SCORE
        multiplyer = 5
      else if _score >= X4_LEVEL_SCORE
        multiplyer = 4
      else if _score >= X3_LEVEL_SCORE
        multiplyer = 3
      else if _score >= X2_LEVEL_SCORE
        multiplyer = 2
      else
        multiplyer = 1
      multiplyer = 0 if lives < 0

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
    ONE_UP_SCORE = 1000

    MIN_SPEED_SCALE = 0.3
    MAX_SPEED_SCALE = 1.0

    MAX_MULTIPLYER = 6
    X2_LEVEL_SCORE = 1000
    X3_LEVEL_SCORE = 5000
    X4_LEVEL_SCORE = 20000
    X5_LEVEL_SCORE = 50000
    X6_LEVEL_SCORE = 100000

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
    
    BLACK = '#000000'
    WHITE = '#ffffff'
    ORANGE = '#ffb71f'
    LIGHT_BLUE = '#a797ff'
    PINK = '#ff4f57'
    GREEN = '#00a757'
    OFF_WHITE = '#cfcfaf'
    YELLOW = '#ffef57'
    DARK_GREEN = '#3f6f3f'
    BLUE = '#002fff'
    RED = '#ff3f17'
    GRAY = '#bfafcf'
    CYAN = '#27b7ff'
    BROWN = '#576f00'
    YELLOW_GREEN = '#77cf87'
    PURPLE = '#b71f5f'

    ROCK_COLORS = [
      [
        0#ORANGE
        1#LIGHT_BLUE
        2#PINK
        3#GREEN
        4#OFF_WHITE
        5#YELLOW
      ]
      [
        0#ORANGE
        1#LIGHT_BLUE
        2#PINK
        4#OFF_WHITE
        5#YELLOW
      ]
      [
        0#ORANGE
        1#LIGHT_BLUE
        3#GREEN
        4#OFF_WHITE
        5#YELLOW
      ]
      [
        0#ORANGE
        4#OFF_WHITE
        5#YELLOW
        6#DARK_GREEN
      ]
      [
        3#GREEN
        5#YELLOW
        6#DARK_GREEN
      ]
      [
        0#ORANGE
        1#LIGHT_BLUE
        2#PINK
        3#GREEN
        4#OFF_WHITE
        5#YELLOW
      ]
    ]

    LEVEL_COLORS = [
      RED   # Game Over
      BLACK # x1
      BLUE  # x2
      PURPLE# x3
      CYAN  # x4
      GRAY  # x5
      BLACK # x6
    ]


    RULES = [
      X1_RULES
      X2_RULES
      X3_RULES
      X4_RULES
      X5_RULES
      X6_RULES
    ]
    

    window.lives = 4

    next_spinner = 0
    spinner_count = 0

    next_rock = 0
    rock_count = 0

    gameLogicInit = ->
      next_spinner = rand rules.min_spinner_rest, rules.max_spinner_rest
      next_rock = rand rules.min_rock_rest, rules.max_rock_rest

    rules = RULES[0]

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

      if next_rock <= 0 and rock_count < rules.max_rocks
        to_spawn = Math.min(
          rand(0,rules.max_rock_spawn) + 1,
          rules.max_rocks - rock_count
        )

        i = 0
        while i < to_spawn
          addRock()
          ++i
        next_rock = rand rules.min_rock_rest, rules.max_rock_rest
      next_rock -= FRAME_LENGTH_MS

      if _score <= 0
        speed_scale = MIN_SPEED_SCALE
      else
        speed_scale = MIN_SPEED_SCALE + Math.min(MAX_SPEED_SCALE-MIN_SPEED_SCALE,
                                                 Math.sqrt(_score/X6_LEVEL_SCORE))

    player = undefined

    death = ->
      one_up_total = 0
      rock_count = 0
      gbox.clearGroup 'rocks'
      spinner_count = 0
      gbox.clearGroup 'spinners'
      score DEATH_SCORE
      --lives
      player.init()

    MIN_SPINNER_YSPEED = 0.5
    MAX_SPINNER_YSPEED = 1.0
    MIN_SPINNER_XSPEED = 0.0
    MAX_SPINNER_XSPEED = 0.25

    addSpinner = ->
      ++spinner_count
      gbox.addObject
        group: 'spinners'
        frame: 0
        init: ->
          if rand(0,1) is 0
            @tileset = 'spinner_tiles'
            @w = 16
            @h = 16
          else
            @tileset = 'spinner_big_tiles'
            @w = 32
            @h = 32
          @y = -@h
          @x = frand 0, gbox.getScreenW()
          @vx = frand(MIN_SPINNER_XSPEED, MAX_SPINNER_XSPEED) * speed_scale
          @vx *= -1 if rand(0,1) is 1
          @fliph = @vx < 0
          @vy = frand(MIN_SPINNER_YSPEED, MAX_SPINNER_YSPEED) * speed_scale

        initialize: ->
          @init()

        die: (doScore) ->
          --spinner_count
          gbox.trashObject @

          if doScore > 0
            if @w > 16
              score BIG_SPINNER_SHOT_SCORE
            else
              score SMALL_SPINNER_SHOT_SCORE

        first: ->
          @x += @vx
          @y += @vy
          
          @frame = Math.floor(@y/4) % 4
          for bullet in player.bullets
            if bullet.active
              if gbox.collides @, bullet
                bullet.active = false
                addExplosion @x+@w/2, @y+@h/2
                @die(1)
                return

          for own id,explosion of gbox.getGroup 'explosions'
            if gbox.collides @, explosion
              addExplosion @x+@w/2, @y+@h/2
              @die(1)
              return

          if @x < LEFT_WALL
            @die(0)
            return
          if @x + @w > RIGHT_WALL
            @die(0)
            return

          if @y + @h > FLOOR
            if @w > 16
              score BIG_SPINNER_LAND_SCORE
            else
              score SMALL_SPINNER_LAND_SCORE

            death()
            return

        blit: ->
          gbox.blitTile gbox.getBufferContext(),
            tileset: @tileset
            tile: @frame
            dx: Math.round @x
            dy: Math.round @y
            fliph: @fliph

    MIN_ROCK_YSPEED = 0.85
    MAX_ROCK_YSPEED = 2.0
    MIN_ROCK_XSPEED = 0
    MAX_ROCK_XSPEED = 0.25
    ROCK_SPLIT_SPEED = 0.25
    ROCK_SPLIT_PROBABILITY = 0.5

    addRock = (parent, num, rock_num) ->
      ++rock_count
      gbox.addObject
        group: 'rocks'
        frame: 0
        init: ->
          if parent
            if num is 1
              @vx = -ROCK_SPLIT_SPEED + parent.vx
              @x = parent.x + 4
            else
              @vx = ROCK_SPLIT_SPEED + parent.vx
              @x = parent.x + 4
            @y = parent.y
            @vy = parent.vy
            @color = parent.color
            @tileset = 'small_rock_tiles'
            @w = 16
            @h = 8
          else
            @color = choose ROCK_COLORS[multiplyer-1]
            rock_num = rand(0,2)

            if rand(0,1) is 0
              @tileset = 'small_rock_tiles'
              @w = 16
              @h = 8
            else
              @tileset = 'large_rock_tiles'
              @w = 32
              @h = 16
            @y = -@h
            @x = frand 0, gbox.getScreenW()
            @vx = frand(MIN_ROCK_XSPEED, MAX_ROCK_XSPEED) * speed_scale
            @vx *= -1 if rand(0,1) is 1
            @vy = frand(MIN_ROCK_YSPEED, MAX_ROCK_YSPEED) * speed_scale

          @frame = @color*3 + rock_num
          @fliph = @vx < 0

        initialize: ->
          @init()

        die: (doScore) ->
          --rock_count
          gbox.trashObject @

          if doScore > 0
            if @w > 16
              score BIG_ROCK_SHOT_SCORE
            else
              score SMALL_ROCK_SHOT_SCORE
          else if doScore < 0
            if @w > 16
              score BIG_ROCK_LAND_SCORE
            else
              score SMALL_ROCK_LAND_SCORE

        first: ->
          @x += @vx
          @y += @vy
          
          for bullet in player.bullets
            if bullet.active
              if gbox.collides @, bullet
                bullet.active = false
                if @w > 16 and frand(0,1) < ROCK_SPLIT_PROBABILITY
                  rock_num = rand(0,2)
                  addRock @, 0, rock_num
                  addRock @, 1, rock_num
                else
                  addExplosion @x+@w/2, @y+@h/2
                @die(1)
                return

          for own id,explosion of gbox.getGroup 'explosions'
            if gbox.collides @, explosion
              addExplosion @x+@w/2, @y+@h/2
              @die(1)
              return

          if gbox.collides @, player
            console.log _score
            console.log speed_scale
            death()
            return

          if @x < LEFT_WALL
            @die(0)
          if @x + @w > RIGHT_WALL
            @die(0)

          if @y + @h > FLOOR
            @die(-1)

        blit: ->
          gbox.blitTile gbox.getBufferContext(),
            tileset: @tileset
            tile: @frame
            dx: Math.round @x
            dy: Math.round @y
            fliph: @fliph

    EXPLOSION_FRAME_LENGTH = 3
    EXPLOSION_FRAME_COUNT = 7
    EXPLOSION_FRAME_HEIGHT = 16
    EXPLOSION_FRAME_WIDTH = 16

    addExplosion = (x,y) ->
      gbox.addObject
        group: 'explosions'
        frame: 0
        tileset: 'explosion_tiles'
        x: x-8
        y: y-8
        frame_count: 0

        die: ->
          gbox.trashObject @

        first: ->
          ++@frame_count
          if @frame_count > EXPLOSION_FRAME_LENGTH * EXPLOSION_FRAME_COUNT
            @die()

          if gbox.collides @, player, 0
            death()

          @frame = Math.floor @frame_count / EXPLOSION_FRAME_LENGTH

        blit: ->
          gbox.blitTile gbox.getBufferContext(),
            tileset: @tileset
            tile: @frame
            dx: Math.round @x
            dy: Math.round @y

    addBullet = ->
      gbox.addObject
        group: 'bullets'
        active: false
        x: 0
        y: 0
        h: 24
        w: 4
        speed: 8
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
        id: 'player_id'
        group: 'player'
        speed: 3
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
      gbox.setGroups ['background', 'explosions', 'bullets', 'rocks', 'spinners', 'game', 'player']
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
            color_index = 0
            if lives >= 0
              color_index = multiplyer
            gbox.blitFade gbox.getBufferContext(),
              color:LEVEL_COLORS[color_index]
              alpha:1

            gbox.blitAll gbox.getBufferContext(), gbox.getImage('bg'),
              dx:1
              dy:1

            gbox.blitText gbox.getBufferContext(),
              font: 'small'
              text: _score
              dx:32
              dy:FLOOR + 4
              dw:16*7
              dh:16
              valign: gbox.ALIGN_TOP
              halign: gbox.ALIGN_RIGHT
            
            lives_text = ''
            if lives > 7
              lives_text = '*' + lives
            else
              i = 0
              lives_text = ''
              while i < lives
                lives_text += '*'
                ++i

            gbox.blitText gbox.getBufferContext(),
              font: 'small_green'
              text: lives_text
              dx:160
              dy:FLOOR + 4
              dw:16*7
              dh:16
              valign: gbox.ALIGN_TOP
              halign: gbox.ALIGN_LEFT

            gbox.blitText gbox.getBufferContext(),
              font: 'small'
              text: 'x'+multiplyer
              dx:160+16*7
              dy:FLOOR + 4
              dw:16*2
              dh:16
              valign: gbox.ALIGN_TOP
              halign: gbox.ALIGN_LEFT

      gbox.go()

    window.addEventListener 'load', loadResources, false
