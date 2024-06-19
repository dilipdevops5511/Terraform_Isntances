resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "web_server" {
  ami           = "ami-05e00961530ae1b55"
  instance_type = "t2.small"
  key_name      = "keypairnewaccount"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [
      aws_security_group.ssh_access.id
  ]

user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y  # Update package lists with -y for automatic yes to prompts
    sudo apt-get install apache2 -y  # Install Apache web server with -y for automatic yes to prompts
    sudo systemctl start apache2  # Start Apache service
    sudo systemctl enable apache2  # Enable Apache service to start on boot
    echo "<html><body><h1>Welcome to my website!</h1></body></html>" > /var/www/html/index.html  # Create a simple index.html file with a welcome message
    sudo systemctl restart apache2  # Restart Apache service to apply changes
EOF


  
    tags = {
        Name = "Terraform Instances"
    }
}

resource "aws_security_group" "ssh_access" {
  name_prefix = "ssh_access"
  vpc_id      =  aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  
resource "aws_eip" "eip" {
  instance = aws_instance.web_server.id
  
  tags = {
    Name = "test-eip"
  }
}
