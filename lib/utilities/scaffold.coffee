###

  This script runs in a directory that is empty.  The name and scaffold template
  are passed in.  It copies the contents of the scaffold directory to this
  directory and then runs scripts.

  TODO: Need to set up questions regarding custom build

###


Fs       = require "fs"
Path     = require "path"
Exec     = require('child_process').exec
Argv     = require('minimist')( process.argv.slice(2) )

ReadConfig   = require "./read-config"
ExecCommand = require "./execute-command"
BuildTasks = require './../methods/build'
CopySync = require("./directory-tools").copySync
Remove = require("./directory-tools").remove


doAfterPreInstall = (project, scaffoldConfig) ->

  if project.path isnt process.cwd()

    # Copy over all of the things
    CopySync project.path, process.cwd()

  # Save config
  Fs.writeFileSync(
    Path.join(process.cwd(), "#{Tool}.json")
    JSON.stringify(scaffoldConfig, null, 2)
  )

  if not Fs.existsSync('package.json')

    defaultPackageData =
      name: scaffoldConfig.name
      version: "0.0.0"
      description: ""
      main: "index.js"
      scripts:
        test: "echo \"Error: no test specified\" && exit 1"
      author: ""
      license: "MIT"


    Fs.writeFile 'package.json', JSON.stringify(defaultPackageData, null, 2)


  if scaffoldConfig.scripts

    for action of scaffoldConfig.scripts

      if action isnt 'preinstall' and action isnt 'postinstall' and
        action isnt 'custom'

          ExecCommand scaffoldConfig.scripts[action], process.cwd()

  # Before compiling, remove the nspignore folder
  Remove Path.join(process.cwd(), '/norma-ignore')
  BuildTasks [], process.cwd()

  # Run post installation scripts
  if scaffoldConfig.scripts and scaffoldConfig.scripts.postinstall

    ExecCommand(scaffoldConfig.scripts.postinstall, project.path)


module.exports = (project, name) ->



  # name = "My awesome project" or some other cool name
  # project = { path: '/Users/.../Norma/scaffolds/ee-multisite',
  #   name: 'ee-multisite',
  #   type: 'folder',
  #   children: [Object] }

  # See if a config file already exists (for local files)
  configExists = Fs.existsSync Path.join(project.path, "#{Tool}.json")

  ###

    This portions saves the name of the project to the norma. I wonder
    if there is a way to insert the name at the top. Ordering of keys
    will be needed for more complex initializations as well

  ###
  if configExists

    scaffoldConfig = ReadConfig project.path
    scaffoldConfig.name = name

  else

    scaffoldConfig =
      name: name
      tasks: {}


  if scaffoldConfig.scripts and scaffoldConfig.scripts.preinstall?

    ExecCommand(scaffoldConfig.scripts.preinstall, project.path, ->
      doAfterPreInstall project, scaffoldConfig
    )

  else

    doAfterPreInstall project, scaffoldConfig
