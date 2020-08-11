'use strict';

const express = require('express');
const app = express();
var bodyParser = require('body-parser');
var os = require('os');
var cors = require('cors');

var log4js = require('log4js');
log4js.loadAppender('file');
var logger = log4js.getLogger('app');

var routes = require('./routes/i2devopsRoutes');
const appProperties = require('./properties/app-properties');

const port =  appProperties.app_port;

logger.setLevel('TRACE');

app.use(cors());
app.use(bodyParser.urlencoded({extended: true}));

try
{
  app.use(bodyParser.json());

  app.use(routes);


  app.set('port', port);

  app.get('/api/v1/healthcheck', (req, res) => {
    res.status(200).send({
        success: 'true',
        Application_status: "Server Running",
        Running_Port: port,
        Hostname: os.hostname(),
        serviceName : appProperties.serviceName
    })
  });

  var server = app.listen(app.get('port'), function () {
    logger.info(`${appProperties.serviceName} Lisening on Port ${server.address().port}`);
  });

  process.on('SIGTERM', function () {
    logger.info(`Graceful Shutdown`);
    server.close(function () {
            logger.info(`Connection Close`);
            process.exit(0);
    });
  });
}
catch (err)
{
  logger.error(`Exception while Starting Server: ${err}`);
}
