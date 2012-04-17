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
  body ''
  coffeescript ->
    maingame = undefined

    loadResources = ->
      help.akihabaraInit
        title: 'ASTROSMASH!'
        width: 162
        height: 102
        zoom: 4

      gbox.setFps 60

      gbox.addImage 'logo', 'logo.png'

      gbox.addImage "player_sprite", "player_sprite.png"
      gbox.addTiles
        id: "player_tiles"
        image: "player_sprite"
        tileh: 16
        tilew: 16
        tilerow: 1
        gapx: 0
        gapy: 0

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

      gbox.loadAll main
    addBullet = ->
      gbox.addObject
        group: 'bullets'
        active: false
        x: 0
        y: 0
        speed: 4
        first: ->
          if @active
            @y -= @speed
            if @y < -gbox.getImage('bullet').height
              @active = false

        blit: ->
          if @active
            gbox.blitAll gbox.getBufferContext(), gbox.getImage('bullet'),
              dx:@x
              dy:@y

    addPlayer = ->
      gbox.addObject
        id: "player_id"
        group: "player"
        tileset: "player_tiles"
        frame: 0
        width: gbox.getImage('player_sprite').width
        speed: 2
        bullets: []
        initialize: ->
          @w = gbox.getImage('player_sprite').width
          @w = gbox.getImage('player_sprite').height
          @x = gbox.getScreenW()/2 - @w/2
          @y = 81

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
          if @x > gbox.getScreenW() - @width - 1
            @x = gbox.getScreenW() - @width - 1

        blit: ->
          gbox.blitTile gbox.getBufferContext(),
            tileset: @tileset
            tile: @frame
            dx: @x
            dy: @y
            fliph: @fliph
            flipv: @flipv
            camera: @camera
            alpha: 1.0

    main = ->
      gbox.setGroups ['background', 'bullets', 'player', 'game']
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
