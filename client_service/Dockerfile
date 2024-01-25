# Use the official Node.js LTS image as the base image
FROM node:lts-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the Next.js application
RUN npm run build

# Use a lighter-weight image for production
FROM node:lts-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the build artifacts from the build stage to the final image
COPY --from=build /app/.next ./.next
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./

# Expose the port on which the application will run
EXPOSE 3001

# Start the Next.js application
CMD ["npm", "start"]
