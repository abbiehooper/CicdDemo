# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build # Use the official .NET 9.0 SDK image, name it build
WORKDIR /src # Set the working directory inside the container
COPY ["CicdDemo.csproj", "./"] # If the .csproj hasn't changed, Docker reuses the next step instead of re-downloading all packages.
RUN dotnet restore # Restore dependencies
COPY . . # Copy the rest of the application code
RUN dotnet publish -c Release -o /app/publish # Publish the application to the /app/publish folder

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 # Use the official .NET 9.0 ASP.NET runtime image. We only need the runtime to run our already-compiled app.
WORKDIR /app # Sets working directory to /app in this new, smaller image.
COPY --from=build /app/publish . # Copies the compiled app from the "build" stage into this new smaller image.

# Run as non-root user
RUN useradd -m -u 1001 appuser # Creates a new user called "appuser" with user ID 1001.	
USER appuser # Switches to the "appuser" user. This ensures the application runs with non-root privileges, enhancing security.

EXPOSE 8080 # Informs Docker that the container listens on port 8080 at runtime. This does not actually publish the port.
ENV ASPNETCORE_URLS=http://+:8080 # Configures the ASP.NET Core application to listen on port 8080.

ENTRYPOINT ["dotnet", "CicdDemo.dll"] # Sets the command to run the application when the container starts.