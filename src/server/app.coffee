'use strict'

ndx = require 'ndx-server'
.config
  database: 'vsa'
  tables: ['users', 'properties']
  localStorage: './data'
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
.use require './services/dezrez'
.controller require './controllers/dezrez'
.controller require './controllers/cases'
.start()
