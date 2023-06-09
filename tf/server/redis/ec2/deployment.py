# import boto3



# def main():
    # # Create an EC2 client
    # ec2_client = boto3.client('ec2', region_name='us-east-1')
    
    # # Define the parameters
    # ami_id = 'ami-0abcdef1234567890'  # replace with your AMI ID
    # instance_type = 't2.micro'
    # key_name = 'your-key'  # replace with your key name
    # security_group_id = 'sg-0abcdef1234567890'  # replace with your security group ID
    # iam_role_name = 'ec2-YourRoleName-role-ip'  # replace with your IAM role name (from terraform output)
    
    # # Start the EC2 instance
    # response = start_ec2_instance(ec2_client, ami_id, instance_type, key_name, security_group_id, iam_role_name)
    
    # if response:
    #     print(f"EC2 instance started successfully: {response['Instances'][0]['InstanceId']}")
    # else:
    #     print("EC2 instance creation failed.")

# if __name__ == "__main__":
#     main()

import boto3
import json

bucket_name="maelstrommedia-state-bucket"
ver = 1
stage = 'test'
server_name = 'redis'
sg_key = f"music/{ver}/{stage}/server/{server_name}/sg/infa.tf"
iam_key = f"music/{ver}/{stage}/server/{server_name}/role/infa.tf"
vpc_key = f"music/{ver}/{stage}/vpc/infa.tf"


s3_resource = boto3.resource('s3')

try:
    sg_obj = s3_resource.Object(bucket_name, sg_key)
    sg_content = sg_obj.get()['Body'].read().decode()
    sg_content_dict = json.loads(sg_content)
    sg_state = sg_content_dict['outputs']
    vpc_id = sg_state['security_group_vpc_id']
    sg_id = sg_state['security_group_id']
    print(vpc_id)
    print(sg_id)
    iam_obj = s3_resource.Object(bucket_name, iam_key)
    iam_content = iam_obj.get()['Body'].read().decode()
    iam_content_dict = json.loads(iam_content)
    iam_state = iam_content_dict['outputs']
    iam_name = iam_state['ec2_instance_profile_arn']['value'].split('/')[-1]
    print(iam_name)
    vpc_obj = s3_resource.Object(bucket_name, vpc_key)
    vpc_content = vpc_obj.get()['Body'].read().decode()
    vpc_content_dict = json.loads(vpc_content)
    vpc_state = vpc_content_dict['outputs']
    public_subnets = vpc_state['public_subnets']['value'][0]
    
except Exception as e:
    print(f"Error getting object from S3: {e}")

def start_ec2_instance(ec2_client, ami_id, instance_type, key_name, security_group_id, iam_role_name, subnet_id):
    try:
        response = ec2_client.run_instances(
            ImageId=ami_id,
            InstanceType=instance_type,
            KeyName=key_name,
            IamInstanceProfile={'Name': iam_role_name},
            MinCount=3,
            MaxCount=3,
            NetworkInterfaces=[
                {
                    'AssociatePublicIpAddress': True,
                    'DeviceIndex': 0,
                    'Groups': [security_group_id['value']],
                    'SubnetId': subnet_id,
                },
            ]
        )
        
        return response
    except Exception as e:
        print(f"Error starting EC2 instance: {e}")
        return None

# Create an EC2 client
ec2_client = boto3.client('ec2', region_name='us-east-1')
# Define the parameters
ami_id = 'ami-053b0d53c279acc90'  # replace with your AMI ID
instance_type = 't3.large'
key_name = 'KEY'
security_group_id =     sg_id  # replace with your security group ID
iam_role_name = iam_name# replace with your IAM role name (from terraform output , )

# Start the EC2 instance
response = start_ec2_instance(ec2_client, ami_id, instance_type, key_name, security_group_id, iam_role_name, public_subnets)

if response:
    print(f"EC2 instance started successfully: {response['Instances'][0]['InstanceId']}")
else:
    print("EC2 instance creation failed.")

