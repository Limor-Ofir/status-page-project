eks_cluster_name     = "limor-cluster"
node_group_name      = "limor-node-group"
vpc_id               = "vpc-0adf5159595ef567c"
private_subnet_ids   = ["subnet-04a525fe041945cf0", "subnet-0f436d38bb8f0ac97"]
public_subnet_ids    = ["subnet-0ac228099a9446754", "subnet-01891e293224bd322"]
acm_certificate_arn  = "arn:aws:acm:us-east-1:992382545251:certificate/ded63588-718d-4d09-93ad-f660877e4a55"  # Replace with your actual ACM certificate ARN

