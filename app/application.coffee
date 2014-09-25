ApiService         = require './ApiService'
DebuggerController = require './DebuggerController'
ExerciseController = require './ExerciseController'
ExerciseComponent  = require './ExerciseComponent'
MenuComponent      = require './MenuComponent'
TutorMenuComponent = require './TutorMenuComponent'

$one = (selector) -> document.querySelector(selector)
$all = (selector) -> document.querySelectorAll(selector)

if window.location.hostname == 'localhost'
  window.onerror = (message, url, lineNumber) ->
    window.alert "See console: #{message} at #{url}:#{lineNumber}"

if window.location.hostname == 'localhost'
  apiHost = 'localhost:9292'
else
  apiHost = 'basicruby.danstutzman.com'
service = new ApiService(apiHost)

pathChanged = (path, oldPath) ->

  if path == '/'
    service.getMenu (data) ->
      React.renderComponent MenuComponent(data), $one('#screen')

  else if path == '/tutor'
    service.getTutorMenu (data) ->
      React.renderComponent TutorMenuComponent(data), $one('#screen')

  else if match = /^\/([0-9]+)([PYBRGO])(\/([0-9]+))?$/.exec(path)
    controller = new ExerciseController($one('#screen'), service, path)
    controller.setup()

  else
    window.alert "Unknown route #{path}"

document.addEventListener 'DOMContentLoaded', ->
  window.hasher.prependHash = ''
  if window.location.hash == ''
    window.hasher.setHash '/'
  window.hasher.initialized.add pathChanged
  window.hasher.changed.add pathChanged
  window.hasher.init()

  # Fix bug where Mobile Safari landscape mode scrolls too far down the page
  window.addEventListener 'orientationchange', ->
    window.scrollTo 0, 1

  window.setTimeout (-> REQUIRE['app/AstToBytecodeCompiler'].initCache()), 0
