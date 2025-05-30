# Learn about building .NET container images:
# https://github.com/dotnet/dotnet-docker/blob/main/samples/README.md
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-noble AS build
ARG TARGETARCH
WORKDIR /source

# Copy project file and restore as distinct layers
COPY --link . .
RUN dotnet restore -a $TARGETARCH && \
    dotnet publish -a $TARGETARCH --no-restore -o /app


# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-noble

RUN apt-get update && \
    apt-get -y --no-install-recommends install libicu-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8080
WORKDIR /app
COPY --link --from=build /app .
ENTRYPOINT ["./SimpleCare.API"]
