(function () {
  'use strict';
  var asy, superagent;

  superagent = require('superagent');

  asy = require('async');

  module.exports = function (ndx) {
    var calculateMilestones, checkCount, checkNew, fetchClientManagementProperties, getDefaultProgressions, webhookCalls;
    let debugInfo = {};
    let processed = {
      commissions: 0
    }
    ndx.database.on('ready', function () {
      /*return ndx.database.select('properties', {
        override: {
          deleted: true
        }
      }, function (props) {
        var j, len, prop, results;
        results = [];
        for (j = 0, len = props.length; j < len; j++) {
          prop = props[j];
          ndx.database["delete"]('properties', {
            _id: prop._id
          });
          results.push(console.log('deleted', prop._id));
        }
        return results;
      });*/
    });
    getDefaultProgressions = function (property) {
      property.progressions = [];
      return ndx.database.select('progressions', {
        isdefault: true
      }, function (progressions) {
        var j, len, progression, results;
        results = [];
        for (j = 0, len = progressions.length; j < len; j++) {
          progression = progressions[j];

          /*
          for milestone in progression.milestones[0]
            milestone.progressing = false
            milestone.completed = true
            milestone.startTime = new Date().valueOf()
            milestone.completedTime = new Date().valueOf()
           */
          results.push(property.progressions.push(JSON.parse(JSON.stringify(progression))));
        }
        return results;
      });
    };
    calculateMilestones = function (property) {
      var b, branch, gotOverdue, j, k, l, len, len1, len2, milestone, p, progression, ref, ref1, updateEstDays;
      if (property.progressions && property.progressions.length) {
        updateEstDays = function (progressions) {
          var aday, b, branch, fetchMilestoneById, i, j, k, l, len, len1, len2, len3, len4, len5, len6, m, milestone, n, needsCompleting, o, prev, progStart, progression, q, ref, results, testMilestone;
          aday = 24 * 60 * 60 * 1000;
          fetchMilestoneById = function (id, progressions) {
            var j, k, l, len, len1, len2, mybranch, mymilestone, myprogression, ref;
            for (j = 0, len = progressions.length; j < len; j++) {
              myprogression = progressions[j];
              ref = myprogression.milestones;
              for (k = 0, len1 = ref.length; k < len1; k++) {
                mybranch = ref[k];
                for (l = 0, len2 = mybranch.length; l < len2; l++) {
                  mymilestone = mybranch[l];
                  if (mymilestone._id === id) {
                    return mymilestone;
                  }
                }
              }
            }
          };
          for (j = 0, len = progressions.length; j < len; j++) {
            progression = progressions[j];
            ref = progression.milestones;
            for (k = 0, len1 = ref.length; k < len1; k++) {
              branch = ref[k];
              for (l = 0, len2 = branch.length; l < len2; l++) {
                milestone = branch[l];
                milestone.estCompletedTime = null;
              }
            }
          }
          needsCompleting = true;
          i = 0;
          while (needsCompleting && i++ < 5) {
            for (m = 0, len3 = progressions.length; m < len3; m++) {
              progression = progressions[m];
              delete progression.needsCompleting;
              progStart = progression.milestones[0][0].completedTime;
              b = 1;
              while (b++ < progression.milestones.length) {
                branch = progression.milestones[b - 1];
                for (n = 0, len4 = branch.length; n < len4; n++) {
                  milestone = branch[n];
                  milestone.overdue = false;
                  milestone.afterTitle = '';
                  if (milestone.estCompletedTime) {
                    continue;
                  }
                  if (milestone.completed && milestone.completedTime) {
                    milestone.estCompletedTime = milestone.completedTime;
                    continue;
                  }
                  if (milestone.userCompletedTime) {
                    try {
                      milestone.estCompletedTime = new Date(milestone.userCompletedTime).valueOf();
                      continue;
                    } catch (undefined) { }
                  }
                  if (!milestone.estAfter) {
                    prev = progression.milestones[b - 2][0];
                    milestone.estCompletedTime = (prev.completedTime || prev.estCompletedTime) + (milestone.estDays * aday);
                    continue;
                  }
                  testMilestone = fetchMilestoneById(milestone.estAfter, progressions);
                  if (testMilestone) {
                    if (milestone.estType === 'complete') {
                      if (testMilestone.completedTime || testMilestone.estCompletedTime) {
                        milestone.estCompletedTime = (testMilestone.completedTime || testMilestone.estCompletedTime) + (milestone.estDays * aday);
                      }
                      milestone.afterTitle = " after " + testMilestone.title + " completed";
                    } else {
                      if (testMilestone.completedTime || testMilestone.estCompletedTime) {
                        milestone.estCompletedTime = (testMilestone.completedTime || testMilestone.estCompletedTime) - (testMilestone.estDays * aday) + (milestone.estDays * aday);
                      }
                      milestone.afterTitle = " after " + testMilestone.title + " started";
                    }
                  } else {
                    progression.needsCompleting = true;
                    b = progression.milestones.length;
                    break;
                  }
                }
              }
            }
            needsCompleting = false;
            for (o = 0, len5 = progressions.length; o < len5; o++) {
              progression = progressions[o];
              if (progression.needsCompleting) {
                needsCompleting = true;
              }
            }
          }
          results = [];
          for (q = 0, len6 = progressions.length; q < len6; q++) {
            progression = progressions[q];
            results.push(delete progression.needsCompleting);
          }
          return results;
        };
        updateEstDays(property.progressions);
        property.milestoneIndex = {};
        gotOverdue = false;
        ref = property.progressions;
        for (p = j = 0, len = ref.length; j < len; p = ++j) {
          progression = ref[p];
          ref1 = progression.milestones;
          for (b = k = 0, len1 = ref1.length; k < len1; b = ++k) {
            branch = ref1[b];
            for (l = 0, len2 = branch.length; l < len2; l++) {
              milestone = branch[l];
              if (milestone.userCompletedTime) {
                milestone.userCompletedTime = new Date(milestone.userCompletedTime).valueOf();
              }
              if (new Date().valueOf() > (milestone.userCompletedTime || milestone.estCompletedTime)) {
                milestone.overdue = true;
                if (p === 0 && milestone.progressing && !gotOverdue) {
                  property.milestone = milestone;
                  gotOverdue = true;
                }
              }
              if (p === 0 && !gotOverdue) {
                if (milestone.completed || milestone.progressing) {
                  property.milestone = milestone;
                }
              }
              if (milestone.completed) {
                property.milestoneIndex[progression._id] = b;
              }
            }
          }
        }
        if (property.milestone) {
          property.milestoneStatus = 'progressing';
          if (property.milestone.overdue) {
            property.milestoneStatus = 'overdue';
          }
          if (property.milestone.completed) {
            property.milestoneStatus = 'completed';
          }
          return property.cssMilestone = {
            completed: property.milestone.completed,
            progressing: property.milestone.progressing,
            overdue: property.milestoneStatus === 'overdue'
          };
        }
      }
    };
    fetchClientManagementProperties = function () {
      debugInfo = {
        updated: 0,
        inserted: 0,
        errors: 0
      };
      return new Promise(function (resolve) {
        console.log('fetching client management', process.env.PROPERTY_URL + "/search");
        var opts;
        opts = {
          RoleStatus: 'InstructionToSell',
          RoleType: 'Selling',
          IncludeStc: true
        };
        return superagent.post(process.env.PROPERTY_URL + "/search")
          .set('Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN)
          .send(opts).end(async function (err, res) {
            var now;
            if (!err && res.body.Collection) {
              now = new Date().getTime();
              debugInfo.time = now;
              debugInfo.col = res.body.Collection.length;
              for (let p = 0; p < res.body.Collection.length; p++) {
                const property = res.body.Collection[p];
                try {
                  property.viewings = await new Promise(res => ndx.dezrez.get('role/{id}/viewings', null, { id: property.RoleId }, (err, body) => res(body)));
                  property.extendedData = await new Promise(res => ndx.dezrez.get('property/{id}', null, { id: property.PropertyId }, (err, body) => res(body)));
                  property.role = await new Promise(res => ndx.dezrez.get('role/{id}', null, { id: property.RoleId }, (err, body) => res(body)));
                  property.vendor = await new Promise(res => ndx.dezrez.get('property/{id}/owners', null, { id: property.PropertyId }, (err, body) => res(body)));
                  //property.rightmove = await new Promise(res => ndx.dezrez.get('stats/rightmove/{id}', null, { id: property.RoleId }, (err, body) => res(body)));
                  property.offers = await new Promise(res => ndx.dezrez.get('role/{id}/offers', null, { id: property.RoleId }, (err, body) => res(body)));
                  if(property.offers) {
                    property.offers.Collection = [];
                  }
                  console.log(property.offers ? property.offers.TotalCount : 'no offers');
                  /*property.events = await new Promise(res => ndx.dezrez.get('role/{id}/events', { pageSize: 200 }, { id: property.RoleId }, (err, body) => res(body)));
                  if(property.events) {
                    property.events.Collection = property.events.Collection.map(event => ({EventType:{Name:event.EventType.Name}}));
                  }*/
                } catch(e) {
                  debugInfo.errors++;
                  debugInfo.errorText = e;
                }
                property.active = true;
                property.now = now;
                const dbprop = await ndx.database.selectOne('clientmanagement', { RoleId: property.RoleId });
                if (dbprop) {
                  property._id = dbprop._id;
                  property.notes = dbprop.notes;
                  await ndx.database.upsert('clientmanagement', property);
                  console.log('updating', property._id);
                  debugInfo.updated++;
                }
                else {
                  property.notes = [];
                  await ndx.database.insert('clientmanagement', property);
                  console.log('inserting', property.RoleId);
                  debugInfo.inserted++
                }
                await new Promise(res => setTimeout(res, 100));
              }
              await ndx.database.delete('clientmanagement', { now: { $lt: now } });
              console.log('finished fetching');
              resolve();
            }
          })
      })
    };
    checkCount = 0;
    checkNew = function () {
      var opts;
      opts = {
        RoleStatus: 'OfferAccepted',
        RoleType: 'Selling',
        IncludeStc: true
      };
      return superagent.post(process.env.PROPERTY_URL + "/search").set('Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN).send(opts).end(function (err, res) {
        console.log('superagent post returned');
        if (!err && res.body.Collection) {
          return asy.eachSeries(res.body.Collection, function (property, callback) {
            return ndx.property.fetch(property.RoleId.toString(), function (mycase) {
              var propClone;
              if (!mycase.progressions || !mycase.progressions.length) {
                ndx.property.getDefaultProgressions(mycase);
                return ndx.database.update('properties', {
                  progressions: mycase.progressions
                }, {
                  _id: mycase._id
                }, function () {
                  return callback();
                });
              } else {
                const role = mycases.role;
                if(role) {
                  if(!role.Commission) {
                    processed.commissionProp = property;
                    if(property && property.Fees && property.Fees.length) {
                      processed.commissions++;
                      const fee = property.Fees[0];
                      if(fee.FeeValueType && fee.FeeValueType.SystemName === 'Absolute') {
                        role.Commission = property.Fees[0].DefaultValue;
                      }
                      else {
                        if(role.AcceptedOffer) {
                          role.Commission = role.AcceptedOffer.Value * (property.Fees[0].DefaultValue / 100);
                        }
                      }
                    }
                  }
                }
                propClone = JSON.stringify(mycase);
                calculateMilestones(mycase);
                if (propClone !== JSON.stringify(mycase)) {
                  mycase.modifiedAt = new Date().valueOf();
                  ndx.database.update('properties', mycase, {
                    _id: mycase._id
                  });
                }
                return callback();
              }
            });
          }, function () {
            return ndx.database.select('properties', {
              delisted: false
            }, function (properties) {
              if (properties && properties.length) {
                return asy.eachSeries(properties, function (property, propCallback) {
                  var foundRole, j, len, prop, ref;
                  foundRole = false;
                  ref = res.body.Collection;
                  for (j = 0, len = ref.length; j < len; j++) {
                    prop = ref[j];
                    if (+property.roleId === +prop.RoleId) {
                      foundRole = true;
                      break;
                    }
                  }
                  if (!foundRole) {
                    ndx.database.update('properties', {
                      delisted: true
                    }, {
                      _id: property._id.toString()
                    });
                  }
                  return propCallback();
                });
              }
            });
          });
        }
      });
    };
    ndx.database.on('ready', function () { 
      //setInterval(fetchClientManagementProperties, 15 * 60 * 1000);
    });
    webhookCalls = 0;
    ndx.app.post('/webhook', function (req, res, next) {
      console.log('WEBHOOK CALLED');
      webhookCalls++;
      checkNew();
      fetchClientManagementProperties();
      return res.end('ok');
    });
    ndx.app.get('/status', function (req, res, next) {
      return res.json({
        webhookCalls: webhookCalls,
        debugInfo: debugInfo,
        processed: processed
      });
    });
    ndx.database.on('preUpdate', function (args, cb) {
      var property;
      if (args.table === 'properties') {
        property = args.obj;
        calculateMilestones(property);
      }
      return cb();
    });
    return ndx.property = {
      getDefaultProgressions: getDefaultProgressions,
      checkNew: checkNew,
      fetch: function (roleId, cb) {
        return ndx.database.select('properties', {
          roleId: roleId.toString()
        }, function (property) {
          var fetchPropertyRole, offerId, ref;
          fetchPropertyRole = function (roleId, property, propcb) {
            return ndx.dezrez.get('role/{id}', null, {
              id: roleId
            }, function (err, body) {
              if (!err) {
                return ndx.dezrez.get('role/{id}', null, {
                  id: body.PurchasingRoleId
                }, function (err, body) {
                  var contact, j, len, ref, ref1, ref10, ref11, ref12, ref13, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9;
                  if (!err) {
                    if (((ref = body.RoleStatus) != null ? ref.SystemName : void 0) !== 'OfferAccepted') {
                      property.badProp = true;
                      return typeof propcb === "function" ? propcb(property) : void 0;
                    }
                    if (property.role && JSON.stringify(property.role) === JSON.stringify(body)) {
                      property.delisted = false;
                      return typeof propcb === "function" ? propcb(property) : void 0;
                    } else {
                      property.delisted = false;
                      property.role = body;
                      property.offer = body.AcceptedOffer;
                      property.purchaser = body.AcceptedOffer.ApplicantGroup.Name;
                      property.purchasersContact = {
                        role: '',
                        name: (ref1 = body.AcceptedOffer.ApplicantGroup.PrimaryMember) != null ? ref1.ContactName : void 0,
                        email: (ref2 = body.AcceptedOffer.ApplicantGroup.PrimaryMember) != null ? (ref3 = ref2.PrimaryEmail) != null ? ref3.Value : void 0 : void 0,
                        telephone: (ref4 = body.AcceptedOffer.ApplicantGroup.PrimaryMember) != null ? (ref5 = ref4.PrimaryTelephone) != null ? ref5.Value : void 0 : void 0
                      };
                      ref6 = body.Contacts;
                      for (j = 0, len = ref6.length; j < len; j++) {
                        contact = ref6[j];
                        property[(contact.ProgressionRoleType.SystemName.toLowerCase()) + "sSolicitor"] = {
                          role: contact.GroupName,
                          name: contact.CaseHandler.ContactName,
                          email: (ref7 = contact.CaseHandler.PrimaryEmail) != null ? ref7.Value : void 0,
                          telephone: (ref8 = contact.CaseHandler.PrimaryTelephone) != null ? ref8.Value : void 0
                        };
                      }
                      property.vendor = body.AcceptedOffer.VendorGroup.Name;
                      property.vendorsContact = {
                        role: '',
                        name: (ref9 = body.AcceptedOffer.VendorGroup.PrimaryMember) != null ? ref9.ContactName : void 0,
                        email: (ref10 = body.AcceptedOffer.VendorGroup.PrimaryMember) != null ? (ref11 = ref10.PrimaryEmail) != null ? ref11.Value : void 0 : void 0,
                        telephone: (ref12 = body.AcceptedOffer.VendorGroup.PrimaryMember) != null ? (ref13 = ref12.PrimaryTelephone) != null ? ref13.Value : void 0 : void 0
                      };
                      return typeof propcb === "function" ? propcb(property) : void 0;
                    }
                  } else {
                    return typeof propcb === "function" ? propcb(null) : void 0;
                  }
                });
              } else {
                return typeof propcb === "function" ? propcb(null) : void 0;
              }
            });
          };
          if (property && property.length) {
            offerId = property[0].offer.Id;
            if (typeof cb === "function") {
              cb(property[0]);
            }
            if (((ref = property[0].override) != null ? ref.deleted : void 0) && property[0].roleId.toString().indexOf('_') === -1) {
              return ndx.database.update('properties', {
                roleId: property[0].roleId + '_' + property[0].offer.Id
              }, {
                roleId: property[0].roleId
              });
            } else if (property[0].modifiedAt + (60 * 60 * 1000) < new Date().valueOf()) {
              return fetchPropertyRole(property[0].roleId, property[0], function (prop) {
                if (prop) {
                  if (prop.offer.Id !== offerId) {
                    if (property[0].delisted) {
                      return ndx.database.update('properties', {
                        roleId: property[0].roleId + '_' + offerId
                      }, {
                        roleId: property[0].roleId
                      });
                    } else {
                      return ndx.database.update('properties', {
                        offer: prop.offer
                      }, {
                        roleId: property[0].roleId
                      });
                    }
                  } else {
                    return ndx.database.update('properties', prop, {
                      _id: prop._id
                    });
                  }
                }
              });
            }
          } else {
            property = {
              roleId: roleId.toString(),
              startDate: new Date().valueOf()
            };
            return fetchPropertyRole(roleId, property, function (property) {
              if (property && !property.badProp) {
                getDefaultProgressions(property);
                property.delisted = false;
                property.milestone = '';
                property.milestoneStatus = '';
                property.milestoneIndex = null;
                property.notes = [];
                property.chainBuyer = [];
                property.chainSeller = [];
                property.delisted = false;
                ndx.database.insert('properties', property);
              }
              return typeof cb === "function" ? cb(property) : void 0;
            });
          }
        });
      }
    };
  };

}).call(this);