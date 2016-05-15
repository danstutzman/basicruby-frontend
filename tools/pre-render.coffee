#!/usr/bin/env coffee
fs            = require 'fs'
http          = require 'http'
mkdir         = require 'mkdir'
path_         = require 'path'
htmlparser2   = require 'htmlparser2'
global.React  = require 'react'
_             = require 'underscore'
Entities      = require('html-entities').AllHtmlEntities
ApiService    = require '../build/coffee/app/ApiService.js'
Router        = require '../build/coffee/app/Router'

process.chdir(path_.dirname(process.argv[1]) + '/..')

if process.argv.length < 2 + 1 # [0]coffee [1]script.coffee [2]hostname
  process.stderr.write "First arg: hostname for API server\n"
  process.exit 1
else
  apiHost = process.argv[2]

# fake object is necessary global
global.History = {}

rpc =
  request: (config, success, error) ->
    options =
       method:   config.method
       hostname: apiHost.split(':')[0]
       port:     apiHost.split(':')[1]
       path:     config.url
    request = http.request options, (response) ->
      response.setEncoding 'utf8'
      dataSoFar = ''
      response.on 'data', (data) ->
        dataSoFar += data.toString()
      response.on 'end', (data) ->
        result = { data: dataSoFar }
        success(result)
      response.on 'error', (e) ->
        throw new "problem with request: #{e.message}"
    request.end()

service = new ApiService(rpc, (showThrobber)->)
router = new Router(service)
render = (path, callback) ->
  router.render path, (reactComponent, callbackIgnored) ->
    outerHtml  = fs.readFileSync('dist/index-outer.html').toString()
    innerHtml  = React.renderComponentToString(reactComponent)
    beforeHtml = outerHtml.replace /<!-- START PRE-RENDERED CONTENT -->([^]*)/, ''
    afterHtml  = outerHtml.replace /([^]*)<!-- END PRE-RENDERED CONTENT -->/, ''
    outputHtml = beforeHtml +
      (new Entities()).encodeNonASCII(innerHtml) + afterHtml
    outputHtml = outputHtml.replace(
      /<link rel="stylesheet" href="..\/stylesheets\//g,
      '<link rel="stylesheet" href="/stylesheets/')
    outputHtml = outputHtml.replace(
      /<script src="..\/javascripts\//g,
      '<script src="/javascripts/')
    numDirs = path.split('/').length
    if path == '/'
      pathOnDisk = 'dist/index.html'
    else
      pathOnDisk = "dist/static#{numDirs}#{path}"

    console.log pathOnDisk
    mkdir.mkdirsSync path_.dirname(pathOnDisk)
    fs.writeFileSync pathOnDisk, outputHtml
    callback()

scrapeTutorForPaths = (callbackWithTutorPaths) ->
  router.render '/tutor', (reactComponent, callbackIgnored) ->
    html = React.renderComponentToString(reactComponent)

    paths = []
    parser = new htmlparser2.Parser
      onopentag: (name, attributes) ->
        if name == 'a'
          paths.push attributes.href
    parser.write html
    parser.end()

    callbackWithTutorPaths paths

gatherAllPaths = (callbackWithAllPaths) ->
  paths = ['/', '/tutor']
  service.getAllExercises (data) ->
    for exercise in data
      color = exercise.color.substring(0, 1).toUpperCase()
      if exercise.rep_num == 1
        path = "/#{exercise.topic_num}#{color}"
      else
        path = "/#{exercise.topic_num}#{color}/#{exercise.rep_num}"
      paths.push path
  scrapeTutorForPaths (tutorPaths) ->
    callbackWithAllPaths paths.concat(tutorPaths)

renderSitemap = (paths) ->
  content = _.map(paths, (path) -> "http://www.basicruby.com#{path}").join("\n")
  console.log 'dist/sitemap.txt'
  fs.writeFileSync 'dist/sitemap.txt', content

render404 = ->
  render '/404', (->)

gatherAllPaths (paths) ->
  renderSitemap(paths)
  render404()

  renderPaths = (paths) ->
    nextPath = paths.shift()
    render nextPath, ->
      if paths.length > 0
        renderPaths paths
  renderPaths paths