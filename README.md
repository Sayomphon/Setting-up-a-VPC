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
#### 1. Provider Block
```hcl
provider "aws" {
  region = "ap-southeast-1" # Specify the AWS region
}
```
  - **provider "aws"**: This block specifies the cloud provider being used, which in this case is AWS (Amazon Web Services).
  - **region**: This attribute defines the specific geographic region where the resources will be created. Here, it's set to **ap-southeast-1**, which represents the Oregon region.
#### 2. Creating the VPC
```hcl
# Creating the VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = "10.1.0.0/16" # Define the CIDR block for the VPC
  tags = {
    Name = "app-vpc" # Tag the VPC for identification
  }
}
```
  - **resource "aws_vpc" "app_vpc"**: This block creates a new Virtual Private Cloud (VPC).
  - **cidr_block**: This parameter specifies the IP address range allocated for the VPC. The value 10.1.0.0/16 allows for a large number of IP addresses, supporting a substantial number of subnets and EC2 instances.
  - **tags**: The tagging section allows you to assign a descriptive name to the VPC (in this case, "app-vpc") for easier management and identification of resources.
#### 3. Creating the Internet Gateway
```hcl
# Creating the Internet Gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id # Attach the Internet Gateway to the created VPC
  tags = {
    Name = "app-igw" # Tag the Internet Gateway for identification
  }
}
```
  - **resource "aws_internet_gateway" "app_igw"**: This block creates an Internet Gateway that enables connectivity between the VPC and the Internet.
  - **vpc_id**: This attribute links the Internet Gateway to the VPC created earlier (denoted by aws_vpc.app_vpc.id), allowing instances within the VPC to access the Internet.
  - **tags**: Similar to the VPC, this section assigns a name ("app-igw") to the Internet Gateway for easier identification and management.

## Task 2: Creating subnets
### Setting by AWS Management Console
In this task, you will create the four subnets for your VPC. You will configure the two public subnets first, and then configure the two private subnets.
1. From the navigation pane, choose **Subnets**.
2. Choose **Create subnet**.
3. For the first public subnet, configure these settings:
    - **VPC ID**: app-vpc
    - **Subnet name**: ***Public Subnet 1***
    - **Availability Zone**: Choose the first Availability Zone
      - Example: If you are in US West (Oregon), you would choose us-west-2a
    - **IPv4 CIDR block**: ***10.1.1.0/24***
4. Choose **Add new subnet**.
5. For the second public subnet, configure these settings:
    - **Subnet name**: ***Public Subnet 2***
    - **Availability Zone**: Choose the second Availability Zone
      - Example: If you are in US West (Oregon), you would choose us-west-2b
    - **IPv4 CIDR block**: 10.1.2.0/24
6. Choose **Add new subnet** and for the first private subnet, configure these settings:
    - **Subnet name**: ***Private Subnet 1***
    - **Availability Zone**: Choose the first Availability Zone
      - Example: If you are in US West (Oregon), you would choose us-west-2a
    - **IPv4 CIDR block**: ***10.1.3.0/24***.
7. Choose **Add new subnet** and for the second private subnet, configure the following:
    - **Subnet name**: ***Private Subnet 2***
    - **Availability Zone**: Choose the second Availability Zone
      - Example: If you are in US West (Oregon), you would choose us-west-2b
    - **IPv4 CIDR block**: ***10.1.4.0/24***
8. Finally, choose **Create subnet**.
9. After the subnets are created, select the check box for **Public Subnet 1**.
10. Choose **Actions** and then choose **Edit subnet settings**.
11. For **Auto-assign IP settings**, select **Enable auto-assign public IPv4 address** and then choose **Save**.
12. Clear the check box for **Public Subnet 1** and select the check box for **Public Subnet 2**.
13. Again, choose **Actions** and then **Edit subnet settings**.
14. For **Auto-assign IP settings**, select **Enable auto-assign public IPv4 address** and save the settings.
