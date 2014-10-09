
Path = require "path"
Multimatch = require "multimatch"
Findup = require "findup-sync"

MapTree = require("./directory-tools").mapTree
ReadConfig = require "./read-config"

arrayify = (el) ->
	(if Array.isArray(el) then el else [el])


camelize = (str) ->
	str.replace /-(\w)/g, (m, p1) ->
		p1.toUpperCase()


requireFn = (cwd) ->

	return require cwd





module.exports = (tasks, cwd) ->

	normaConfig = ReadConfig process.cwd()
	packageList = new Array
	packages = new Array

	mapPkge = (pkgeCwd) ->

		task = requireFn pkgeCwd

		taskObject = task normaConfig, Path.resolve(__dirname, '../../')
		taskObject = null

		packages.push task.tasks



	if cwd.match /norma-packages/

		customs = MapTree cwd
		for custom in customs.children

			for pkge in custom.children

				if pkge.name.match /package[.](js|coffee)/
					mapPkge pkge.path

	else

		pattern = arrayify([
			"#{Tool}-*"
			"#{Tool}.*"
		])

		config = Findup "package.json", cwd: cwd

		node_modules = Findup "node_modules", cwd: cwd

		scope = arrayify([
			"dependencies"
			"devDependencies"
			"peerDependencies"
		])

		replaceString = /^norma(-|\.)/

		config = require(config)

		if !config
			console.log(
				Chalk.red("Could not find dependencies." +
				" Do you have a package.json file in your project?"
				)
			)

		names = scope.reduce(
			(result, prop) ->
		  	result.concat Object.keys(config[prop] or {})
			[]
		)

		Multimatch(names, pattern).forEach (name) ->

			packageList.push Path.resolve(node_modules, name)

			return

		for pkge in packageList
			packageList[pkge] = mapPkge pkge


	return packages