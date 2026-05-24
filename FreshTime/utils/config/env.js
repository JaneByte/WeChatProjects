const API_BASE_URL_MAP = {
  develop: 'http://10.200.52.62:8080/api',
  trial: 'https://unashamed-cursor-drainable.ngrok-free.dev/api',
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
