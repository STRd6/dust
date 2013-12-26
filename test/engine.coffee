require "../test_setup"

Engine = require "../engine"

describe "Engine", ->
  
  MockCanvas = ->
    clear: ->
    context: ->
      beginPath: ->
      clip: ->
      rect: ->
    drawRect: ->
    fill: ->
    withTransform: (t, fn) ->
      fn(@)
    clip: ->
  
  test "#play, #pause, and #paused", ->
    engine = Engine()
  
    equal engine.paused(), false
    engine.pause()
    equal engine.paused(), true
    engine.play()
    equal engine.paused(), false
  
    engine.pause()
    equal engine.paused(), true
    engine.pause()
    equal engine.paused(), false
  
    engine.pause(false)
    equal engine.paused(), false
  
    engine.pause(true)
    equal engine.paused(), true
  
  test "#save and #restore", ->
    engine = Engine()
  
    engine.add {}
    engine.add {}
  
    equals(engine.objects().length, 2)
  
    engine.saveState()
  
    engine.add {}
  
    equals(engine.objects().length, 3)
  
    engine.loadState()
  
    equals(engine.objects().length, 2)
  
  test "before add event", ->
    engine = Engine()
  
    engine.bind "beforeAdd", (data) ->
      equals data.test, "test"
  
    engine.add
      test: "test"
  
  test "#add", ->
    engine = Engine()
  
    engine.add "GameObject",
      test: true
  
    ok engine.first("GameObject")
  
  test "#add class name only", ->
    engine = Engine()
  
    engine.add "GameObject"
  
    ok engine.first("GameObject")
  
  test "zSort", ->
    engine = Engine
      canvas: MockCanvas()
      zSort: true
  
    n = 0
    bindDraw = (o) ->
      o.bind 'draw', ->
        n += 1
        o.I.drawnAt = n
  
    o2 = engine.add
      zIndex: 2
    o1 = engine.add
      zIndex: 1
  
    bindDraw(o1)
    bindDraw(o2)
  
    engine.frameAdvance()
  
    equals o1.I.drawnAt, 1, "Object with zIndex #{o1.I.zIndex} should be drawn first"
    equals o2.I.drawnAt, 2, "Object with zIndex #{o2.I.zIndex} should be drawn second"

  test "draw events", ->
    engine = Engine
      canvas: MockCanvas()
      backgroundColor: false
    
    calls = 0

    engine.bind "beforeDraw", ->
      calls += 1
      ok true

    engine.bind "draw", ->
      calls += 1
      ok true

    engine.frameAdvance()

    equals calls, 2
  
  test "Remove event", 1, ->
    engine = Engine
      backgroundColor: false
  
    object = engine.add
      active: false
  
    object.bind "remove", ->
      ok true, "remove called"
  
    engine.frameAdvance()
  
  test "#find", ->
    engine = Engine()
  
    engine.add
      id: "testy"
  
    engine.add
      test: true
  
    engine.add
      solid: true
      opaque: false
  
    equal engine.find("#no_testy").length, 0
    equal engine.find("#testy").length, 1
    equal engine.find(".test").length, 1
    equal engine.find(".solid=true").length, 1
    equal engine.find(".opaque=false").length, 1
  
  test "Selector.parse", ->
    a = Engine.Selector.parse("#foo")
    equal a.length, 1
    equal a.first(), "#foo"
  
    a = Engine.Selector.parse("#boo, baz")
    equal a.length, 2
    equal a.first(), "#boo"
    equal a.last(), "baz"
  
    a = Engine.Selector.parse("#boo,Light.flicker,baz")
    equal a.length, 3
    equal a.first(), "#boo"
    equal a[1], "Light.flicker"
    equal a.last(), "baz"
  
  test "Selector.process", ->
    [type, id, attr, value] = Engine.Selector.process("Foo#test.cool=1")
  
    equal type, "Foo"
    equal id, "test"
    equal attr, "cool"
    equal value, 1
  
    [type, id, attr, value] = Engine.Selector.process(".baz=false")
  
    equal type, undefined
    equal id, undefined
    equal attr, "baz"
    equal value, false
  
  test "#camera", ->
    engine = Engine()
  
    equal engine.camera(), engine.cameras().first()
  
  test "#collides", ->
    engine = Engine()
  
    engine.collides({x: 0, y: 0, width: 10, height: 10}, null)
  
  test "Integration", ->
    engine = Engine
      FPS: 30
  
    object = engine.add
      class: "GameObject"
      velocity: Point(30, 0)
  
    engine.frameAdvance()
  
    equals object.I.x, 1
    equals object.I.age, 1/30
  
  test "#setState", ->
    engine = Engine()
  
    nextState = GameState()
  
    engine.setState nextState
  
    # Test state change events
    engine.bind "stateEntered", ->
      ok true
    engine.bind "stateExited", ->
      ok true
  
    engine.update()
  
    equal engine.I.currentState, nextState
