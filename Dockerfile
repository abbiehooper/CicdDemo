# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy only the project file
COPY CicdDemo.csproj .
RUN dotnet restore CicdDemo.csproj

# Copy only the necessary files (not .sln)
COPY Program.cs .
COPY appsettings.json .
COPY appsettings.Development.json .

# Build the PROJECT, not the solution
RUN dotnet publish CicdDemo.csproj -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .

RUN useradd -m -u 1001 appuser
USER appuser

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "CicdDemo.dll"]
