# Template (envsubst): ${PORT} = porta do nginx, ${{{ env_prefix }}_FRONT_API_UPSTREAM} = host:porta do {{ project_name }}-back.
worker_processes auto;

events {
  worker_connections 1024;
}

http {
  include /etc/nginx/mime.types;
  default_type application/octet-stream;
  sendfile on;
  keepalive_timeout 65;

  gzip on;
  gzip_comp_level 6;
  gzip_types text/plain text/css application/json application/javascript image/svg+xml;

  server {
    listen ${PORT};
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;

    # API do {{ project_name }}-back, same-origin (evita CORS e prepara a camada de auth por proxy).
    location /v1/auth/ {
      access_log off;
      proxy_pass http://${{{ env_prefix }}_FRONT_API_UPSTREAM}/v1/auth/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_read_timeout 60s;
    }

    location /v1/ {
      proxy_pass http://${{{ env_prefix }}_FRONT_API_UPSTREAM}/v1/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_read_timeout 60s;
    }

    location = /runtime-config.js {
      add_header Cache-Control "no-store";
    }

    location = /health {
      access_log off;
      return 200 "OK";
      add_header Content-Type text/plain;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
      expires 1y;
      add_header Cache-Control "public, immutable";
      try_files $uri =404;
    }

    location / {
      try_files $uri $uri/ /index.html;
    }
  }
}
