(function() {
  'use strict';
  module.exports = function(ndx) {
    if (ndx.invite) {
      ndx.invite.fetchTemplate = function(data, cb) {
        return ndx.database.select('emailtemplates', {
          name: 'User Invite'
        }, function(templates) {
          if (templates && templates.length) {
            return cb({
              subject: templates[0].subject,
              body: templates[0].body,
              from: templates[0].from
            });
          } else {
            return cb({
              subject: "You have been invited",
              body: 'h1 invite\np\n  a(href="#{code}")= code',
              from: "System"
            });
          }
        });
      };
    }
    if (ndx.forgot) {
      return ndx.forgot.fetchTemplate = function(data, cb) {
        return ndx.database.select('emailtemplates', {
          name: 'Forgot Password'
        }, function(templates) {
          if (templates && templates.length) {
            return cb({
              subject: templates[0].subject,
              body: templates[0].body,
              from: templates[0].from
            });
          } else {
            return cb({
              subject: "forgot password",
              body: 'h1 forgot password\np\n  a(href="#{code}")= code',
              from: "System"
            });
          }
        });
      };
    }
  };

}).call(this);
