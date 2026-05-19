const API_BASE_URL_MAP = {
  develop: 'http://10.200.6.174:8080/api',
  trial: 'http://10.200.6.174:8080/api',
  release: 'https://api.freshtime.com/api'
};


const REQUEST_LOG_ENABLE_MAP = {
  develop: true,
  trial: true,
  release: false
};

module.exports = {
  API_BASE_URL_MAP,
  REQUEST_LOG_ENABLE_MAP
};
