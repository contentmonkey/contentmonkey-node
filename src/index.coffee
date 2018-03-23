#
# Load the libraries used
#
fs = require 'fs'
path = require 'path'
child_process = require 'child_process'
process = require 'process'
express = require 'express' # http://expressjs.com/en/
morgan = require 'morgan' # https://github.com/expressjs/morgan
Handlebars = require 'handlebars' # http://handlebarsjs.com/
moment = require 'moment' # http://momentjs.com/
marked = require 'marked' # https://github.com/chjj/marked
jade = require 'jade' # http://jade-lang.com/

#
# Setup Global Variables
#
console.log 'Loading settings...'
parts = JSON.parse fs.readFileSync('./server.json', 'utf-8')
styleDir = do process.cwd + '/themes/' + parts['CurrentTheme']
layoutDir = styleDir
templateDir = do process.cwd + '/themes/' + parts['CurrentTheme'] + '/templates'
siteCSS = null
siteScripts = null
mainPage = null
console.log 'CurrentStyling: ' + styleDir
console.log 'CurrentLayout: ' + layoutDir

marked.setOptions {
  renderer: new marked.Renderer,
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: false,
  smartLists: true,
  smartypants: false
}

parts["layout"] = fs.readFileSync templateDir + '/page.html', 'utf8'
parts["404"] = fs.readFileSync templateDir + '/404.html', 'utf8'
parts["footer"] = fs.readFileSync templateDir + '/footer.html', 'utf8'
parts["header"] = fs.readFileSync templateDir + '/header.html', 'utf8'
parts["sidebar"] = fs.readFileSync templateDir + '/sidebar.html', 'utf8'

parts["Sitebase"] = styleDir + "/"

partFiles = fs.readdirSync parts['Sitebase'] + "parts/"

#
# Setup Handlebar's Helpers.
#

#
# HandleBars Helper:     save
#
# Description:         This helper expects a
#                      "<name>" "<value>" where the name
#                      is saved with the value for future
#                      expansions. It also returns the
#                      value directly.
#
Handlebars.registerHelper "save", (name, text) ->
  #
  # Local Variables.
  #
  newName = ""
  newText = ""

  #
  # See if the name and text is in the first argument
  # with a |. If so, extract them properly. Otherwise,
  # use the name and text arguments as given.
  #
  if name.indexOf("|") > 0
    parts = name.split("|")
    newName = parts[0]
    newText = parts[1]
  else
    newName = name
    newText = text

  #
  # Register the new helper.
  #
  Handlebars.registerHelper newName, () ->
    return newText

  #
  # Return the text.
  #
  return newText


#
# HandleBars Helper:   date
#
# Description:         This helper returns the date
#                      based on the format given.
#
Handlebars.registerHelper "date", (dFormat) ->
  return moment().format dFormat


#
# HandleBars Helper:   cdate
#
# Description:         This helper returns the date given
#                      in to a format based on the format
#                      given.
#
Handlebars.registerHelper "cdate", (cTime, dFormat) ->
  return moment(cTime).format(dFormat)


#
# Create and configure the server.
#
contentmonkey = do express

#
# Configure middleware.
#
contentmonkey.use morgan('combined')

#
# Define the routes.
#
contentmonkey.get '/', (request, response) ->
  setBasicHeader response
  if parts["Cache"] == true && mainPage != null
    response.send mainPage
  else
    mainPage = page "main"
    response.send mainPage

contentmonkey.get '/stylesheets.css', (request, response) ->
  response.set "Content-Type", "text/css"
  setBasicHeader response
  response.type "css"
  if parts["Cache"] == true && siteCSS != null
    response.send siteCSS
  else
    siteCSS = fs.readFileSync parts['Sitebase'] + 'css/final/final.css'
    response.send siteCSS


#
# Start the server.
#
addressItems = parts['ServerAddress'].split ':'
server = contentmonkey.listen addressItems[2], () ->
  host = server.address().address;
  port = server.address().port;
  console.log 'contentmonkey is listening at http://%s:%s', host, port

setBasicHeader = (response) ->
  response.append "Cache-Control", "max-age=2592000, cache"
  response.append "Server", "ContentMonkey"

page = (p) ->
  return "<h1>Hello World</h1>"

dump = () -> return null

figurePage = (p) ->
  return ""
