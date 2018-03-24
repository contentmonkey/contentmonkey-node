#
# Load the libraries used
#
fs            = require 'fs'
path          = require 'path'
child_process = require 'child_process'
process       = require 'process'
express       = require 'express' # http://expressjs.com/en/
morgan        = require 'morgan' # https://github.com/expressjs/morgan
Handlebars    = require 'handlebars' # http://handlebarsjs.com/
moment        = require 'moment' # http://momentjs.com/
marked        = require 'marked' # https://github.com/chjj/marked
pug           = require 'pug' # http://jade-lang.com/
Sequelize     = require 'sequelize'
chalk         = require 'chalk'
cors          = require 'cors'
slash         = require 'express-slash'
helmet        = require 'helmet'
optimus       = require 'connect-image-optimus'
responseTime  = require 'response-time'
bodyParser    = require 'body-parser'
csrf          = require 'csurf'
cookieParser  = require 'cookie-parser'
session       = require 'express-session'
compression   = require 'compression'


log           = console.log

monkeymode = "production"

if process.env.MONKEYMODE != null
  monkeymode = process.env.MONKEYMODE

testmode = false
if monkeymode == "test"
  testmode = true


colors = {
  Reset: "\x1b[0m"
  Bright: "\x1b[1m"
  Dim: "\x1b[2m"
  Underscore: "\x1b[4m"
  Blink: "\x1b[5m"
  Reverse: "\x1b[7m"
  Hidden: "\x1b[8m"

  FgBlack: "\x1b[30m"
  FgRed: "\x1b[31m"
  FgGreen: "\x1b[32m"
  FgYellow: "\x1b[33m"
  FgBlue: "\x1b[34m"
  FgMagenta: "\x1b[35m"
  FgCyan: "\x1b[36m"
  FgWhite: "\x1b[37m"

  BgBlack: "\x1b[40m"
  BgRed: "\x1b[41m"
  BgGreen: "\x1b[42m"
  BgYellow: "\x1b[43m"
  BgBlue: "\x1b[44m"
  BgMagenta: "\x1b[45m"
  BgCyan: "\x1b[46m"
  BgWhite: "\x1b[47m"
}


info = (str) -> log chalk.magenta.bold '[' + chalk.cyan.bold "INFO" + chalk.magenta.bold ']' + " " + chalk.black str
error = (str) -> log chalk.magenta.bold '[' + chalk.red.bold "ERROR" + chalk.magenta.bold ']' + " " + chalk.red.bold str
warn = (str) -> log chalk.magenta.bold '['  + chalk.yellow.bold "WARN"  + chalk.magenta.bold "]" + " " + chalk.bold.yellow str

#
# Setup Global Variables
#
info 'Loading...'
info 'Loading settings...'
parts = JSON.parse fs.readFileSync('./server.json', 'utf-8')
info 'Loading database...'
sequelize = new Sequelize parts['Database']['Database'], parts['Database']['Username'], parts['Database']['Password'], {
  host: parts['Database']['Host'],
  dialect: parts['Database']['Dialect'],
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  },
  storage: "contentmonkey.sqlite",
  operatorsAliases: parts['Database']['operatorsAliases'],
  logging: false
}

User = sequelize.define parts["Database"]["Prefix"] + "users", {
  username: Sequelize.STRING,
  password: Sequelize.STRING,
  email: Sequelize.STRING,
  security_level: Sequelize.INTEGER,
  last_active: Sequelize.DATE,
  registered: Sequelize.DATE,
  firstname: Sequelize.STRING,
  lastname: Sequelize.STRING,
  dummy: Sequelize.BOOLEAN,
  active: Sequelize.BOOLEAN
}

Page = sequelize.define parts["Database"]["Prefix"] + "pages", {
  title: Sequelize.STRING,
  category: Sequelize.INTEGER,
  type: Sequelize.INTEGER,
  content: Sequelize.TEXT,
  draft: Sequelize.BOOLEAN,
  active: Sequelize.BOOLEAN
}
Page.belongsTo User

Setting = sequelize.define parts["Database"]["Prefix"] + "settings", {
  property: Sequelize.STRING,
  value: Sequelize.STRING,
  description: Sequelize.STRING
}

if testmode
  warn "We are not initializing database. We are in test mode!"
else
  if parts["Development"]
    warn "You are using Development-Mode to load the database!"
    sequelize.sync {force: true}
  else
    do sequelize.sync

info 'Loading environment...'
styleDir = do process.cwd + '/themes/' + parts['CurrentTheme']
layoutDir = styleDir
templateDir = do process.cwd + '/themes/' + parts['CurrentTheme'] + '/templates'
imageDir = do process.cwd + '/content/files/images/'
PORT = process.env.PORT || 55555
siteCSS = null
siteScripts = null
mainPage = null
info 'Loading theme...'
info 'CurrentStyling: ' + styleDir
info 'CurrentLayout: ' + layoutDir

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

info 'Loading templates...'
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
info 'Loading HandleBars lib...'
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



info "Loading csrf-Protection..."
csrfProtection =  csrf {cookie: true}

info "Loading bodyParser..."
parseForm = bodyParser.urlencoded {extended: false}

#
# Create and configure the server.
#
info 'Loading server...'
contentmonkey = do express




#
# Configure middleware.
#
info 'Loading morgan...'
contentmonkey.use morgan('combined')

info 'Loading cors...'
contentmonkey.use do cors

info "Loading express-slash..."
#contentmonkey.use do slash
warn "Skipping express-slash in this version!"

info "Loading helmet..."
contentmonkey.use do helmet
warn "Some helmet modules are disabled!"

info "Loading connect-image-optimus..."
contentmonkey.use optimus imageDir

info "Loading response-time..."
contentmonkey.use do responseTime

info "Loading cookie parser..."
contentmonkey.use do cookieParser

info "Loading compression..."
contentmonkey.use compression {filter: shouldCompress}

#
# Define the routes.
#
contentmonkey.get '/', (request, response) ->
  setBasicHeader response
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

contentmonkey.get '/:page', (request, response) ->
  setBasicHeader response
  response.send page request.params.page



startServer = () ->
  addressItems = parts['ServerAddress'].split ':'
  server = contentmonkey.listen PORT, () ->
    host = server.address().address;
    port = server.address().port;
    info 'contentmonkey is listening at http://' + host + ":" + port
    info 'Done!'


#
# Start the server.
#
info 'Starting server...'
if testmode
  error "Interrupting! Only a test."
  process.exit 0
else
  do startServer



page = (p) ->
  return "<h1>Hello World</h1>"

setBasicHeader = (response) ->
  response.append "Cache-Control", "max-age=2592000, cache"
  response.append "Server", "ContentMonkey"

shouldCompress = (req, res) ->
  if req.headers['x-no-compression']
    return false

  return compression.filter req, res
