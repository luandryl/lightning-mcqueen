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
    ports:
      - "127.0.0.1:{{ backend_port }}:{{ backend_port }}"
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
