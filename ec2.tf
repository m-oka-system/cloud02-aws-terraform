################################
# ENI
################################
resource "aws_network_interface" "web_01" {
  subnet_id       = aws_subnet.public_subnet_1a.id
  private_ips     = ["10.0.11.11"]
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "${var.prefix}-web-01"
  }
}

resource "aws_network_interface" "web_02" {
  subnet_id       = aws_subnet.public_subnet_1c.id
  private_ips     = ["10.0.12.11"]
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "${var.prefix}-web-02"
  }
}

################################
# EC2
################################
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "web_01" {
  ami                     = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type           = "t2.micro"
  count                   = 1
  iam_instance_profile    = aws_iam_instance_profile.ec2.name
  disable_api_termination = false
  monitoring              = false
  user_data               = file("./param/userdata.sh")
  key_name                = "${var.prefix}-key"

  network_interface {
    network_interface_id = aws_network_interface.web_01.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name = "${var.prefix}-web-01"
  }

  volume_tags = {
    Name = "${var.prefix}-web-01"
  }
}

resource "aws_instance" "web_02" {
  ami                     = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type           = "t2.micro"
  count                   = 1
  iam_instance_profile    = aws_iam_instance_profile.ec2.name
  disable_api_termination = false
  monitoring              = false
  user_data               = file("./param/userdata.sh")
  key_name                = "${var.prefix}-key"

  network_interface {
    network_interface_id = aws_network_interface.web_02.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name = "${var.prefix}-web-02"
  }

  volume_tags = {
    Name = "${var.prefix}-web-02"
  }
}


output "web01_public_ip" {
  description = "valThe public IP address assigned to the instanceue"
  value       = aws_instance.web_01[0].public_ip
}

output "web02_public_ip" {
  description = "valThe public IP address assigned to the instanceue"
  value       = aws_instance.web_02[0].public_ip
}
