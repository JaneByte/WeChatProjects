const { post } = require('./request');

function trackEvent(eventName, payload = {}) {
  if (!eventName) return Promise.resolve();
  return post('/track/event', { eventName, payload }, { retry: 0 })
    .catch(() => null);
}

module.exports = {
  trackEvent
};
