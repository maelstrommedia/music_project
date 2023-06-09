# We use an official Python runtime as the base image
FROM python:3.9-slim-buster

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev

# Setting the working directory in the container
WORKDIR /app

# Installing necessary build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Copying the current directory contents into the container
COPY . /app


# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


EXPOSE 8080
CMD ["uwsgi", "uwsgi.ini"]