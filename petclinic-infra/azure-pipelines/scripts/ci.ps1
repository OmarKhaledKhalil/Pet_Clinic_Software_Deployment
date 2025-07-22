# Install Node.js
Set-Location -Path './petclinic'                # Change directory to the Pet Clinic project
npm install                                     # Install Node.js dependencies

# Run build and tests
npm run build                                   # Build the application
npm test                                        # Run application tests

# Prepare and run SonarQube analysis
& sonar-scanner -Dsonar.projectKey="PetClinic" -Dsonar.sources="." # Run SonarQube scanner with project key

# Determine the outcome
If ($LASTEXITCODE -ne 0) {                      # Check the exit code of the last command
    Write-Host "CI process failed."             # Print message if CI process failed
    Exit 1                                      # Exit with error code
} else {
    Write-Host "CI process succeeded."          # Print message if CI process succeeded
}