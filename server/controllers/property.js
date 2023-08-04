(function() {
  'use strict';
  var marked, progress, superagent;

  superagent = require('superagent');

  progress = require('progress');

  marked = require('marked');

  module.exports = function(ndx) {
    ndx.app.get('/api/properties/reset-progressions', ndx.authenticate(['admin', 'superadmin']), function(req, res, next) {
      return ndx.database.select('properties', null, function(properties) {
        var i, len, property;
        if (properties && properties.length) {
          for (i = 0, len = properties.length; i < len; i++) {
            property = properties[i];
            ndx.database.update('properties', {
              progressions: [],
              milestone: '',
              milestoneIndex: '',
              milestoneStatus: '',
              cssMilestone: ''
            }, {
              _id: property._id
            });
          }
          ndx.property.checkNew();
        }
        return res.end('OK');
      });
    });
    ndx.app.post('/api/properties/advance-progression', ndx.authenticate(), function(req, res, next) {
      var advanceRequest, advanceTo, branch, i, j, k, l, len, len1, len2, len3, milestone, milestones, noDays, progression, ref, ref1, text;
      milestones = [];
      if (req.body.milestone) {
        milestones.push(req.body.milestone);
      } else {
        ref = req.body.property.progressions;
        for (i = 0, len = ref.length; i < len; i++) {
          progression = ref[i];
          ref1 = progression.milestones;
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            branch = ref1[j];
            for (k = 0, len2 = branch.length; k < len2; k++) {
              milestone = branch[k];
              if (milestone.progressing && milestone.overdue) {
                milestones.push(milestone);
              }
            }
          }
        }
      }
      advanceTo = req.body.advanceTo;
      if (advanceTo) {
        advanceTo = new Date(advanceTo);
      } else {
        noDays = +req.body.noDays;
        advanceTo = new Date();
        advanceTo.setDate(advanceTo.getDate() + noDays);
      }
      text = "## Advance Progression Request  \n#### Milestone" + (milestones.length > 1 ? 's' : '') + "  \n";
      for (l = 0, len3 = milestones.length; l < len3; l++) {
        milestone = milestones[l];
        text += "`" + milestone.title + "`  \n";
      }
      text += "#### Advance to  \n`" + (advanceTo.toDateString()) + "`  \n";
      text += "#### Requested by  \n`" + (ndx.user.displayName || ndx.user.local.email) + "`  \n";
      text += "#### Reason  \n" + req.body.reason + "  \n";
      advanceRequest = {
        milestones: milestones,
        user: ndx.user,
        roleId: req.body.property.roleId,
        link: req.protocol + "://" + req.hostname + "/case/" + req.body.property.roleId,
        displayAddress: req.body.property.displayAddress,
        advanceTo: advanceTo.valueOf(),
        text: text,
        reason: req.body.reason,
        date: new Date()
      };
      if (ndx.email) {
        ndx.database.select('emailtemplates', {
          name: 'Advance Progression'
        }, function(templates) {
          if (templates && templates.length) {
            return ndx.database.select('users', {
			  sendEmail: true,
              roles: {
                admin: {
                  $nnull: true
                }
              }
            }, function(users) {
              var len4, m, results, user;
              if (users && users.length) {
                results = [];
                for (m = 0, len4 = users.length; m < len4; m++) {
                  user = users[m];
                  Object.assign(templates[0], advanceRequest);
                  templates[0].to = users[0].local.email;
                  templates[0].text = marked(templates[0].text);
                  results.push(ndx.email.send(templates[0]));
                }
                return results;
              }
            });
          }
        });
      }
      if (!req.body.property.advanceRequests) {
        req.body.property.advanceRequests = [];
      }
      req.body.property.advanceRequests.push(advanceRequest);
      ndx.database.update('properties', {
        advanceRequests: req.body.property.advanceRequests
      }, {
        roleId: req.body.property.roleId.toString()
      });
      return res.end('OK');
    });
    ndx.app.post('/api/properties/send-new-sales-email', ndx.authenticate(), function(req, res, next) {
      var user;
      if (ndx.email) {
        user = ndx.user;
        ndx.database.select('users', {sendEmail:true}, function(users) {
          var i, len, results;
          results = [];
          const template = req.body.template ? req.body.template : 'Sales';
          for (i = 0, len = users.length; i < len; i++) {
            user = users[i];
            results.push(ndx.database.select('emailtemplates', {
              name: `New ${template} Instruction Email`
            }, function(templates) {
              var ref;
              if (templates && templates.length) {
                templates[0].newSales = req.body.newSales;
                templates[0].user = user;
                templates[0].to = (ref = user.local) != null ? ref.email : void 0;
                return ndx.email.send(templates[0]);
              }
            }));
          }
          return results;
        });
      }
      return res.end('OK');
    });
    ndx.app.post('/api/properties/send-new-lettings-email', ndx.authenticate(), async function(req, res, next) {
      var user;
      if (ndx.email) {
        user = ndx.user;
        const templateName = req.body.template ? req.body.template : 'Lettings';
        const template = await ndx.database.selectOne('emailtemplates', {name: `New ${templateName} Instruction Email`});
        if(template) {
          template.newLettings = req.body.newLettings;
          template.user = user;
          template.to = 'lettings@vitalspace.co.uk';
          ndx.email.send(template);
        }
      }
      return res.end('OK');
    });
    ndx.app.post('/api/properties/send-reduction-email', ndx.authenticate(), function(req, res, next) {
      var user;
      if (ndx.email) {
        user = ndx.user;
        ndx.database.select('users', {sendEmail:true}, function(users) {
          var i, len, results;
          results = [];
          for (i = 0, len = users.length; i < len; i++) {
            user = users[i];
            results.push(ndx.database.select('emailtemplates', {
              name: 'Price Reduction Email'
            }, function(templates) {
              var ref;
              if (templates && templates.length) {
                templates[0].reduction = req.body.reduction;
                templates[0].user = user;
                templates[0].to = (ref = user.local) != null ? ref.email : void 0;
                return ndx.email.send(templates[0]);
              }
            }));
          }
          return results;
        });
      }
      return res.end('OK');
    });
    ndx.app.get('/api/properties/:roleId', ndx.authenticate(), function(req, res, next) {
      return ndx.property.fetch(req.params.roleId, function(property) {
        return res.json(property);
      });
    });
    ndx.app.get('/api/properties/:roleId/progressions', ndx.authenticate(), function(req, res, next) {
      return ndx.database.select('properties', {
        roleId: req.params.roleId
      }, function(properties) {
        if (properties && properties.length) {
          return res.json(properties[0].progressions);
        } else {
          return res.json([]);
        }
      });
    });
    ndx.app.post('/webhook', function(req, res, next) {
      return res.end('hi');
    });
    return ndx.database.on('ready', function() {
      if (!ndx.database.count('properties')) {
        console.log('building database');
        return superagent.post(process.env.PROPERTY_URL + "/search").set('Content-Type', 'application/json').set('Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN).send({
          RoleStatus: 'OfferAccepted',
          RoleType: 'Selling',
          IncludeStc: true
        }).end(function(err, response) {
          var bar, fetchProp;
          console.log('building property database');
          if (!err && response && response.body) {
            bar = new progress('  downloading [:bar] :percent :etas', {
              complete: '=',
              incomplete: ' ',
              width: 20,
              total: response.body.Collection.length
            });
            fetchProp = function(index) {
              bar.tick(1);
              if (index < response.body.Collection.length) {
                return ndx.property.fetch(response.body.Collection[index].RoleId, function() {
                  return fetchProp(++index);
                });
              } else {
                return console.log('\ndatabase build complete');
              }
            };
            return fetchProp(0);
          }
        });
      }
    });
  };

}).call(this);
