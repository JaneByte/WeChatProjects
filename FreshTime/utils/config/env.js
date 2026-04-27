const API_BASE_URL_MAP = {
  develop: 'http://192.168.43.252:8080/api',
  trial: 'http://192.168.43.252:8080/api',
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
