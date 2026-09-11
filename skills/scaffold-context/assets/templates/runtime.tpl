// Em Docker, este arquivo é reescrito por /start.sh com os valores reais das envs.
// Em Vite dev, o default aponta para o proxy /v1 do próprio dev server.
window.__APP_CONFIG__ = window.__APP_CONFIG__ || {
  {{ env_prefix }}_FRONT_API_BASE_URL: '/v1',
};
