# Docker.coffee
#
#	© 2013 Dave Goehrig <dave@dloh.org>
#

os = require 'os'
http = require 'http'

crud = (method,self) ->
	(command, path,data) ->
		block = []
		req = http.request { hostname: 'localhost', port: 5678, path: path, method: method, headers: { "Content-Type": "application/json", "Content-Length" : data && data.length || 0 }}, (res) ->
			res.setEncoding 'utf8'
			res.on 'data', (chunk) ->
				block.push(chunk)
			res.on 'end', () ->
				self.send [ command, os.hostname(), res.statusCode, JSON.parse(block.join('')) ]
		if data && data.length
			req.write(data)
		req.end()

Docker = () ->
	self = this
	Get = crud 'GET', self
	Post = crud 'POST', self
	Put = crud 'PUT', self
	Delete = crud 'DELETE', self
	this.run = (tag,cmd,ports,env) ->
		Post "run", "/containers/create", JSON.stringify(
			"Hostname":"",
			"User":"",
			"Memory":0,
			"MemorySwap":0,
			"AttachStdin":true,
			"AttachStdout":true,
			"AttachStderr":true,
			"PortSpecs": ports || null,
			"Privileged": false,
			"Tty":true,
			"OpenStdin":true,
			"StdinOnce":false,
			"Env": env || null,
			"Cmd": cmd || null,
			"Dns":null,
			"Image": tag,
			"Volumes":{},
			"VolumesFrom":"",
			"WorkingDir":"")
	this.start = (container) ->
		Post "start", "/containers/#{container}/start",'{}'
	this.stop = (container) ->
		Post "stop", "/containers/#{container}/stop"
	this.restart = (container) ->
		Post "restart", "/containers/#{container}/restart"
	this.running = () ->
		Get "running", "/containers/json?all=0"
	this.containers = () ->
		Get "containers", "/containers/json?all=1"
	this.info = (container) ->
		Get "info", "/containers/#{container}/json"
	this.top = (container) ->
		Get "top", "/containers/#{container}/top"
	this.changes = (container) ->
		Get "top", "/containers/#{container}/changes"
	this.kill = (container) ->
		Post "kill", "/containers/#{container}/kill"
	this.remove = (tag) ->
		Delete "remove", "/containers/#{tag}"
	this.images = () ->
		Get "images", "/images/json?all=1"
	this.remove_image = (image) ->
		Delete "remove_image", "/images/#{image}"
	this.image_info = (image) ->
		Get "image_info", "/images/#{image}/json"
	this.pull = (image) ->
		Post "pull", "/images/create?fromImage=#{image}"
	this.push = (image,repo) ->
		Post "push", "/images/#{image}/push?registry=#{repo}"
	this.commit = (container,tag,repo,run) ->
		Post "commit", "/commit?container=#{container}&tag=#{tag}&repo=#{repo}&run=#{run}"

	this["*"] = (message...) ->
		console.log  "Unknown mesage #{JSON.stringify(message)}"

module.exports = Docker
