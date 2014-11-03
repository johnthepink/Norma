Fs = require("fs-extra")
Chalk  = require("chalk")
Flags = require("minimist")( process.argv.slice(2) )

Init = require("./init")
Package = require "./../utilities/package"


module.exports = (tasks, cwd) ->

  args = process.argv.slice(2)

  # remove the need for the flag to be last
  ###

    This seems odd to be needed? Need to explore more
    ~ @jbaxleyiii

  ###
  count = 0
  for argument in args

    if !argument.match /(-|--)package/
      index = args.indexOf argument
      tasks[count] = argument
      count++


  # if you specified a name
  if tasks.length > 1

    dir = if Flags.package then "#{Tool}-#{tasks[1]}" else tasks[1]

    # making directory without exception if exists
    try
      Fs.mkdirSync dir, '0755'
    catch e
      throw e  unless e.code is "EEXIST"

    # After directory is made or found, change to it for the process
    process.chdir dir

    # Make a package
    if Flags.package

      Package tasks, process.cwd()

    # Create a scaffold
    else
      tasks = ["create"]

      Init tasks, process.cwd()

      if not Fs.existsSync('package.json')

        defaultPackageData = {
          name: dir
        }

        Fs.writeFile 'package.json', JSON.stringify(defaultPackageData, null, 2)

  else

    console.log Chalk.red "Please specify a project name"

    process.exit 0



# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: "<name>"
    description: "create a new scaffoled project from name"
  }
  {
    command: "<name> --package"
    description: "create a new package project from name"
  }
]
