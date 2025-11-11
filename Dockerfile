# Build stage
# Use the official .NET 9.0 SDK image, name it build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build 
# Set the working directory inside the container
WORKDIR /src 
# If the .csproj hasn't changed, Docker reuses the next step instead of re-downloading all packages.
COPY ["CicdDemo.csproj", "./"] 
RUN dotnet restore 
# Copy the rest of the application code
COPY . . 
# Publish the application to the /app/publish folder
RUN dotnet publish -c Release -o /app/publish 

# Runtime stage
# Use the official .NET 9.0 ASP.NET runtime image. We only need the runtime to run our already-compiled app.
FROM mcr.microsoft.com/dotnet/aspnet:9.0 
# Sets working directory to /app in this new, smaller image.
WORKDIR /app 
# Copies the compiled app from the "build" stage into this new smaller image.
COPY --from=build /app/publish . 

# Run as non-root user
# Creates a new user called "appuser" with user ID 1001.	
RUN useradd -m -u 1001 appuser 
# Switches to the "appuser" user. This ensures the application runs with non-root privileges, enhancing security.
USER appuser 

# Informs Docker that the container listens on port 8080 at runtime.
EXPOSE 8080 
ENV ASPNETCORE_URLS=http://+:8080

# Sets the command to run the application when the container starts.
ENTRYPOINT ["dotnet", "CicdDemo.dll"] 