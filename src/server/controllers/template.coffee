'use strict'
fs = require 'fs'

module.exports = (ndx) ->
  emailUpdate = (args) ->
    if args.table is 'emailtemplates'
      fs.writeFile "./views/#{args.id}.jade", args.obj.body, 'utf-8'
  emailDelete = (args) ->
    if args.table is 'emailtemplates'
      try
        fs.unlinkSync "./views/#{args.id}.jade"
  ndx.database.on 'update', emailUpdate
  ndx.database.on 'insert', emailUpdate
  ndx.database.on 'delete', emailDelete
