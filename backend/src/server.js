'use strict';

require('dotenv').config();
const app = require('./app');

const PORT = Number(process.env.PORT || 3300);
const HOST = process.env.HOST || '0.0.0.0';

app.listen({ port: PORT, host: HOST })
  .then(() => app.log.info(`Server ready on http://${HOST}:${PORT}`))
  .catch((err) => {
    app.log.error(err);
    process.exit(1);
  });
