(function() {
  'use strict';
  var objtrans;

  objtrans = require('objtrans');

  module.exports = function(ndx) {
    var transform, transforms;
    transform = function(args, cb) {
      var i, j, len, mytransform, obj, ref;
      if (args.transformer && (mytransform = transforms[args.transformer])) {
        mytransform._id = true;
        ref = args.objs;
        for (i = j = 0, len = ref.length; j < len; i = ++j) {
          obj = ref[i];
          args.objs[i] = objtrans(obj, mytransform);
        }
      }
      return cb(true);
    };
    setImmediate(function() {
      return ndx.database.on('selectTransform', transform);
    });
    return transforms = {
      "dashboard/properties": {
        "override": true,
        "progressions": true,
        "displayAddress": function(obj) {
          if(!obj || !obj.offer || !obj.offer.Property || !obj.offer.Property.Address) return 'Bad address';
          return obj.offer.Property.Address.Number + " " + obj.offer.Property.Address.Street + ", " + obj.offer.Property.Address.Locality + ", " + obj.offer.Property.Address.Town + ", " + obj.offer.Property.Address.Postcode;
        },
        "milestoneIndex": true,
        "role": true,
        "roleId": true,
        "purchasersSolicitor": true,
        "vendorsSolicitor": true,
        "pipeline": true,
        "consultant": true
      }
    };
  };

}).call(this);
