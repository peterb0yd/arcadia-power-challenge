const Nightmare = require('nightmare');
const nightmare = Nightmare({ show: true });


nightmare
  .goto('https://www.dominionenergy.com')
  .type('#user', 'justin_doody')
  .type('#password', 'NqjczsbPc6sBzWFaXFtZ')
  .click('#SignIn')
  .wait(5000)
  .evaluate(() => {
    console.log('success!')
  })
  .end()
  .then(console.log)
  .catch(e => {
    console.log('error')
    console.log(e)
  })
