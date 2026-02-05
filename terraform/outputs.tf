output "summary" {
  description = "Deployment summary"
  value = <<-EOT
    
    ========================================
    Wiz Exercise Infrastructure Deployed
    ========================================
    
    Region: ${var.aws_region}
    
    MongoDB VM:
      - Public IP: ${aws_instance.mongodb.public_ip}
      - Private IP: ${aws_instance.mongodb.private_ip}
      - SSH: ssh ubuntu@${aws_instance.mongodb.public_ip}
      - Connection: ${aws_instance.mongodb.private_ip}:27017
    
    EKS Cluster:
      - Name: ${aws_eks_cluster.main.name}
      - Endpoint: ${aws_eks_cluster.main.endpoint}
      - Configure: aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}
    
    ECR Repository:
      - URL: ${aws_ecr_repository.wiz_app.repository_url}
    
    S3 Buckets:
      - Backups (PUBLIC): ${aws_s3_bucket.mongodb_backups.bucket}
      - Public URL: https://${aws_s3_bucket.mongodb_backups.bucket}.s3.amazonaws.com/
    
    Security Issues (Intentional):
      ⚠️  SSH exposed to 0.0.0.0/0
      ⚠️  MongoDB VM has excessive IAM permissions
      ⚠️  S3 bucket is publicly readable
      ⚠️  Outdated Ubuntu 20.04
      ⚠️  Outdated MongoDB 4.4
      ⚠️  Kubernetes pods have cluster-admin role
    
    Next Steps:
      1. Configure kubectl: aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}
      2. Deploy app: kubectl apply -f k8s/
      3. Enable security scanning
      4. Demonstrate vulnerability detection
    
    ========================================
  EOT
}
