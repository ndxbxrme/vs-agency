(function() {
  module.exports = function(ndx) {
    const millisecondsUntil10am = () => {
      const now = new Date();
      const tenAM = new Date();
      tenAM.setHours(10, 0, 0, 0);
    
      if (now.getHours() >= 10) {
        tenAM.setDate(tenAM.getDate() + 1);
      }
    
      return tenAM.getTime() - now.getTime();
    }
    return ndx.database.on('ready', function() {
      const sendUnknownSolicitorEmails = function() {
        ndx.database.select('properties', {
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
                  return ndx.database.select('users', {sendEmail:true}, function(users) {
                    var j, len1, ref12, ref13, results, user;
                    if (users && users.length) {
                      results = [];
                      for (j = 0, len1 = users.length; j < len1; j++) {
                        user = users[j];
                        if(user.deleted) continue;
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
        setTimeout(sendUnknownSolicitorEmails, millisecondsUntil10am());
      };
      setTimeout(sendUnknownSolicitorEmails, millisecondsUntil10am());
    });
  };

}).call(this);
