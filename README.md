# Setting up a VPC
In this exercise, you set up a new virtual private cloud (VPC). This new VPC will have four subnets (two public subnets and two private subnets) and two route tables (one public route table and one private route table). Then, you launch an EC2 instance inside the new VPC. Finally, at the end of the exercise, you stop the instance to prevent future costs from incurring.

## Task 1: Creating the VPC
### Setting by AWS Management Console
In this task, you will create a new VPC.
1. If needed, log in to the AWS Management Console as your Admin user.
2. In the Services search box, enter VPC and open the VPC console by choosing **VPC** from the list.
3. In the navigation pane, under **Virtual private cloud**, choose **Your VPCs**.
4. Choose **Create VPC**.
5. Configure these settings:
  - **Name tag**: app-vpc
  - **IPv4 CIDR block**: 10.1.0.0/16
6. Choose **Create VPC**.
7. In the navigation pane, under **Virtual private cloud**, choose **Internet gateways**
8. Choose **Create internet gateway**.
9. For **Name tag**, paste app-igw and choose **Create internet gateway**.
10. In the details page for the internet gateway, choose **Actions** and then choose **Attach to VPC**.
11. For **Available VPCs**, choose app-vpc and then choose **Attach internet gateway**.

### Setting by Terraform
