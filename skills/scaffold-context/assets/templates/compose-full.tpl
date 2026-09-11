services:
  back:
    build:
      context: .
      dockerfile: build/Dockerfile
      args:
        SERVICE: back
    env_file: {{ backend_dir }}.env
    environment:
      MONGO_URI: ${MONGO_URI:?Set MONGO_URI reachable from the container}
      APP_PORT: {{ backend_port }}
    ports:
      - "{{ backend_port }}:{{ backend_port }}"
  front:
    build:
      context: .
      dockerfile: build/Dockerfile
      args:
        SERVICE: front
    environment:
      {{ env_prefix }}_FRONT_API_UPSTREAM: back:{{ backend_port }}
    ports:
      - "{{ frontend_container_port }}:80"
