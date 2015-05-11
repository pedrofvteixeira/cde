'use strict'
###*
# @module TreeSelector
###

###*
# Mixin that provides console logging abilities
# @class Logger
# @static
# @extensionfor AbstractSelect
# @extensionfor Models.Tree
# @extensionfor Views.Abstract
# @main
###
do (TreeSelector = TreeSelector) ->
  TreeSelector.Logger =
    ###*
    # @property logLevel
    # @type {Integer}
    # @default 0
    ###
    logLevel:0


    ###*
    # @property ID
    # @type {String}
    # @default "TreeSelector.{{Namespace}}.{{Class}}"
    ###
    ID: ''


    ###*
    # Outputs a message to the console (using console.log), if the logLevel is right
    # @method log
    # @param {String} message
    # @chainable
    ###
    log: (msg) ->
      if @logLevel >= 1
        console?.log? if @ID? then "#{@ID} : #{msg}" else msg
      return this


    ###*
    # Outputs a debugg message to the console (using console.debug), if the logLevel is right
    # @method debug
    # @param {String} message
    # @chainable
    ###
    debug: (msg) ->
      if @logLevel >= 2
        console?.debug?  if @ID? then "#{@ID} : #{msg}" else msg
      return this

    ###*
    # Outputs a warning message to the console (using console.warn), if the logLevel is right
    # @method warn
    # @param {String} message
    # @chainable
    ###
    warn: (msg) ->
      console?.warn?  if @ID? then "#{@ID} : #{msg}" else msg
      return this

    ###*
    # Outputs an informative message to the console (using console.info)
    # @method info
    # @chainable
    # @param {String} message
    ###
    info: (msg) ->
      console?.info?  if @ID? then "#{@ID} : #{msg}" else msg
      return this

    ###*
    # Outputs an error message to the console (using console.error)
    # @method error
    # @param {String} message
    # @chainable
    ###
    error: (msg) ->
      console?.error?  if @ID? then "#{@ID} : #{msg}" else msg
      return this
