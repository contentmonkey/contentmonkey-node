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
parts = JSON.parse fs.readFileSync('./server.json', 'utf-8')
styleDir = do process.cwd + '/themes/styling/' + parts['CurrentStyling']
console.log styleDir
