# infrastructure
Packer, Terraform and Ansible code for deploying VPC, Bastion hosts, Web Hosts and Application Load Balancer.

Example Usage:

Deployment:
ansible-playbook 02_vpc.yml --extra-vars "var_file=variables.yml state=present"

Destroy:
ansible-playbook 02_vpc.yml --extra-vars "var_file=variables.yml state=absent"
