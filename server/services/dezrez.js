(function() {
  'use strict';
  var superagent;

  superagent = require('superagent');

  module.exports = function(ndx) {
    var accessToken, envUrls, get, post, refreshToken, tokenExpires, urls;
    if (process.env.REZI_ID && process.env.REZI_SECRET) {
      envUrls = {
        dev: {
          auth: 'https://server.vitalspace.com/dezrez/token/',
          api: 'https://server.vitalspace.com/dezrez/'
        },
        production: {
          auth: 'https://server.vitalspace.com/dezrez/token/',
          api: 'https://server.vitalspace.com/dezrez/'
        },
        live: {
          auth: 'https://server.vitalspace.com/dezrez/token/',
          api: 'https://server.vitalspace.com/dezrez/'
        }
      };
      urls = envUrls[process.env.NODE_ENV || 'dev'];
      accessToken = null;
      tokenExpires = 0;
      refreshToken = function(cb) {
        var authCode, grantType, scopes;
        if (tokenExpires < new Date().valueOf()) {
          authCode = new Buffer(process.env.REZI_ID + ':' + process.env.REZI_SECRET).toString('base64');
          grantType = 'client_credentials';
          scopes = 'event_read event_write people_read people_write property_read property_write impersonate_web_user';
          return superagent.post(urls.auth).set('Authorization', 'Basic ' + authCode).set('Rezi-Api-Version', '1.0').send({
            grant_type: grantType,
            scope: scopes
          }).end(function(err, response) {
            if (!err) {
              accessToken = response.body.access_token;
              tokenExpires = new Date().valueOf() + (6000 * 1000);
            }
            return cb(err);
          });
        } else {
          return cb();
        }
      };
      get = function(route, query, params, callback) {
        var doCallback;
        doCallback = function(err, body) {
          if (Object.prototype.toString.call(params) === '[object Function]') {
            return params(err, body);
          } else if (Object.prototype.toString.call(callback) === '[object Function]') {
            return callback(err, body);
          }
        };
        return refreshToken(function(err) {
          if (!err) {
            if (params) {
              route = route.replace(/\{([^\}]+)\}/g, function(all, key) {
                return params[key];
              });
            }
            query = query || {};
            query.agencyId = process.env.AGENCY_ID || 37;
            console.log('getting:', urls.api + route);
            return superagent.get(urls.api + route).set('Rezi-Api-Version', '1.0').set('Content-Type', 'application/json').set('Authorization', 'Bearer ' + accessToken).query(query).send().end(function(err, response) {
              if (err) {
                return doCallback(err);
              } else {
                return doCallback(null, response.body);
              }
            });
          } else {
            return doCallback(err, []);
          }
        });
      };
      post = function(route, data, params, callback) {
        var doCallback;
        doCallback = function(err, body) {
          if (Object.prototype.toString.call(params) === '[object Function]') {
            return params(err, body);
          } else if (Object.prototype.toString.call(callback) === '[object Function]') {
            return callback(err, body);
          }
        };
        return refreshToken(function(err) {
          if (!err) {
            if (params) {
              route = route.replace(/\{([^\}]+)\}/g, function(all, key) {
                return params[key];
              });
            }
            data = data || {};
            return superagent.post(urls.api + route).set('Rezi-Api-Version', '1.0').set('Content-Type', 'application/json').set('Authorization', 'Bearer ' + accessToken).query({
              agencyId: process.env.AGENCY_ID || 37
            }).send(data).end(function(err, response) {
              return doCallback(err, response != null ? response.body : void 0);
            });
          } else {
            return doCallback(err, []);
          }
        });
      };
      return ndx.dezrez = {
        get: get,
        post: post
      };
    }
  };

}).call(this);
