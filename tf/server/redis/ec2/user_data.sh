sudo apt-get update
sudo apt-get install docker.io -Y
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker
sudo apt-get install awscli -Y
aws configure
sudo apt-get update
sudo apt-get install -y golang
sudo apt-get make
git clone https://github.com/awslabs/amazon-ecr-credential-helper.git

# Go to the repository directory
cd amazon-ecr-credential-helper

# Make the project. This will result in the creation of the docker-credential-ecr-login binary in the bin directory.
make

# You may want to move the binary to /usr/local/bin so it's accessible system-wide:
sudo mv bin/local/docker-credential-ecr-login /usr/local/bin/
go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
source ~/.bashrc
mkdir -p ~/.docker

cd ~/.docker/config.json


echo '{
	"credsStore": "ecr-login"
}' > ~/.docker/config.json


aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 984119170260.dkr.ecr.us-east-1.amazonaws.com/music-dev-repo
aws ecr describe-images --repository-name music-dev-repo --region us-east-1
