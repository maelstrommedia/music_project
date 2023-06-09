docker build -t my-redis .
docker run -d --network host --name my-redis my-redis