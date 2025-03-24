# Use a lightweight Node.js image
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Compile TypeScript (ensure tsconfig.json is set up)
RUN npm run build

# Expose port 3000 (or your app's port)
EXPOSE 3000

# Start the application
CMD ["node", "dist/index.js"]
