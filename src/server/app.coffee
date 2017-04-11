'use strict'

require 'ndx-server'
.config
  database: 'db'
  tables: ['users', 'properties', 'progressions', 'emailtemplates', 'smstemplates', 'dashboard']
  localStorage: './data'
  hasInvite: true
  hasForgot: true
.start()
