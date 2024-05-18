# Use a base image that contains Java runtime
FROM openjdk:17-jdk-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the build artifact from the host to the container
COPY target/hello-world-0.0.1-SNAPSHOT.jar app.jar

# # Expose the port the app runs on

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
