require "../../test_setup"

GameObject = require "../../game_object"

describe 'Meter', ->

  test "should respect 0 being set as the meter attribute", ->
    obj = GameObject
      health: 0
      healthMax: 110

    obj.meter 'health'

    equals obj.I.health, 0

  test "should set max<Attribute> if it isn't present in the including object", ->
    obj = GameObject
      health: 150

    obj.meter 'health'

    equals obj.I.healthMax, 150

  test "should set both <attribute> and max<attribute> if they aren't present in the including object", ->
    obj = GameObject()

    obj.meter 'turbo'

    equals obj.I.turbo, 100
    equals obj.I.turboMax, 100
