const { zonedTimeToUtc, utcToZonedTime, format } = require('date-fns-tz');

const millisecondsUntilNextWednesdayAt10am = () => {
  const now = new Date();
  const timeZone = 'Europe/London'; // Time zone for the United Kingdom

  // Convert the current time to the UK time zone
  const nowInUKTimeZone = utcToZonedTime(now, timeZone);

  const nextWednesday = new Date(nowInUKTimeZone);
  nextWednesday.setHours(10, 0, 0, 0);

  // Determine the day difference to next Wednesday
  const daysUntilWednesday = (10 - nowInUKTimeZone.getDay()) % 7 || 7;
  nextWednesday.setDate(nextWednesday.getDate() + daysUntilWednesday);

  return nextWednesday.getTime() - nowInUKTimeZone.getTime();
};
module.exports = (ndx) => {
  ndx.database.on('ready', () => {
    const sendEmail = async () => {
      try {
        if(new Date().getDay()===3) {
          const template = await ndx.database.selectOne('emailtemplates', {
            name: 'Auto Reminder - Boards'
          });
          if(template) {
            const users = await ndx.database.select('users');
            if(users && users.length) {
              for(const user of users) {
                if(user.deleted || user.local.email==='superadmin@admin.com') {
                  continue;
                }
                template.to = user.local.email;
                ndx.email.send(template);
              }
            }
          }
        }
      }
      catch(e) {
        console.log('boards reminder error');
      }
      setTimeout(sendEmail, millisecondsUntilNextWednesdayAt10am());
    }
    setTimeout(sendEmail, millisecondsUntilNextWednesdayAt10am());
  })
}