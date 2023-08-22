const { zonedTimeToUtc, utcToZonedTime, format } = require('date-fns-tz');
(function() {
  module.exports = function(ndx) {
    const millisecondsUntil10am = () => {
      const now = new Date();
      const timeZone = 'Europe/London'; // Time zone for the United Kingdom
    
      // Convert the current time to the UK time zone
      const nowInUKTimeZone = utcToZonedTime(now, timeZone);
    
      const tenAM = new Date(nowInUKTimeZone);
      tenAM.setHours(10, 0, 0, 0);
    
      if (nowInUKTimeZone.getHours() >= 10 || nowInUKTimeZone.getTime() > tenAM.getTime()) {
        tenAM.setDate(tenAM.getDate() + 1);
      }
    
      // Format the dates for display
      const formatOptions = { timeZone, hour: '2-digit', minute: '2-digit' };
      const tenAMString = format(tenAM, 'HH:mm', formatOptions);
      const nowString = format(nowInUKTimeZone, 'HH:mm', formatOptions);
    
      console.log(`The next email will be sent at 10 AM UK time. Current time: ${nowString}, Next email time: ${tenAMString}`);
    
      return tenAM.getTime() - nowInUKTimeZone.getTime();
    };
    ndx.database.on('ready', function() {
      const sendBirthdayEmails = async () => {
        try {
          const now = new Date();
          const date = now.getDate();
          const month = now.getMonth();
          const birthdays = await ndx.database.select('birthdays', {
            where: {
              date, month
            }
          });
          if(birthdays && birthdays.length) {
            birthdays.forEach(async birthday => {
              const age = now.getFullYear() - birthday.year;
              const template = await ndx.database.selectOne('emailTemplates', {
                name: `Birthday ${age} Year${age===1?'':'s'}`
              });
              if(template) {
                template.birthday = birthday;
                template.to = birthday.email;
                ndx.email.send(template);
              }
            })
          }
        }
        catch(e) {
          console.log('birthday error', e);
        }
        setTimeout(sendBirthdayEmails, millisecondsUntil10am());
      }
      setTimeout(sendBirthdayEmails, millisecondsUntil10am());
    });
  }
}).call(this);