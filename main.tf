# 1. depends_on  (S3 -> EC2 dependency)
resource "aws_s3_bucket" "data_bucket" {
  bucket = "my-data-bucket-${random_id.suffix.hex}"
}

resource "aws_instance" "app_server" {
  ami           = "ami-020cba7c55df1f615"  
  instance_type = "t2.micro"
  depends_on    = [aws_s3_bucket.data_bucket]
}

# 2. count  (3 identical instances)
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
}

# 3. for_each (Map-driven instances)
variable "server_names" {
  type    = set(string)
  default = ["app1", "app2", "app3"]
}

resource "aws_instance" "servers" {
  for_each      = var.server_names
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  tags = {
    Name = each.key
  }
}

# 4. lifecycle (Prevent destruction)
resource "aws_s3_bucket" "protected_bucket" {
  bucket = "do-not-delete-${random_id.suffix.hex}"
  lifecycle {
    prevent_destroy = false
  }
}

# 5. provider  (Multi-region)
provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu"
  region = "eu-west-1"
}

resource "aws_instance" "us_server" {
  provider      = aws.us
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
}

resource "aws_instance" "eu_server" {
  provider      = aws.eu
  ami           = "ami-01f23391a59163da9"
  instance_type = "t2.micro"
}

# 6. provisioner + connection Example
resource "aws_instance" "nginx" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  key_name      = "key_name"  

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file ("key_pair_name.pem")  
      host        = self.public_ip
    }
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx"
    ]
  }
}

# Supporting resource
resource "random_id" "suffix" {
  byte_length = 4
}