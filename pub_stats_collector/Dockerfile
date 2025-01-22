FROM dart:stable AS build

# Resolve app dependencies.
# The docker build command must be run from the root of the repo
WORKDIR /app/pub_stats_collector
COPY pub_stats_core ../pub_stats_core
RUN sed -i '/resolution: workspace/d' ../pub_stats_core/pubspec.yaml
COPY pub_stats_collector .
RUN sed -i '/resolution: workspace/d' pubspec.yaml
RUN dart pub get

RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/pub_stats_collector/bin/server /app/bin/

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]
