'use strict'

angular.module 'vs-agency'
.filter 'hasDocument', ->
  (property, docName) ->
    return if not property
    if property.Documents and property.Documents.length
      for document in property.Documents
        if document.DocumentSubType.DisplayName is docName
          return 'Yes'
    'No'