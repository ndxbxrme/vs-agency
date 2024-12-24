const { zonedTimeToUtc, utcToZonedTime, format } = require('date-fns-tz');

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
module.exports = (ndx) => {
  ndx.database.on('ready', () => {
    const sendEmail = async () => {
      if(new Date().getDay()===3) {
        const template = await ndx.database.selectOne('emailtemplates', {
          name: 'Auto Reminder - Boards'
        });
        if(template) {
          const users = await ndx.database.select('users');
          if(users && users.length) {
            for(user of users) {
              template.to = user.local.email;
              ndx.email.send(template);
            }
          }
        }
      }
      setTimeout(sendEmail, millisecondsUntil10am());
    }
    setTimeout(sendEmail, millisecondsUntil10am());
  })
}