# set-up build base. Available Node bases: https://hub.docker.com/_/node
FROM node:18-alpine as build_stage

# Set-up build directory in image.Built artifacts will be here 
WORKDIR /build_directory

# Copy all files starts with Package to .=> build_directory
COPY package*.json .

# Install all dependencies
RUN npm install

#Copy all other files from project to build directory
COPY . .

# Run build command, output will be in /build_directory/dist
# as Vite by default builds app in dist
RUN npm run build

# Stage-2.Production build.
# Alpine with nginx installed: https://hub.docker.com/_/nginx
FROM nginx:stable-alpine as final_stage

# Copy from build stage to final_stage
# From /build_directory/dist folder to default Nginx root directory
COPY --from=build_stage /build_directory/dist /usr/share/nginx/html

# Overriding Nginx config.
# /etc/nginx/conf.d/default.conf is used to configure default host.
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

#docker build . -t 'tldraw-exp:v1.0'
#docker run -p 8080:8080 tldraw-exp:v1.0
# Go To: http://localhost:8080/