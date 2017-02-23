'use strict'

ndx = require 'ndx-server'
.config
  database: 'vsa'
  tables: ['users', 'properties', 'progressions']
  localStorage: './data'
.use 'ndx-cors'
.use 'ndx-passport'
.use 'ndx-passport-twitter'
.use 'ndx-passport-facebook'
.use 'ndx-user-roles'
.use 'ndx-socket'
.use 'ndx-keep-awake'
.use 'ndx-database-backup'
.use 'ndx-auth'
.use 'ndx-static-routes'
.use 'ndx-superadmin'
.use 'ndx-connect'
.use 'ndx-memory-check'
.use require './services/invite'
.use require './services/dezrez'
.controller require './controllers/dezrez'
.controller require './controllers/cases'
.controller require './controllers/users'
.controller require './controllers/progressions'
.controller (ndx) ->
  ndx.database.on 'ready', ->
    #ndx.database.exec 'DELETE FROM progressions'
.start()
