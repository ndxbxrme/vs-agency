(function() {
  'use strict';
  var superagent;

  superagent = require('superagent');

  module.exports = function(ndx) {
    var calculateMilestones, fetchContacts, getDefaultProgressions, processActions;
    fetchContacts = function(action, property) {
      var contact, contacts, j, len, negotiator, ref;
      contacts = [];
      if (action.specificUser) {
        ndx.database.select('users', {
          _id: action.specificUser
        }, function(res) {
          if (res && res.length) {
            return contacts.push({
              email: res[0].email || res[0].local.email
            });
          }
        });
      } else {
        ref = action.to;
        for (j = 0, len = ref.length; j < len; j++) {
          contact = ref[j];
          console.log('contact', contact);
          if (contact.indexOf('all') === 0) {
            if (contact === 'negotiator') {
              negotiator = property["case"].offer.Negotiators[0];
              contacts.push({
                name: negotiator.ContactName,
                role: negotiator.JobTitle,
                email: negotiator.PrimaryEmail.Value,
                telephone: negotiator.PrimaryTelephone.Value
              });
            }
            if (contact === 'allagency') {
              ndx.database.select('users', {sendEmail:true}, function(res) {
                var k, len1, results, user;
                if (res && res.length) {
                  results = [];
                  for (k = 0, len1 = res.length; k < len1; k++) {
                    user = res[k];
                    if(!user.deleted && user.local && user.local.sites && user.local.sites.main && user.local.sites.main.role && user.local.sites.main.role==='agency') {
                      results.push(contacts.push({
                        name: user.displayName || user.local.email,
                        role: 'Agency',
                        email: user.email || user.local.email,
                        telephone: user.telephone
                      }));
                    } else {
                      results.push(void 0);
                    }
                  }
                  return results;
                }
              });
            }
            if (contact === 'alladmin') {
              ndx.database.select('users', {sendEmail:true}, function(res) {
                var k, len1, results, user;
                if (res && res.length) {
                  results = [];
                  for (k = 0, len1 = res.length; k < len1; k++) {
                    user = res[k];
                    console.log('checking', user);
                    if(!user.deleted && user.local && user.local.sites && user.local.sites.main 
                      && user.local.sites.main.role && ['superadmin', 'admin'].includes(user.local.sites.main.role) 
                      && user.local.email && user.local.email!=='superadmin@admin.com') {
                      results.push(contacts.push({
                        name: user.displayName || user.local.email,
                        role: 'Admin',
                        email: user.email || user.local.email,
                        telephone: user.telephone
                      }));
                    } else {
                      results.push(void 0);
                    }
                  }
                  return results;
                }
              });
            }
          } else {
            if (property["case"][contact]) {
              contacts.push(property["case"][contact]);
            } else {
              console.log('could not find contact', contact);
            }
          }
          console.log('contacts', contacts);
        }
      }
      return contacts;
    };
    processActions = async function(actionOn, actions, roleId, property) {
      var action, branch, contacts, isStarted, j, len, milestone, progression, results;
      if (actions && actions.length) {
        if (!property) {
          return superagent.get(process.env.PROPERTY_URL + "/property/" + roleId).set('Authorization', 'Bearer ' + process.env.PROPERTY_TOKEN).send().end(function(err, res) {
            if (!err) {
              property = res.body;
              return ndx.property.fetch(roleId, function(mycase) {
                property["case"] = mycase;
                return processActions(actionOn, actions, roleId, property);
              });
            } else {
              throw err;
            }
          });
        } else {
          results = [];
          for (j = 0, len = actions.length; j < len; j++) {
            action = actions[j];
            if (action.on === actionOn) {
              switch (action.type) {
                case 'Trigger':
                  results.push((function() {
                    var k, len1, ref, results1;
                    ref = property["case"].progressions;
                    results1 = [];
                    for (k = 0, len1 = ref.length; k < len1; k++) {
                      progression = ref[k];
                      results1.push((function() {
                        var l, len2, ref1, results2;
                        ref1 = progression.milestones;
                        results2 = [];
                        for (l = 0, len2 = ref1.length; l < len2; l++) {
                          branch = ref1[l];
                          results2.push((function() {
                            var len3, m, results3;
                            results3 = [];
                            for (m = 0, len3 = branch.length; m < len3; m++) {
                              milestone = branch[m];
                              if (milestone._id === action.milestone) {
                                if (action.triggerAction === 'complete') {
                                  if (!milestone.completed) {
                                    isStarted = milestone.startTime;
                                    milestone.completed = true;
                                    milestone.progressing = false;
                                    milestone.completedTime = new Date().valueOf();
                                    if (!isStarted) {
                                      milestone.startTime = new Date().valueOf();
                                    }
                                    ndx.database.update('properties', property["case"], {
                                      _id: property["case"]._id
                                    });
                                    if (!isStarted) {
                                      processActions('Start', milestone.actions, roleId, property);
                                    }
                                    results3.push(processActions('Complete', milestone.actions, roleId, property));
                                  } else {
                                    results3.push(void 0);
                                  }
                                } else {
                                  if (!milestone.startTime) {
                                    milestone.progressing = true;
                                    milestone.startTime = new Date().valueOf();
                                    ndx.database.update('properties', property["case"], {
                                      _id: property["case"]._id
                                    });
                                    results3.push(processActions('Start', milestone.actions, roleId, property));
                                  } else {
                                    results3.push(void 0);
                                  }
                                }
                              } else {
                                results3.push(void 0);
                              }
                            }
                            return results3;
                          })());
                        }
                        return results2;
                      })());
                    }
                    return results1;
                  })());
                  break;
                case 'Email':
                  contacts = fetchContacts(action, property);
                  let template = await ndx.database.selectOne('emailtemplates', {_id: action.template});
                  if(template) {
                    if(property.pipeline) {
                      let pipelineTemplate = await ndx.database.selectOne('emailtemplates', {name:`${property.pipeline}:${template.name}`});
                      if(pipelineTemplate) {
                        template = pipelineTemplate;
                        for(let k = 0; k < contacts.length; k++) {
                          const contact = contacts[k];
                          if(contact && contact.email && template.subject && template.body && template.from) {
                            if(process.env.EMAIL_OVERRIDE) {
                              template.subject = `${template.subject} <${contact.email}>`;
                            }
                            ndx.email.send({
                              to: contact.email,
                              subject: template.subject,
                              body: template.body,
                              from: template.from,
                              contact: contact,
                              property: property
                            })
                          }
                        }
                      }
                    }
                  }
                  break;
                case 'Sms':
                  contacts = fetchContacts(action, property);
                  results.push(ndx.database.select('smstemplates', {
                    _id: action.template
                  }, function(res) {
                    var contact, k, len1, results1;
                    if (res && res.length) {
                      results1 = [];
                      for (k = 0, len1 = contacts.length; k < len1; k++) {
                        contact = contacts[k];
                        results1.push(ndx.sms.send({
                          originator: 'VitalSpace',
                          numbers: [contact.telephone],
                          body: res[0].body
                        }, {
                          contact: contact,
                          property: property
                        }));
                      }
                      return results1;
                    }
                  }));
                  break;
                default:
                  results.push(void 0);
              }
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      }
    };
    getDefaultProgressions = function(property) {
      property.progressions = [];
      return ndx.database.select('progressions', {
        isdefault: true
      }, function(progressions) {
        var j, len, progression, results;
        results = [];
        for (j = 0, len = progressions.length; j < len; j++) {
          progression = progressions[j];
          if(progression.deleted) continue;
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
    calculateMilestones = function(property) {
      var b, branch, gotOverdue, j, k, l, len, len1, len2, milestone, p, progression, ref, ref1, updateEstDays;
      if (property.progressions && property.progressions.length) {
        updateEstDays = function(progressions) {
          var aday, b, branch, fetchMilestoneById, i, j, k, l, len, len1, len2, len3, len4, len5, len6, m, milestone, n, needsCompleting, o, prev, progStart, progression, q, ref, results, testMilestone;
          aday = 24 * 60 * 60 * 1000;
          fetchMilestoneById = function(id, progressions) {
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
                    } catch (undefined) {}
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
    return ndx.milestone = {
      processActions: processActions,
      getDefaultProgressions: getDefaultProgressions,
      calculateMilestones: calculateMilestones
    };
  };

}).call(this);
