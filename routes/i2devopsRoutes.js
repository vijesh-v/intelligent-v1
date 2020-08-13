'use strict';
var express = require('express');
var got = require('got');
var log4js = require('log4js');
log4js.loadAppender('file');
var logger = log4js.getLogger('i2devopsRoutes');
logger.setLevel('TRACE');

var router = express.Router();

router.get('/api/v1/i2devops', async (req, res) => {
	try {
		logger.debug("/api/v1/i2devops");

        const options = {
          headers: {
            'St2-Api-Key': "ZTA5OTI4NTAwODg5YTYyMGU2OTYyNjY2MWEzNzA5ZTdhNWEyNzA1YzhmOTc2NzRmOTllN2Q2MjMzMTUyN2UwNw",
          },
	  json: req.body,
          responseType: 'json',
          throwHttpErrors : false
        }
		const stackstormresponse = {
			challenge : req.body.challenge
		};
		res.status(200).send(stackstormresponse);
	}
	catch (err) {
		logger.error("Exception in Serving the Request "+err)
		res.status(500).send("Exception in Serving the Request");
	}
});

router.post('/api/v1/i2devops', async (req, res) => {
	try {
		logger.debug("/api/v1/i2devops");

        const options = {
          headers: {
            'St2-Api-Key': "ZTA5OTI4NTAwODg5YTYyMGU2OTYyNjY2MWEzNzA5ZTdhNWEyNzA1YzhmOTc2NzRmOTllN2Q2MjMzMTUyN2UwNw",
          },
	  json: req.body,
          responseType: 'json',
          throwHttpErrors : false
        }
		const stackstormresponse = await got.post("https://34.69.73.187/api/v1/webhooks/pod_restart", options);
		stackstormresponse.challenge = req.body.challenge;
		res.status(stackstormresponse.statusCode).send(stackstormresponse.body);
	}
	catch (err) {
		logger.error("Exception in Serving the Request "+err)
		res.status(500).send("Exception in Serving the Request");
	}
});

module.exports = router;
