# Find outdated Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# MongoDB EC2 instance in public subnet (for SSH access)
resource "aws_instance" "mongodb" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.mongodb.id]
  iam_instance_profile   = aws_iam_instance_profile.mongodb_ec2.name

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              apt-get update
              
              # Install outdated MongoDB 4.4
              wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
              echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
              apt-get update
              apt-get install -y mongodb-org=4.4.* mongodb-org-server=4.4.* mongodb-org-shell=4.4.* mongodb-org-mongos=4.4.* mongodb-org-tools=4.4.*
              
              # Hold MongoDB version
              echo "mongodb-org hold" | dpkg --set-selections
              echo "mongodb-org-server hold" | dpkg --set-selections
              echo "mongodb-org-shell hold" | dpkg --set-selections
              echo "mongodb-org-mongos hold" | dpkg --set-selections
              echo "mongodb-org-tools hold" | dpkg --set-selections
              
              # Configure MongoDB to listen on all interfaces
              sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
              
              # Enable authentication
              cat >> /etc/mongod.conf <<EOL
              security:
                authorization: enabled
              EOL
              
              # Start MongoDB
              systemctl start mongod
              systemctl enable mongod
              
              # Wait for MongoDB to start
              sleep 10
              
              # Create admin user
              mongosh admin --eval 'db.createUser({user: "admin", pwd: "WizExercise2024!", roles: [{role: "root", db: "admin"}]})'
              
              # Create application database and user
              mongosh admin -u admin -p WizExercise2024! --eval 'use wiz-opportunities'
              mongosh wiz-opportunities -u admin -p WizExercise2024! --authenticationDatabase admin --eval 'db.createUser({user: "wizapp", pwd: "WizApp2024!", roles: [{role: "readWrite", db: "wiz-opportunities"}]})'
              
              # Install AWS CLI for backups
              apt-get install -y awscli
              
              # Create backup script
              cat > /usr/local/bin/mongodb-backup.sh <<'SCRIPT'
              #!/bin/bash
              TIMESTAMP=$(date +%Y%m%d_%H%M%S)
              BACKUP_DIR="/tmp/mongodb-backup-$TIMESTAMP"
              S3_BUCKET="${s3_backup_bucket}"
              
              # Create backup
              mongodump --uri="mongodb://admin:WizExercise2024!@localhost:27017" --out="$BACKUP_DIR"
              
              # Compress backup
              tar -czf "$BACKUP_DIR.tar.gz" -C /tmp "mongodb-backup-$TIMESTAMP"
              
              # Upload to S3
              aws s3 cp "$BACKUP_DIR.tar.gz" "s3://$S3_BUCKET/backups/mongodb-backup-$TIMESTAMP.tar.gz"
              
              # Cleanup
              rm -rf "$BACKUP_DIR" "$BACKUP_DIR.tar.gz"
              SCRIPT
              
              chmod +x /usr/local/bin/mongodb-backup.sh
              
              # Add cron job for daily backups at 2 AM
              echo "0 2 * * * /usr/local/bin/mongodb-backup.sh >> /var/log/mongodb-backup.log 2>&1" | crontab -
              
              # Create initial backup
              /usr/local/bin/mongodb-backup.sh
              
              echo "MongoDB setup complete"
              EOF

  tags = {
    Name = "${var.project_name}-mongodb"
  }

  depends_on = [aws_s3_bucket.mongodb_backups]
}

# Output MongoDB connection details
output "mongodb_private_ip" {
  description = "Private IP of MongoDB instance"
  value       = aws_instance.mongodb.private_ip
}

output "mongodb_public_ip" {
  description = "Public IP of MongoDB instance (for SSH)"
  value       = aws_instance.mongodb.public_ip
}

output "mongodb_connection_string" {
  description = "MongoDB connection string for application"
  value       = "mongodb://wizapp:WizApp2024!@${aws_instance.mongodb.private_ip}:27017/wiz-opportunities"
  sensitive   = true
}
