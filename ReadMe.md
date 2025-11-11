# How to build a CI/CD Pipeline with Health Checks and Monitoring

## Step 1: 

- Create your application
- Add health checks and monitoring via the [Program.cs](https://github.com/abbiehooper/CicdDemo/blob/master/Program.cs)

**Test it:**
```powershell
dotnet run
# Visit http://localhost:5000
# Visit http://localhost:5000/health
```

## Step 2:
- Dockerize it [Dockerfile Example](https://github.com/abbiehooper/CicdDemo/blob/master/Dockerfile)
- Add a [.dockerignore](https://github.com/abbiehooper/CicdDemo/blob/master/.dockerignore) file

**Test it:** 
```powershell
# Build the Docker image
docker build -t cicd-demo:local .

# Run the container
docker run -p 8080:8080 cicd-demo:local

# Test the health endpoint (PowerShell equivalent)
Invoke-WebRequest http://localhost:8080/health
```