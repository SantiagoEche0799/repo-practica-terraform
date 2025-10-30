region             = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
vpc_id             = null

ami                = "ami-0bbdd8c17ed981ef9"
instance_type      = "t3.micro"

bucket_prefix      = "devops-directive-web-app-prod"
domain             = "devopsdemodeployed-prod.com"

db_name            = "my_db_postgres"
db_user            = "demo_db_postgres"
db_pass            = "SuperSecureProdPass123!"
