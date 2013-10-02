# Docker.coffee
#
#	© 2013 Dave Goehrig <dave@dloh.org>
#

os = require 'os'
spawn = (require 'child_process').spawn

Docker = () ->
	self = this
	exec = (command, args...) ->
		proc = spawn(command,args)
		proc.stdout.on 'data', (data) ->
			self.send [ "stdout", data ]
		proc.stderr.on 'data', (data) ->
			self.send [ "stdout", data ]
		proc.on 'close', (code) ->
			if code == 0
				self.send [ "ok" ]
			else
				self.send [ "error", code ]
	this.run = (tag) ->
		if tag.match(/^\S+$/)
			exec "docker", "run", "-i","-d","-t", tag
	this.start = (container) ->
		if container.match(/^\S+$/)
			exec "docker", "start", container
	this.stop = (container) ->
		if container.match(/^\S+$/)
			exec "docker", "stop", container
	this.restart = (container) ->
		if container.match(/^\S+$/)
			exec "docker", "restart", container
	this.images = () ->
		exec "docker", "images"
	this.containers = (all) ->
		if all
			exec "docker", "ps", "-a"
		else
			exec "docker", "ps"
	this.remove = (tag) ->
		if tag.match(/^\S+$/)
			exec "docker", "rm", tag
	this.remove_image = (tag) ->
		if tag.match(/^\S+$/)
			exec "docker", "rmi", tag
	this.pull = (tag) ->
		if tag.match(/^\S+$/)
			exec "docker", "pull", tag
	this.push = (tag) ->
		if tag.match(/^\S+$/)
			exec "docker", "push", tag
	this.commit = (container,tag) ->
		if tag.match(/^\S+$/) and container.match(/^\S+$/)
			exec "docker", "commit", container, tag
	this.info = () ->
		exec "docker", "info"

	this["*"] = (message...) ->
		console.log  "Unknown mesage #{JSON.stringify(message)}"

module.exports = Docker
