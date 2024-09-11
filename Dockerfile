# Base image
FROM ubuntu:20.04

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    openjdk-11-jdk \
    unzip

# Install Horusec CLI
RUN curl -fsSL https://raw.githubusercontent.com/ZupIT/horusec/main/deployments/scripts/install.sh | bash -s latest

# Install Dependency-Check
RUN curl -LO https://github.com/jeremylong/DependencyCheck/releases/download/v6.5.0/dependency-check-6.5.0-release.zip \
    && unzip dependency-check-6.5.0-release.zip -d dependency-check

# Install OWASP ZAP (via Docker)
RUN docker pull owasp/zap2docker-stable

# Install Dastardly
RUN docker pull dastardly-ci/dastardly

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
