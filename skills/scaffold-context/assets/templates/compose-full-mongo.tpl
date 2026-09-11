services:
  back:
    build:
      context: .
      dockerfile: build/Dockerfile
      args:
        SERVICE: back
    env_file: {{ backend_dir }}.env
    environment:
      MONGO_URI: mongodb://mongo:27017
      APP_PORT: {{ backend_port }}
    depends_on:
      mongo:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "--fail", "--silent", "http://127.0.0.1:{{ backend_port }}/health/ready"]
      interval: 5s
      timeout: 5s
      retries: 12
      start_period: 5s
    ports:
      - "127.0.0.1:{{ backend_port }}:{{ backend_port }}"
  front:
    depends_on:
      back:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--spider", "http://127.0.0.1/health"]
      interval: 5s
      timeout: 5s
      retries: 12
    build:
      context: .
      dockerfile: build/Dockerfile
      args:
        SERVICE: front
    environment:
      {{ env_prefix }}_FRONT_API_UPSTREAM: back:{{ backend_port }}
    ports:
      - "127.0.0.1:{{ frontend_container_port }}:80"
  mongo:
    image: mongo:7.0
    ports:
      - "127.0.0.1:27017:27017"
    volumes:
      - mongo-data:/data/db
    healthcheck:
      test: ["CMD", "mongosh", "--quiet", "--eval", "quit(db.adminCommand('ping').ok ? 0 : 1)"]
      interval: 5s
      timeout: 5s
      retries: 20
      start_period: 10s

volumes:
  mongo-data:
