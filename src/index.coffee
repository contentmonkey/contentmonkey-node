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
styleDir = do process.cwd + '/themes/styling/' + parts['CurrentStyling']
layoutDir = do process.cwd + '/themes/layout/' + parts['CurrentLayout']
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

parts["layout"] = fs.readFileSync layoutDir + '/template.html', 'utf8'
parts["404"] = fs.readFileSync styleDir + '/404.html', 'utf8'
parts["footer"] = fs.readFileSync styleDir + '/footer.html', 'utf8'
parts["header"] = fs.readFileSync styleDir + '/header.html', 'utf8'
parts["sidebar"] = fs.readFileSync styleDir + '/sidebar.html', 'utf8'

partFiles = fs.readdirSync parts['Sitebase'] + "parts/"
partFiles.forEach (ele, index, array) ->
  parts[path.basename ele, path.extname(ele)] = figurePage parts['Sitebase'] + "parts/" + path.basename(ele, path.extname(ele))
