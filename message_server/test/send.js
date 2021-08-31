const axios = require('axios')

const send = 'http://127.0.0.1:3000/send';
const sendMulticast = 'https://osbb-messaging-api.herokuapp.com/sendMulticast';
const sendToDevice = 'http://127.0.0.1:3000/sendToDevice';

const herokuServerAddress = 'https://osbb-messaging-api.herokuapp.com/';

emulatorToken = 'd5lZ7gqeQfmsrr2dM6NKoo:APA91bFeeQd1nLdUZU9ubU2c883WFGAgx9CXOSG1Q5kETsAX3w7wbeKcNQec_1vuUBu1IQaXS8R_TMc6WFaLQ20LcBqmCbQ0tspcdwl8CJyPr36_SDNZn7ItosC0bvlnexGidme5gX7-';
phoneToken = 'eg7zK4mDRgWjGdhHULPlnH:APA91bGLwhpa81SYwhpisCvX7fPatcnhrXGAweMEtHwROrV5H1lbAm2lkoRreM9C4OfPVF7i6OCVrQX9aN1sTcmA7MrpG3SilNWlEcfDB6CD5CBfS4gvT1LbE09FOHouhN_1jTv27Ou2';

var sendToDevicemessage = {
  tokens: [emulatorToken],
  message: {
    notification: {
      title: `${new Date().toLocaleString()}`,
      body: `message`,
    },
    data: {
      owner: 'owner'
    }
  },
}

var sendMessage = {
  token: phoneToken,
    notification: {
      title: `${new Date().toLocaleString()}`,
      body: `SEND message`,
    },
  android: {
    priority: 'high'
  } 
}

var sedMulticastMessage = {
  tokens: [phoneToken],
  notification: {
    title: `${new Date().toLocaleString()}`,
    body: `SENDMULTICAST message`,
  },
}

axios
  .post(sendToDevice, 
    sendToDevicemessage
  )
  .then(res => {
    console.log(res.data);
  })
  .catch(error => {
    console.error('Axios post responce error')
  })