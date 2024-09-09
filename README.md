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

### Setting by Terraform
#### 1. Creating Public Subnet 1
```hcl
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-southeast-2a" # Change according to your preference
  tags = {
    Name = "Public Subnet 1" # Tag the subnet for identification
  }
}
```
  - **resource "aws_subnet" "public_subnet_1"**: This block creates the first public subnet.
  - **vpc_id**: Specifies the ID of the VPC to which this subnet belongs, linking it to the VPC created in Task 1.
  - **cidr_block**: Defines the range of IP addresses available for this subnet. The value "10.1.1.0/24" allows for 256 IP addresses.
  - **availability_zone**: Designates the AWS Availability Zone where the subnet will be located; here, it's set to "us-west-2a," but this can be adjusted as required.
  - **tags**: Assigns a descriptive name ("Public Subnet 1") for easier identification in the AWS console.
#### 2. Creating Public Subnet 2
```hcl
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-southeast-2b" # Change according to your preference
  tags = {
    Name = "Public Subnet 2" # Tag the subnet for identification
  }
}
```
  - **resource "aws_subnet" "public_subnet_2"** : Similar to Public Subnet 1, this block creates a second public subnet.
  - **cidr_block**: Uses a different CIDR block ("10.1.2.0/24") to expand the range of available IPs.
  - **availability_zone**: This subnet resides in "us-west-2b," providing redundancy across different zones.
#### 3. Creating Private Subnet 1
```hcl
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "ap-southeast-2a" # Change according to your preference
  tags = {
    Name = "Private Subnet 1" # Tag the subnet for identification
  }
}
```
  - **resource "aws_subnet" "private_subnet_1"**: This block creates the first private subnet.
  - Similar to the public subnets, it links to the VPC and establishes its own CIDR block ("10.1.3.0/24").
  - **availability_zone**: Designates "us-west-2a" for the private subnet's location, supporting a layered architecture.
#### 4. Creating Private Subnet 2
```hcl
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "ap-southeast-2b" # Change according to your preference
  tags = {
    Name = "Private Subnet 2" # Tag the subnet for identification
  }
}
```
  - **resource "aws_subnet" "private_subnet_2"**: This block establishes the second private subnet.
  - **cidr_block**: Uses "10.1.4.0/24" for addressing.
  - **availability_zone**: Placed in "us-west-2b" to ensure availability across multiple zones.
#### 5. Enabling Auto-assign Public IP for Public Subnets
```hcl
resource "aws_subnet_public_ip" "public_subnet_1_auto_assign" {
  subnet_id = aws_subnet.public_subnet_1.id
  map_public_ip_on_launch = true
}

resource "aws_subnet_public_ip" "public_subnet_2_auto_assign" {
  subnet_id = aws_subnet.public_subnet_2.id
  map_public_ip_on_launch = true
}
```
  - **resource "aws_subnet_public_ip"**: These blocks enable automatic assignment of Public IP addresses for the public subnets when EC2 instances are launched within them.
  - **subnet_id**: Specifies which public subnet should have this setting apply.
  - **map_public_ip_on_launch**: Set to ***true***, this option ensures that instances launched in these subnets receive public IP addresses, making them accessible from the internet.

## Task 3: Creating route tables
### Setting by AWS Management Console
In this task, you will create the route tables for your VPC.
First, you will create the public route table.
1. In the navigation pane, choose **Route Tables**.
2. Choose **Create route table**.
3. For the route table, configure these settings:
    - **Name**: app-routetable-public
    - **VPC**: app-vpc
4. Choose **Create route table**.
5. If needed, open the route table details pane by choosing **app-routetable-public** from the list.
6. Choose the **Routes** tab and choose **Edit routes**.
7. Choose **Add route** and configure these settings:
    - **Destination**: ***0.0.0.0/0***
    - **Target**: Internet Gateway, then choose app-igw (which you set up in the VPC task)
8. Choose **Save changes**.
9. Choose the **Subnet associations** tab.
10. Scroll to **Subnets without explicit associations** and choose **Edit subnet associations**.
11. Select the two public subnets that you created (**Public Subnet 1** and **Public Subnet 2**) and choose **Save associations**.
Next, you will create the private route table.
12. In the navigation pane, choose **Route Tables**.
13. Choose **Create route table** and configure these settings:
    - **Name**: ***app-routetable-private***
    - **VPC**: ***app-vpc***
14. Choose **Create route table**.
15. If needed, open the details pane for **app-routetable-private** by choosing it from the list.
16. Choose the **Subnet associations tab**.
17. Scroll to **Subnets without explicit associations** and choose **Edit subnet associations**.
18. Select the two private subnets (**Private Subnet 1** and **Private Subnet 2**) and choose **Save associations**.

### Setting by Terraform
#### 1. Creating the Public Route Table
```hcl
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app_vpc.id # Attach the route table to the VPC
  tags = {
    Name = "app-routetable-public" # Tag the route table for identification
  }
}
```
  - **resource "aws_route_table" "public_route_table"**: This block creates a new route table specifically for managing routing for public subnets.
  - **vpc_id**: Links the route table to the VPC created in Task 1, ensuring that routing rules apply within the correct network context.
  - **tags**: Provides a human-readable name ("app-routetable-public") for easier identification and management in the AWS Console.
#### 2. Creating the Route for the Public Route Table
```hcl
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0" # Routes all outbound traffic
  gateway_id             = aws_internet_gateway.app_igw.id # Use the Internet Gateway
}
```
  - **resource "aws_route" "public_route"**: This block establishes a specific route within the public route table.
  - **route_table_id**: References the public route table created previously, linking this route to that table.
  - **destination_cidr_block**: Set to "0.0.0.0/0", this allows all outbound traffic to reach any IP address on the internet.
  - **gateway_id**: Identifies the Internet Gateway (created in Task 1) which the route will use to allow outbound internet access for instances in the public subnets.
#### 3. Associating Public Subnet 1 with the Public Route Table
```hcl
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
```
  - **resource "aws_route_table_association" "public_subnet_1_association"**: This block links the first public subnet with the public route table.
  - **subnet_id**: Specifies the public subnet created in Task 2, allowing it to utilize the routing rules defined in the public route table.
  - **route_table_id**: References the public route table, establishing the association.
#### 4. Associating Public Subnet 2 with the Public Route Table
```hcl
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
```
  - **resource "aws_route_table_association" "public_subnet_2_association"**: Similar to the previous block, this piece associates the second public subnet with the same public route table.
  - This ensures that instances launched within Public Subnet 2 can also access the defined routes in the public route table.
#### 5. Creating the Private Route Table
```hcl
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.app_vpc.id # Attach the route table to the VPC
  tags = {
    Name = "app-routetable-private" # Tag the route table for identification
  }
}
```
  - **resource "aws_route_table" "private_route_table"**: This block establishes a new route table for the private subnets.
  - **vpc_id**: Links it to the VPC created in Task 1, ensuring proper routing management.
  - **tags**: Provides identification for the route table, naming it "app-routetable-private".
#### 6. Associating Private Subnet 1 with the Private Route Table
```hcl
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}
```
  - **resource "aws_route_table_association" "private_subnet_1_association"**: This block associates the first private subnet with the private route table.
  - Instances residing in this subnet will refer to this route table when determining how to respond to incoming and outgoing network traffic.
#### 7. Associating Private Subnet 2 with the Private Route Table
```hcl
resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
```
  - **resource "aws_route_table_association" "private_subnet_2_association"**: This block completes the routing setup by associating the second private subnet with the private route table.
  - Similar to the previous association, it ensures that instances in Private Subnet 2 follow the routing rules defined in the private route table.

## Task 4: Launching an EC2 instance that uses a role
### Setting by AWS Management Console
Now that you have created a network, you will launch your EC2 instance by using the VPC that you created!
1. In the search box, enter EC2 and open the Amazon EC2 console by choosing **EC2** from the list.
2. In the navigation pane, choose **Instances** and choose **Launch instances**.
3. For **Name** use ***employee-directory-app***.
4. Under **Application and OS Images (Amazon Machine Image)**, choose the default **Amazon Linux 2023**.
5. Under **Instance type**, select **t2.micro**.
6. Under **Key pair (login)** choose the **app-key-pair** created in exercise-3.
7. Configure the following settings under Network settings and Edit.
    - **VPC**: app-vpc
    - **Subnet**: Public Subnet 1
    - **Auto-assign Public IP**: Enable
8. Under **Firewall (security groups)** choose **Create security group**. Use ***web-security-group*** as the **Security group name** and change **Description** to ***Enable HTTP access***.
9. Under **Inbound security groups rules** choose **Remove** above the **ssh** rule.
10. Choose **Add security group rule**. For **Type** choose **HTTP**. Under **Source type** choose **Anywhere**.
11. Choose **Add security group rule**. For **Type** choose **HTTPS**. Under **Source type** choose **Anywhere**.
12. Expand **Advanced details** and under **IAM instance profile** choose **S3DynamoDBFullAccessRole**.
13. In the **User data** box, paste the following code:
```bash
#!/bin/bash -ex
wget https://aws-tc-largeobjects.s3-us-west-2.amazonaws.com/DEV-AWS-MO-GCNv2/FlaskApp.zip
unzip FlaskApp.zip
cd FlaskApp/
yum -y install python3-pip
pip install -r requirements.txt
yum -y install stress
export PHOTOS_BUCKET=${SUB_PHOTOS_BUCKET}
export AWS_DEFAULT_REGION=<INSERT REGION HERE>
export DYNAMO_MODE=on
FLASK_APP=application.py /usr/local/bin/flask run --host=0.0.0.0 --port=80
```
14. Change the following line to match your Region (the Region is listed at the top right, next to your user name):
```bash
export AWS_DEFAULT_REGION=<INSERT REGION HERE>
```
Example:
This example uses the US West (Oregon) Region, or us-west-2.
```bash
export AWS_DEFAULT_REGION=us-west-2
```
**Note**: You still don’t need to change the ***SUB_PHOTOS_BUCKET*** variable in the user data script. You will update this placeholder in a later lab.
15. Choose **Launch instance**.
16. Choose **View all instances**.
The instance should now be listed under **Instances**.
17. Wait for the **Instance state** to change to ***Running*** and the **Status check** to change to 2/2 checks passed.
**Note**: Often, the status checks update, but the console user interface (UI) might not update to reflect the most recent information. You can minimize waiting by refreshing the page after a few minutes.
18. Select the running **employee-directory-app instance** by selecting its check box.
19. On the **Details** tab, copy the **Public IPv4 address**.
**Note**: Make sure that you only copy the address instead of choosing the open address link.
20. In a new browser window, paste the IP address that you copied. ***Make sure to remove the ‘S’ after HTTP so you are using only HTTP instead***.
21. In a new browser window, paste the IP address that you copied.
You should see an **Employee Directory** placeholder. You won’t be able to interact with the application yet because it’s not connected to a database.

### Setting by Terraform
#### 1. Creating the EC2 Instance
```hcl
resource "aws_instance" "employee_directory_app" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with the latest Amazon Linux 2023 AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  key_name      = "app-key-pair"
  security_groups = [aws_security_group.web_security_group.name]

  iam_instance_profile = "S3DynamoDBFullAccessRole" # Ensure this role exists
```
  - **resource "aws_instance" "employee_directory_app"**: This block defines the configuration for the EC2 instance you want to launch.
  - **ami**: Specifies the Amazon Machine Image ID. You should replace this with the latest Amazon Linux 2023 AMI ID available in your AWS region.
  - **instance_type**: Defines the type of EC2 instance. In this case, t2.micro is used, which is eligible for the AWS Free Tier.
  - **subnet_id**: Links the instance to Public Subnet 1, allowing it to get a public IP address.
  - **associate_public_ip_address**: This boolean option indicates that the instance should be assigned a public IP address.
  - **key_name**: Specifies the name of the key pair used for SSH access to the instance.
  - **security_groups**: Associates the instance with the security group defined later in the code.
  - **iam_instance_profile**: Attaches the specified IAM role, which should already exist, allowing the instance to access AWS services as per the role's permissions.
#### 2. User Data Script
```hcl
  user_data = <<-EOF
              #!/bin/bash -ex
              wget https://aws-tc-largeobjects.s3-ap-southeast-1.amazonaws.com/DEV-AWS-MO-GCNv2/FlaskApp.zip
              unzip FlaskApp.zip
              cd FlaskApp/
              yum -y install python3-pip
              pip install -r requirements.txt
              yum -y install stress
              export PHOTOS_BUCKET=${SUB_PHOTOS_BUCKET}
              export AWS_DEFAULT_REGION=ap-southeast-1
              export DYNAMO_MODE=on
              FLASK_APP=application.py /usr/local/bin/flask run --host=0.0.0.0 --port=80
              EOF
```
  - **user_data**: The user_data attribute allows you to specify commands that will run on the EC2 instance upon launch.
  - **#!/bin/bash -ex**: This line indicates that the script should be executed using the Bash shell, with -e allowing the script to exit on any errors, and -x enabling debugging output.
  - **wget**: Downloads the Flask application zip file from the specified URL.
  - **unzip**: Unzips the downloaded file so that its contents will be available for use.
  - **cd FlaskApp/**: Changes directory to the unzipped application folder.
  - **yum -y install python3-pip**: Installs Python package manager pip to manage Python packages.
  - **pip install -r requirements.txt**: Installs the necessary Python packages defined in the requirements.txt file.
  - **yum -y install stress**: Installs the stress utility for load testing if needed.
  - **export**: Sets environment variables required for the Flask application’s execution. Make sure to replace ${SUB_PHOTOS_BUCKET} with the actual value before deployment.
  - **FLASK_APP**: This command launches the Flask application on port 80 and binds it to all network interfaces (0.0.0.0).
#### 3. Creating the Security Group
```hcl
resource "aws_security_group" "web_security_group" {
  name        = "web-security-group"
  description = "Enable HTTP access"
  vpc_id     = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
  - **resource "aws_security_group" "web_security_group"**: This block creates a new security group that controls inbound traffic to the EC2 instance.
  - **name**: Specifies a name for the security group, making it easier to identify.
  - **description**: A brief description of the security group’s purpose.
  - **vpc_id**: Associates the security group with the VPC created earlier, ensuring that the rules apply within the correct network context.
  - **ingress**: Defines inbound rules for the security group.
    - **from_port** and **to_port**: Set to 80 and 443, allowing HTTP and HTTPS traffic, respectively.
    - **protocol**: Specifies the protocol to use; in this case, TCP.
    - **cidr_blocks**: The rule allows traffic from anywhere on the internet (0.0.0.0/0).
