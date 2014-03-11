# Docker.coffee
#
#	© 2013 Dave Goehrig <dave@dloh.org>
#

os = require 'os'
http = require 'http'

crud = (method,self) ->
	(command, hostname, path, data) ->
		block = []
		req = http.request { hostname: hostname, port: 5678, path: path, method: method, headers: { "Content-Type": "application/json", "Content-Length" : data && data.length || 0 }}, (res) ->
			res.setEncoding 'utf8'
			res.on 'data', (chunk) ->
				block.push(chunk)
			res.on 'end', () ->
				console.log 'sending', [ 'docker', command, os.hostname(), res.statusCode, JSON.parse(block.join('')) ]
				self.send [ 'docker', command, os.hostname(), res.statusCode, JSON.parse(block.join('')) ]
		if data && data.length
			req.write(data)
		req.end()

Docker = () ->
	self = this
	Get = crud 'GET', self
	Post = crud 'POST', self
	Put = crud 'PUT', self
	Delete = crud 'DELETE', self
	this.run = (hostname,tag,cmd,ports,env,dns) ->
		Post "run", hostname, "/containers/create", JSON.stringify(
			"Hostname": hostname || "",
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
			"Dns": dns || null,
			"Image": tag,
			"Volumes":{},
			"VolumesFrom":"",
			"WorkingDir":"")
	this.start = (hostname, container) ->
		Post "start", hostname "/containers/#{container}/start",'{}'
	this.stop = (hostname, container) ->
		Post "stop", hostname, "/containers/#{container}/stop"
	this.restart = (hostname, container) ->
		Post "restart", hostname, "/containers/#{container}/restart"
	this.running = (hostname) ->
		Get "running", hostname, "/containers/json?all=0"
	this.containers = (hostname) ->
		Get "containers", hostname, "/containers/json?all=1"
	this.info = (hostname,container) ->
		Get "info", hostname,"/containers/#{container}/json"
	this.top = (hostname,container) ->
		Get "top", hostname, "/containers/#{container}/top"
	this.changes = (hostname,container) ->
		Get "top", hostname, "/containers/#{container}/changes"
	this.kill = (hostname,container) ->
		Post "kill", hostname, "/containers/#{container}/kill"
	this.remove = (hostname, tag) ->
		Delete "remove", hostname, "/containers/#{tag}"
	this.images = (hostname) ->
		Get "images", hostname, "/images/json?all=1"
	this.remove_image = (hostname, image) ->
		Delete "remove_image", hostname, "/images/#{image}"
	this.image_info = (hostname, image) ->
		Get "image_info", hostname, "/images/#{image}/json"
	this.pull = (hostname, image) ->
		Post "pull", hostname, "/images/create?fromImage=#{image}"
	this.push = (hostname, image,repo) ->
		Post "push", hostname, "/images/#{image}/push?registry=#{repo}"
	this.commit = (hostname, container,tag,repo,run) ->
		Post "commit", hostname, "/commit?container=#{container}&tag=#{tag}&repo=#{repo}&run=#{run}"

	this["*"] = (message...) ->
		console.log  "Unknown mesage #{JSON.stringify(message)}"

module.exports = Docker
