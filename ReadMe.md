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
- Add a workflow YAML file, e.g., [deploy.yml]()


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

DEPLOY_HOST - Your server IP
DEPLOY_USER - SSH username
DEPLOY_SSH_KEY - github-actions-key 

To get the private key content, run:

```powershell
Get-Content github-actions-key | Set-Clipboard
```
Paste it into the "Value" field when creating the secret.

## Step 6: Deploy!
Push your code to GitHub. This will trigger the GitHub Actions workflow.
Monitor the Actions tab in your repository to see the deployment progress.
Once complete, your application should be live on your server!




