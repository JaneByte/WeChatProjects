const API_BASE_URL_MAP = {
  develop: 'http://10.200.66.177:8080/api',
  trial: 'http://10.200.66.177:8080/api',
  release: 'http://10.200.66.177:8080/api'
};


const REQUEST_LOG_ENABLE_MAP = {
  develop: true,
  trial: true,
  release: true
};

module.exports = {
  API_BASE_URL_MAP,
  REQUEST_LOG_ENABLE_MAP
};
