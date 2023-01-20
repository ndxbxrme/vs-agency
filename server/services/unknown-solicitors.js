(function() {
  module.exports = function(ndx) {
    return ndx.database.on('ready', function() {
      var nextSendTime, resetNextSendTime, sendUnknownSolicitorEmails;
      nextSendTime = null;
      sendUnknownSolicitorEmails = function() {
        return ndx.database.select('properties', {
          where: {
            delisted: false
          }
        }, function(properties) {
          var getSolicitor, i, len, myproperties, property, ps, reduce, ref, ref1, ref10, ref11, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9, solicitors, vs;
          solicitors = [];
          myproperties = [];
          reduce = function(name) {
            return (name || 'Unknown').toLowerCase().replace(/solicitor(s*)/g, '').replace(/law|llp/g, '').replace(/ll/g, 'l').replace(/ [a-z] /, '').replace(' & ', '').replace(' and ', '').replace(/\s+/g, '');
          };
          getSolicitor = function(name, sol) {
            var i, len, solicitor;
            for (i = 0, len = solicitors.length; i < len; i++) {
              solicitor = solicitors[i];
              if (reduce(solicitor.name) === reduce(name)) {
                return solicitor;
              }
            }
            solicitor = {
              id: solicitors.length,
              name: name || 'Unknown'
            };
            solicitors.push(solicitor);
            return solicitor;
          };
          for (i = 0, len = properties.length; i < len; i++) {
            property = properties[i];
            ps = getSolicitor((ref = property.purchasersSolicitor) != null ? ref.role : void 0);
            vs = getSolicitor((ref1 = property.vendorsSolicitor) != null ? ref1.role : void 0);
            if (ps.name === 'Unknown' || vs.name === 'Unknown') {
              if (!myproperties.filter(function(item) {
                return item.id === property.roleId;
              }).length) {
                myproperties.push({
                  address: ((ref2 = property.offer) != null ? (ref3 = ref2.Property) != null ? ref3.Address.Number : void 0 : void 0) + " " + ((ref4 = property.offer) != null ? (ref5 = ref4.Property) != null ? ref5.Address.Street : void 0 : void 0) + ", " + ((ref6 = property.offer) != null ? (ref7 = ref6.Property) != null ? ref7.Address.Locality : void 0 : void 0) + ", " + ((ref8 = property.offer) != null ? (ref9 = ref8.Property) != null ? ref9.Address.Town : void 0 : void 0) + ", " + ((ref10 = property.offer) != null ? (ref11 = ref10.Property) != null ? ref11.Address.Postcode : void 0 : void 0),
                  id: property.roleId,
                  purchasingSolicitor: ps.name === 'Unknown',
                  vendingSolicitor: vs.name === 'Unknown'
                });
              }
            }
          }
          if (myproperties.length) {
            if (ndx.email) {
              return ndx.database.select('emailtemplates', {
                name: 'Unknown Solicitors'
              }, function(templates) {
                if (templates && templates.length) {
                  return ndx.database.select('users', {
                    deleted: null
                  }, function(users) {
                    var j, len1, ref12, ref13, results, user;
                    if (users && users.length) {
                      results = [];
                      for (j = 0, len1 = users.length; j < len1; j++) {
                        user = users[j];
                        console.log('sending to', (ref12 = user.local) != null ? ref12.email : void 0);
                        templates[0].unknowns = myproperties;
                        templates[0].user = user;
                        templates[0].to = (ref13 = user.local) != null ? ref13.email : void 0;
                        results.push(ndx.email.send(templates[0]));
                      }
                      return results;
                    }
                  });
                }
              }, true);
            }
          }
        }, true);
      };
      resetNextSendTime = function() {
        nextSendTime = new Date(new Date(new Date().toDateString()).setHours(10));
        return nextSendTime = new Date(nextSendTime.setDate(nextSendTime.getDate() + 1));
      };
      resetNextSendTime();
      nextSendTime = new Date();
      return setInterval(function() {
        var ref;
        if (new Date() > nextSendTime) {
          if ((0 < (ref = nextSendTime.getDay()) && ref < 6)) {
            sendUnknownSolicitorEmails();
          }
          return resetNextSendTime();
        }
      }, 10000);
    });
  };

}).call(this);
