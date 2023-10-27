# Define custom function directory
ARG FUNCTION_DIR="/function"

FROM node:18-buster as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

WORKDIR ${FUNCTION_DIR}

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        g++ \
        make \
        cmake \
        unzip \
        libcurl4-openssl-dev

# Copy function code
COPY index.js package.json package-lock.json ./

# Install app dependencies
RUN npm install

# Install the required lambda runtime interface client
RUN npm install aws-lambda-ric

# Grab a fresh slim copy of the image to reduce the final size
FROM node:18-buster-slim

# Required for Node runtimes which use npm@8.6.0+ because
# by default npm writes logs under /home/.npm and Lambda fs is read-only
ENV NPM_CONFIG_CACHE=/tmp/.npm \
    PACKAGE_VERSION="v2"

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

# Set runtime interface client as default command for the container runtime
ENTRYPOINT ["/usr/local/bin/npx", "aws-lambda-ric"]
# Pass the name of the function handler as an argument to the runtime
CMD ["index.handler"]
