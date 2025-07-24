try {
    # Navigate to PetClinic project directory
    Write-Host "Navigating to PetClinic directory..."
    Set-Location -Path './petclinic'

    # Install required Node.js dependencies
    Write-Host "Installing Node.js dependencies..."
    npm install

    # Build the application
    Write-Host "Building application..."
    npm run build

    # Execute tests
    Write-Host "Running tests..."
    npm test

    # Run SonarQube analysis for code quality
    Write-Host "Running SonarQube analysis..."
    & sonar-scanner -Dsonar.projectKey="PetClinic" -Dsonar.sources="."

    # Validate the CI process
    Write-Host "CI process succeeded."
} catch {
    Write-Error "CI process failed: $_"
    exit 1
}