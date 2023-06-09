import os
from pathlib import Path

state_bucket = 'maelstrommedia-state-bucket'
ver = 1
stage = 'test'
resource = 'server'
server = 'redis'
state_key = f'music/{ver}/{stage}/{resource}/{server}/sg/infa.tf'
region_name = 'us-east-1'
config_string = f'''
bucket="{state_bucket}"
key="{state_key}"
region="{region_name}"
'''
var_string = f'''
stage="{stage}"
ver="{ver}"
tf_resource="{resource}"
sgname="ec2-{server}-sg"
'''

# Write config_string to infa.config
config_file_path = Path(os.getcwd()) / 'infa.config'
with open(config_file_path, 'w') as file:
    file.write(config_string)

# Write var_string to terraform.tfvars
var_file_path = Path(os.getcwd()) / 'terraform.tfvars'
with open(var_file_path, 'w') as file:
    file.write(var_string)
