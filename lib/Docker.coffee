# Docker.coffee
#
#	© 2013 Dave Goehrig <dave@dloh.org>
#

os = require 'os'
spawn = (require 'child_process').spawn

Docker = () ->
	self = this
	exec = (command, args...) ->
		out = ''
		err = ''
		console.log "$ #{command} #{args}"
		proc = spawn(command,args)
		proc.stdout.on 'data', (data) ->
			out = "#{out}#{data}"
		proc.stderr.on 'data', (data) ->
			err = "#{err}#{data}"
		proc.on 'exit', (code) ->
			if code == 0
				console.log out
				self.send [ "ok", out, err ]
			else
				console.log err
				self.send [ "error", "#{code}", err ]
	this.run = (tag) ->
		exec "docker", "run", "-i","-d","-t", tag
	this.start = (container) ->
		exec "docker", "start", container
	this.stop = (container) ->
		exec "docker", "stop", container
	this.restart = (container) ->
		exec "docker", "restart", container
	this.images = () ->
		exec "docker", "images"
	this.ps = () ->
		exec "docker", "ps"
	this.containers = () ->
		exec "docker", "ps", "-a"
	this.remove = (tag) ->
		exec "docker", "rm", tag
	this.remove_image = (tag) ->
		exec "docker", "rmi", tag
	this.pull = (tag) ->
		exec "docker", "pull", tag
	this.push = (tag) ->
		exec "docker", "push", tag
	this.commit = (container,tag) ->
		exec "docker", "commit", container, tag
	this.info = () ->
		exec "docker", "info"

	this["*"] = (message...) ->
		console.log  "Unknown mesage #{JSON.stringify(message)}"

module.exports = Docker
