import json
import boto3
import os
from pathlib import Path

def create_policy(iam_client, policy_name, tags):
    # Define the policy document that grants all access to ECR
    policy_document = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ecr:*"
                ],
                "Resource": "*"
            }
        ]
    }
    
    try:
        # Create the policy
        response = iam_client.create_policy(
            PolicyName=policy_name,
            PolicyDocument=json.dumps(policy_document),
            Description='Policy with full access to ECR',
            Tags=tags
        )
        return response
    except Exception as e:
        print(f"Error creating policy: {e}")
        return None


def main():
    ver = str(1)
    stage = 'test'
    iam_client = boto3.client('iam')
    arn_list = []
    
    # Define the policy name and tags
    policy_name = f'redis_ecr_policy_{ver}'
    policy_tags = [
        {
            'Key': 'ver',
            'Value': ver
        },
        {'Key' : 'stage' , 
         'Value' : stage}
        # Add more tags as needed
    ]
    
    # Create the policy
    policy_response = create_policy(iam_client, policy_name, policy_tags)
    
    if policy_response:
        print(f"Policy created successfully: {policy_response['Policy']['Arn']}")
        arn_list.append(policy_response['Policy']['Arn'])
        arn_path = Path(os.getcwd()) / 'arn.json'
        with open(arn_path, 'w') as file:
            file.write(json.dumps(arn_list))
    else:
        print("Policy creation failed.")


if __name__ == "__main__":
    main()
