(function() {
  'use strict';
  module.exports = function(ndx) {
    ndx.app.post('/api/milestone/start', ndx.authenticate(), function(req, res, next) {
      var actions;
      actions = [
        {
          on: 'Start',
          type: 'Trigger',
          triggerAction: '',
          milestone: req.body.milestone
        }
      ];
      ndx.milestone.processActions('Start', actions, req.body.roleId);
      return res.end('OK');
    });
    return ndx.app.post('/api/milestone/completed', ndx.authenticate(), function(req, res, next) {
      var actions;
      actions = [
        {
          on: 'Complete',
          type: 'Trigger',
          triggerAction: 'complete',
          milestone: req.body.milestone
        }
      ];
      ndx.milestone.processActions('Complete', actions, req.body.roleId);
      return res.end('OK');
    });
  };

}).call(this);
