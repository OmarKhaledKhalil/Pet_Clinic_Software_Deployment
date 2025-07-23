# Navigate to PetClinic directory
Set-Location -Path './petclinic'

# Install Node.js dependencies
npm install

# Run build and tests
npm run build
npm test

# Prepare and run SonarQube analysis
& sonar-scanner -Dsonar.projectKey="PetClinic" -Dsonar.sources="."

# Determine the outcome
If ($LASTEXITCODE -ne 0) {
    Write-Host "CI process failed."
    Exit 1
} else {
    Write-Host "CI process succeeded."
}