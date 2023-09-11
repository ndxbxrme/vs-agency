(function() {
  'use strict';
  require('ndx-server').config({
    database: 'db',
    tables: ['users', 'properties', 'progressions', 'emailtemplates', 'smstemplates', 'dashboard', 'targets', 'shorttoken', 'clientmanagement', 'birthdays'],
    localStorage: './data',
    hasInvite: true,
    hasForgot: true,
    serveUploads: true,
    softDelete: true,
    publicUser: {
      _id: true,
      displayName: true,
      local: {
        email: true
      },
      roles: true
    }
  }).use(ndx => {
    ndx.addPublicRoute('/birthday-unsubscribe');
    ndx.app.post('/birthday-unsubscribe', function(req, res, next) {
      try {
        const id = req.body.id;
        ndx.database.delete('birthdays', {_id:id});
      }
      catch(e) {
        console.log('unsub error');
      }
      return res.end('OK');
    })
  }).start();

}).call(this);
