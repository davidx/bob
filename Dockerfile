# Use an official Ruby runtime as a parent image
FROM ruby:latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Install any needed packages specified in Gemfile
# Uncomment the following lines if you have a Gemfile
# COPY Gemfile ./
# RUN bundle install

# Make port 80 available to the world outside this container
# Uncomment the following line if your app uses a port
# EXPOSE 80

# Define environment variable
# Use this if you need environment variables
# ENV NAME World

# Run app.rb when the container launches
CMD ["ruby", "./app.rb"]

