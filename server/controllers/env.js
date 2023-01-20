(function() {
  'use strict';
  module.exports = function(ndx) {
    return ndx.app.get('/env.js', function(req, res, next) {
      res.header('Content-Type', 'application/javascript');
      return res.end("(function() { 'use strict'; var e, error, module; module = null; try { module = angular.module('ndx'); } catch (error) { e = error; module = angular.module('ndx', []); } module.constant('env', { PROPERTY_URL: '" + process.env.PROPERTY_URL + "', PROPERTY_TOKEN: '" + process.env.PROPERTY_TOKEN + "' }); }).call(this);");
    });
  };

}).call(this);
