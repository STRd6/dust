The `Age` module handles keeping track of an object's age.

>     player = GameObject()
>
>     player.update(1)
>
>     #=> player.I.age is 1

    {defaults} = require "../util"

    module.exports = (I={}, self) ->
      defaults I,
        age: 0

      self.bind 'afterUpdate', (dt) ->
        I.age += dt

      return self
