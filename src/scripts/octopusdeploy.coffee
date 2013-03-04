# Description:
#   Interacts with Octopus Deploy's api to create and deploy releases.
#
# Dependencies:
#   "underscore": "1.3.3"
#
# Configuration:
#   HUBOT_OCTOPUSDEPLOY_URL - https://deploy.example.com
#   HUBOT_OCTOPUSDEPLOY_APIKEY - ajkfdjfdksj39k3j4k3j43
#
# Commands:
#   hubot create release <semver> for <project>
#
# Author:
#   jeff-french
_   = require 'underscore'

module.exports = (robot) ->
  hostname = process.env.HUBOT_OCTOPUSDEPLOY_URL
  apiKey   = process.env.HUBOT_OCTOPUSDEPLOY_APIKEY

  projects = []

  getProjects = (msg, callback) ->
    url = "#{hostname}/api/projects"
    msg.http(url)
      .get() (err, res, body) ->
          err = body unless res.statusCode == 200
          projects = JSON.parse(body) unless err
          callback err, msg, projects

  mapNameToProjectId = (msg, name, callback) ->

    execute = (projects) ->
      project = _.find projects, (proj) => return proj.Name == name
      if project
        return project.Id

    result = execute(projects)

    if result
      callback(msg, result)
      return

    getProjects msg, (err, msg, projects) ->
      callback msg, execute(buildTypes)

  robot.respond /create release (\d)+\.(\d)+\.(\d)+\.(\d)+ for (.*)/i, (msg) ->
    version     = msg.match[1]
    projectName = msg.match[2]
    project     = mapNameToProjectId msg, projectName, (msg, project) ->
      if not project
        msg.send "Project #{projectName} was not found."
        return

      url = "#{hostname}/"