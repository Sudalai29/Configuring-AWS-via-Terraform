For creating this whole infrastructure these steps were followed and all the terraform codes for the particular AWS services are available in the terraform documentation for AWS provider page.,
https://registry.terraform.io/providers/hashicorp/aws/latest/docs
https://docs.aws.amazon.com/whitepapers/latest/cicd_for_5g_networks_on_aws/terraform.html

Here are the Steps:

1. **VPC Creation**:
    - Define a VPC with a specified CIDR block.
    - Create two public subnets within the VPC, each with their respective CIDR blocks.
    - Associate the subnets with their corresponding availability zones.

2. **Route Tables**:
    - Define route tables for the public subnets in different availability zones.
    - Ensure routes are configured to direct traffic appropriately within the VPC.

3. **Security Group Creation**:
    - Create a security group for EC2 instances within the VPC.
    - Define inbound and outbound rules in the security group to control traffic flow to and from the instances.

4. **EC2 Instances**:
    - Launch EC2 instances within the public subnets using Terraform.
    - Associate the created security group with the EC2 instances.

5. **Application Load Balancer (ALB)**:
    - Create an Application Load Balancer (ALB) to distribute incoming traffic.
    - Attach the ALB to the public subnets.
    - Register EC2 instances in the public subnet(s) as target groups with the ALB.

6. **Routing Traffic**:
    - Associate the ALB with the route table(s) for the public subnets.
    - Route incoming traffic from the ALB to the EC2 instances in the public subnets through appropriate route tables.

7. **Route Table Association**:
    - Associate the created security group with the route table(s) for the public subnets.
    - Ensure that the security group's inbound and outbound rules align with the desired network traffic policies.

By following this setup, you ensure a secure and scalable environment for running applications within your VPC, with Terraform managing the entire infrastructure deployment process.
