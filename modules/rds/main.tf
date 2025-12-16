resource "aws_security_group" "db_sg" {
  name        = "${var.name}-db-sg"
  description = "Database security group"
  vpc_id      = var.vpc_id

  # Ingress from app tier will be added as a separate rule from root.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-db-sg"
  }
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.name}-db-subnets"
  }
}

# PRIMARY
resource "aws_db_instance" "postgres_primary" {
  identifier              = "${var.name}-postgres-primary"
  allocated_storage       = var.allocated_storage
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  deletion_protection     = false
  publicly_accessible     = false
  backup_retention_period = 7

  # Optional: Multi-AZ can sit under the covers of that "Primary" block
  multi_az = var.multi_az

  tags = {
    Name = "${var.name}-postgres-primary"
    Role = "primary"
  }
}

# READ REPLICA (same region, other AZ / subnet)
resource "aws_db_instance" "postgres_read_replica" {
  identifier             = "${var.name}-postgres-replica"
  engine                 = "postgres"
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false

  replicate_source_db = aws_db_instance.postgres_primary.arn

  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Name = "${var.name}-postgres-replica"
    Role = "read-replica"
  }
}
