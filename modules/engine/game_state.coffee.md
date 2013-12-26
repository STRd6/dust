GameState
=========

This engine module provides GameState support to the engine.

It is included in `Engine` by default.

    {defaults} = require "../../util"
    GameState = require "../../game_state"

    module.exports = (I={}, self) ->
      defaults I,
        # TODO: Shouldn't store complex objects in I properties
        currentState: GameState()

      requestedState = null

      # The idea is that all the engine#beforeUpdate triggers happen
      # before the state beforeUpdate triggers, then the state update
      # then the state after update, then the engine after update
      # like a layered cake with states in the middle.
      self.on "update", (elapsedTime) ->
        I.currentState.trigger "beforeUpdate", elapsedTime
        I.currentState.trigger "update", elapsedTime
        I.currentState.trigger "afterUpdate", elapsedTime
    
      self.on "afterUpdate", ->
        # Handle state change
        if requestedState?
          I.currentState.trigger "exit", requestedState
          self.trigger 'stateExited', I.currentState
    
          previousState = I.currentState
          I.currentState = requestedState
    
          I.currentState.trigger "enter", previousState
          self.trigger 'stateEntered', I.currentState
    
          requestedState = null
    
      self.on "draw", (canvas) ->
        I.currentState.trigger "beforeDraw", canvas
        I.currentState.trigger "draw", canvas
        I.currentState.trigger "overlay", canvas
    
      self.extend
        # Just pass through to the current state
        add: (classNameOrEntityData, entityData={}) ->
          # Allow optional add "Class", data form
          if typeof classNameOrEntityData is "string"
            entityData.class = classNameOrEntityData
          else
            entityData = classNameOrEntityData
      
          self.trigger "beforeAdd", entityData
          object = I.currentState.add(entityData)
          self.trigger "afterAdd", object
      
          return object
      
        camera: (n=0) ->
          self.cameras()[n]
      
        cameras: (newCameras) ->
          if newCameras?
            I.currentState.cameras(newCameras)
      
            return self
          else
            I.currentState.cameras()
      
        fadeIn: (options={}) ->
          self.cameras().invoke('fadeIn', options)
      
        fadeOut: (options={}) ->
          self.cameras().invoke('fadeOut', options)
      
        flash: (options={}) ->
          self.camera(options.camera).flash(options)
      
        objects: ->
          I.currentState.objects()
      
        setState: (newState) ->
          requestedState = newState
      
        shake: (options={}) ->
          self.camera(options.camera).shake(options)
      
        saveState: ->
          I.currentState.saveState()
      
        loadState: (newState) ->
          I.currentState.loadState(newState)
      
        reload: ->
          I.currentState.reload()
