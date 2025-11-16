# How to build a CI/CD Pipeline with Health Checks and Monitoring

# How to build a CI/CD Pipeline with Health Checks and Monitoring

## Table of Contents
- [Step 1: Create Your Application](#step-1)
- [Step 2: Dockerize](#step-2)
- [Step 3: GitHub Actions](#step-3)
- [Step 4: Set up a Server](#step-4)
- [Step 5: GitHub Secrets](#step-5)
- [Step 6: Deploy](#step-6-deploy)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:
- [.NET 9.0 SDK](https://dotnet.microsoft.com/download) installed
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- A GitHub account

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

For step 2, ensure you have Docker installed on your machine.

- Dockerize it [Dockerfile Example](https://github.com/abbiehooper/CicdDemo/blob/master/Dockerfile)
- Add a [.dockerignore](https://github.com/abbiehooper/CicdDemo/blob/master/.dockerignore) file

**Test it:** 
```powershell
# Build the Docker image
docker build -t cicd-demo:local .

# Run the container
docker run -p 8080:8080 cicd-demo:local

# Test the health 
Invoke-WebRequest http://localhost:8080/health
```

## Step 3: 

Use GitHub Actions to create a CI/CD pipeline

### What is GitHub Actions?

GitHub Actions is a CI/CD tool built into GitHub. When you push code, it can automatically:

- Build your application
- Run tests
- Build Docker images
- Deploy to servers or cloud platforms

### Create a GitHub Actions Workflow

- Create a `.github/workflows` directory in your repository
- Add a workflow YAML file, e.g., [deploy.yml](https://github.com/abbiehooper/CicdDemo/blob/master/.github/workflows/deploy.yml)


## Step 4: Set up a Server

You can use any server that supports Docker. For this example, we'll use a simple Ubuntu server.
I chose to set this up on Azure, but you can also use other cloud providers like AWS, DigitalOcean or Akamai.
You can also use a local VM or Raspberry Pi, this is free but must always be online to receive deployments.

If you do not want to deploy to a server, you can skip this step and modify the GitHub Actions workflow to deploy to a container registry instead.

## Step 5: Set up GitHub Secrets

Generate a SSH key pair for secure access to your server:

```powershell
ssh-keygen -t ed25519 -C "github-actions" -f github-actions-key

# This creates two files:
# github-actions-key       <- Private key (keep secret!)
# github-actions-key.pub   <- Public key (Add this key to your server)
```
Press Enter to accept the default file location and leave the passphrase empty.
GitHub Actions is an automated system - there's no human to type in a passphrase when it runs. 
If you add a passphrase, the workflow will fail because it can't interactively ask for it.

- Go to your GitHub repository
- Settings → Secrets and variables → Actions
- Click "New repository secret"

Add these secrets to GitHub (Settings → Secrets):

- **DEPLOY_HOST** - Your server IP
- **DEPLOY_USER** - SSH username
- **DEPLOY_SSH_KEY** - github-actions-key 

To get the private key content, run:

```powershell
Get-Content github-actions-key | Set-Clipboard
```
Paste it into the "Value" field when creating the secret.

Make sure to add the github-actions-key files to your .gitignore to avoid committing them to your repository.

## Step 6: Deploy!
Push your code to GitHub. This will trigger the GitHub Actions workflow.
Monitor the Actions tab in your repository to see the deployment progress.
Once complete, your application should be live on your server!

### Your complete pipeline flow: 

1. Push code to GitHub (master branch)
   ↓
2. GitHub Actions triggers automatically
   ↓
3. Builds Docker image with .NET 9.0
   ↓
4. Pushes to GitHub Container Registry
   ↓
5. SSHs to Server
   ↓
6. Pulls latest image
   ↓
7. Tests new container on port 8081
   ↓
8. Health check validates it's working
   ↓
9. Switches to port 8080 (production)
   ↓
10. Old container removed
    ↓
11. ✨ Live in production!

### What You've Built

This pipeline includes:
- ✅ Automated builds on every push to master
- ✅ Docker containerization for consistency
- ✅ Zero-downtime deployments with health checks
- ✅ Automatic rollback on failures
- ✅ Structured JSON logging
- ✅ Metrics endpoint for monitoring
- ✅ Security best practices (non-root user, SSH keys)

**Your Application Endpoints:**
- Main app: `http://YOUR_IP:8080/`
- Health check: `http://YOUR_IP:8080/health`
- Metrics: `http://YOUR_IP:8080/metrics`
- Readiness: `http://YOUR_IP:8080/ready`

## Troubleshooting

### Docker Build Issues

#### Error: `repository name must be lowercase`
**Problem:** Docker image names must be lowercase, but your repository has uppercase letters.

**Solution:** The workflow automatically converts the image name to lowercase using:
```yaml
- name: Set lowercase image name
  run: |
    echo "IMAGE_NAME_LOWER=$(echo ${{ env.IMAGE_NAME }} | tr '[:upper:]' '[:lower:]')" >> $GITHUB_ENV
```

#### Error: `Source file '/src/Dockerfile' could not be found`
**Problem:** The Dockerfile is being copied into the container and .NET is trying to compile it as C# code.

**Solution:** 
1. Check your `.dockerignore` includes `Dockerfile`
2. Check your `.csproj` file doesn't have `<Compile Include="Dockerfile" />` (remove this line if present)

#### Error: `Preprocessor directive expected`
**Problem:** Your `.csproj` file is trying to compile the Dockerfile as C# code.

**Solution:** Open `CicdDemo.csproj` and remove any lines like:
```xml
<Compile Include="Dockerfile" />
```

---

### GitHub Actions Issues

#### Error: `Permission denied (publickey)`
**Problem:** GitHub Actions can't SSH into your server.

**Solution:**
1. Verify the `DEPLOY_SSH_KEY` secret contains the **full private key** including:
   ```
   -----BEGIN OPENSSH PRIVATE KEY-----
   ... key content ...
   -----END OPENSSH PRIVATE KEY-----
   ```
2. Verify the public key is in `~/.ssh/authorized_keys` on your server
3. Check SSH key permissions on the server:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

#### Error: `ssh: handshake failed: EOF`
**Problem:** SSH connection is timing out or the Server is overloaded.

**Solution:**
1. Restart your VM
2. Increase timeout in the workflow (already set to 60s)
3. Check if the VM is out of resources. For Azure:
   ```bash
   ssh -i github-actions-key azureuser@YOUR_IP
   free -h  # Check memory
   df -h    # Check disk space
   ```

#### Error: `unauthorized: authentication required`
**Problem:** Can't push to GitHub Container Registry.

**Solution:** Verify the workflow has the correct permissions:
```yaml
permissions:
  contents: read
  packages: write  # This is required!
```

---

### Deployment Issues

#### Error: `Conflict. The container name "/cicd-demo-new" is already in use`
**Problem:** A previous deployment failed and left a container behind.

**Solution:** SSH into your server and clean up:
```bash
docker stop cicd-demo-new
docker rm cicd-demo-new
```

The updated workflow includes automatic cleanup to prevent this:
```bash
docker stop cicd-demo-new 2>/dev/null || true
docker rm cicd-demo-new 2>/dev/null || true
```

#### Error: Container starts then immediately stops
**Problem:** The application is crashing or the deployment script has an issue.

**Solution:**
1. Check the container logs:
   ```bash
   docker logs cicd-demo
   ```
2. Look for error messages in the logs
3. Try starting the container manually:
   ```bash
   docker start cicd-demo
   docker logs -f cicd-demo
   ```

---

### Network/Connectivity Issues

#### Problem: Can't access the application at `http://YOUR_IP:8080`
**Possible causes and solutions:**

**1. Port 8080 not open in VM Security Group**
For Azure VMs:
- Go to Azure Portal → Your VM → Networking
- Verify there's an inbound rule for port 8080
- Add one if missing:
  - Destination port: `8080`
  - Protocol: TCP
  - Action: Allow

**2. Container not running**
```bash
# Check if container is running
docker ps

# If not running, check all containers
docker ps -a

# Start it if stopped
docker start cicd-demo

# Check logs for errors
docker logs cicd-demo
```

**3. Container running on wrong port**
```bash
# Check which port the container is using
docker ps

# Look at the PORTS column
# Should show: 0.0.0.0:8080->8080/tcp
# If it shows 8081, the container is on the wrong port

# Fix: Remove and recreate on correct port
docker stop cicd-demo
docker rm cicd-demo
docker run -d \
  --name cicd-demo \
  --restart unless-stopped \
  -p 8080:8080 \
  ghcr.io/yourusername/cicddemo:latest
```

**4. VM firewall blocking the port**
```bash
# Check if UFW is active
sudo ufw status

# If active, allow port 8080
sudo ufw allow 8080/tcp
```

**5. Test locally first**
```bash
# SSH into your server
ssh -i github-actions-key azureuser@YOUR_IP

# Test from within the server
curl http://localhost:8080

# If this works but external doesn't, it's a firewall issue
```

---

### Health Check Issues

#### Problem: Deployment fails with "Health check failed"
**Solution:**

1. Check what's wrong with the health endpoint:
```bash
docker logs cicd-demo-new

# Or test the health endpoint manually
curl http://localhost:8081/health
```

2. Common causes:
   - Application taking too long to start (increase timeout in workflow)
   - Application crashing on startup (check logs)
   - Health endpoint not implemented correctly

3. Temporary workaround - deploy without health check:
```bash
# SSH to server and deploy manually
docker pull ghcr.io/yourusername/cicddemo:latest
docker stop cicd-demo
docker rm cicd-demo
docker run -d --name cicd-demo -p 8080:8080 ghcr.io/yourusername/cicddemo:latest
```

---

### General Debugging Commands

**Check what's running:**
```bash
docker ps                    # Running containers
docker ps -a                 # All containers (including stopped)
```

**View logs:**
```bash
docker logs cicd-demo        # All logs
docker logs -f cicd-demo     # Follow logs in real-time
docker logs --tail 50 cicd-demo  # Last 50 lines
```

**Check resource usage:**
```bash
docker stats cicd-demo       # CPU, memory usage
free -h                      # Server memory
df -h                        # Disk space
```

**Network debugging:**
```bash
# Check if port is listening
sudo netstat -tlnp | grep 8080

# Or use ss
sudo ss -tlnp | grep 8080
```

**Clean up Docker:**
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove everything unused (be careful!)
docker system prune -a
```

---

### Still Having Issues?

1. **Check GitHub Actions logs:**
   - Go to your repository → Actions tab
   - Click on the failed workflow
   - Review each step for error messages

2. **Check server logs:**
   ```bash
   docker logs --tail 100 cicd-demo
   ```

3. **Verify all secrets are set correctly:**
   - GitHub → Settings → Secrets and variables → Actions
   - Ensure `DEPLOY_HOST`, `DEPLOY_USER`, and `DEPLOY_SSH_KEY` are set

4. **Test SSH connection manually:**
   - For Azure VMs:
   ```bash
   ssh -i github-actions-key azureuser@YOUR_IP
   ```

5. **Restart everything:**
   ```bash
   # On server
   docker restart cicd-demo
   
   # Or restart the VM
   ```
