###

  This file executes when a user says "norma create/init ...".  A new directory
  has been created for the new norma project and the process has already moved
  to that directory.  This script will gather info about the project from the
  user and then execute the scaffold script.

###


_  = require("lodash")
Inquirer = require("inquirer")
Fs = require("fs-extra")
Chalk = require("chalk")
Path = require("path")
Scaffold = require("./../utilities/scaffold")
MapTree = require("./../utilities/directory-tools").mapTree
RemoveTree = require("./../utilities/directory-tools").removeTree


doInit = (scaffoldNames, scaffolds) ->

  Inquirer.prompt([
    {
      type: "list"
      message: "What type of project do you want to build?"
      name: "scaffold"
      choices: scaffoldNames
    }
    {
      type: "input"
      message: "What do you want your project to be named?"
      name: "project"
      default: "My Awesome Project"
    }
    ],
    (answer) ->

      # Faster filter method
      projects = (p for p in scaffolds.children when p.name is answer.scaffold)

      # Use first match if one was found
      if projects.length

        Scaffold projects[0], answer.project
        return

      console.log(
        Chalk.red 'That scaffold was not found. Try "norma list --scaffold"'
      )
  )


module.exports = (tasks, cwd) ->

  # cwd = path where norma package to be init'ed (same as process cwd)
  # tasks = [ 'create', <appName> ] - flags are not included in the array

  # __dirname is this script files' directory
  scaffolds = MapTree Path.join __dirname, "/../../scaffolds"

  # Add in custom option to list of scaffolds available
  scaffolds.children.push custom =
    path: process.cwd()
    name: 'custom'
    type: 'folder'
    children: []

  # Create list of scaffold names for prompt
  scaffoldNames = (scaffold.name for scaffold in scaffolds.children)

  # Generate list of current files in directory (auto excludes "." and "..")
  cwdIsEmpty = (Fs.readdirSync cwd).length is 0

  # Failsafe to make sure project is empty on creation of new folder
  if (not cwdIsEmpty) and (tasks[0] isnt 'init')

    Inquirer.prompt
      type: "confirm"
      message: "Initializing will empty the current directory. Continue?"
      name: "override"
      default: false
    , (answer) ->

      if answer.override

        # Make really really sure that the user wants this
        Inquirer.prompt
          type: "confirm"
          message: "Removed files are gone forever. Continue?"
          name: "overridconfirm"
          default: false
        , (answer) ->

          if answer.overridconfirm

            # Clean up directory
            console.log Chalk.grey("Emptying current directory")
            RemoveTree cwd, true
            doInit scaffoldNames, scaffolds

          else
            process.exit 0

      else
        process.exit 0

  else

    doInit scaffoldNames, scaffolds


# API ----------------------------------------------------------------------

module.exports.api = [
  {
    command: ""
    description: "initalize a directory as a #{Tool} project"
  }
]
