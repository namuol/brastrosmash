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

    addPlayer = ->
      gbox.addObject
        id: "player_id"
        group: "player"
        tileset: "player_tiles"
        initialize: ->
          toys.topview.initialize this, {}

        first: ->
          toys.topview.controlKeys this,
            left: "left"
            right: "right"
            #up: "up"
            #down: "down"

          toys.topview.handleAccellerations this
          toys.topview.applyForces this

        blit: ->
          gbox.blitFade gbox.getBufferContext(), {}
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
      gbox.setGroups ['player', 'game']
      maingame = gamecycle.createMaingame('game', 'game')
      maingame.gameTitleIntroAnimation = (reset) ->
        if reset
          toys.resetToy @, 'rising'

        gbox.blitFade gbox.getBufferContext(),
          alpha:1
        toys.logos.linear @, 'rising',
          image: 'logo'
          sx: gbox.getScreenW() / 2 - gbox.getImage('logo').width / 2
          sy: 1
          x: gbox.getScreenW() / 2 - gbox.getImage('logo').width / 2
          y: 1
          speed: 0

      maingame.pressStartIntroAnimation = (reset) ->
        if reset
          toys.resetToy @, 'default-blinker'
        else
          gbox.keyIsHit 'a'

      maingame.initializeGame = ->
        addPlayer()

      gbox.go()

    window.addEventListener 'load', loadResources, false
