require "../../test_setup"

GameObject = require "../../game_object"

describe "Cooldown", ->
  test "objects count down each of their cooldowns", ->
    obj = GameObject
      bullet: 83
      cooldowns:
        bullet:
          target: 3
          approachBy: 1

    5.times ->
      obj.update(1)

    equals obj.I.bullet, 78, "bullet should decrease by 5"

    100.times ->
      obj.update(1)

    equals obj.I.bullet, 3, "bullet should not cool down part target value"

  test "should handle negative value", ->
    obj = GameObject
      powerup: -70
      cooldowns:
        powerup:
          target: 0
          approachBy: 1

    11.times ->
      obj.update(1)

    equals obj.I.powerup, -59, "powerup should increase by 11"

    70.times ->
      obj.update(1)

    equals obj.I.powerup, 0, "powerup should not cooldown past target value"

  test "adding many cooldowns to default instance variables", ->
    obj = GameObject
      cool: 20
      rad: 0
      tubular: 0
      cooldowns:
        cool:
          approachBy: 5
          target: -5
        rad:
          approachBy: 0.5
          target: 1.5
        tubular:
          approachBy: 1
          target: 1000

    4.times ->
      obj.update(1)

    equals obj.I.cool, 0
    equals obj.I.rad, 1.5
    equals obj.I.tubular, 4

  test "#cooldown", ->
    obj = GameObject
      health: 100

    obj.cooldown 'health'

    3.times ->
      obj.update(1)

    equals obj.I.health, 97, "health cooldown should exist and equal 97"

    obj.cooldown 'turbo',
      target: 25
      approachBy: 3

    4.times ->
      obj.update(1)

    equals obj.I.health, 93, "health should continue of cool down when new cooldowns are added"
    equals obj.I.turbo, 12, "turbo should cool down normally"

  test "should not blow up if cooldowns aren't specified", ->
    obj = GameObject()

    obj.update(1)
    obj.trigger "afterUpdate", 1

    equals obj.I.age, 1, "should successfully update"

  test "use existing value of instance variable as starting value if no value param given", ->
    obj = GameObject()

    obj.I.health = 3

    obj.cooldown 'health',
      target: 10

    5.times ->
      obj.update(1)

    equals obj.I.health, 8

  test "initialize property to 0 if no current value", ->
    obj = GameObject()

    obj.cooldown 'health',
      target: 10

    5.times ->
      obj.update(1)

    equals obj.I.health, 5
