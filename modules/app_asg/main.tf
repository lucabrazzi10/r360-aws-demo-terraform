resource "aws_security_group" "app_sg" {
  name        = "${var.name}-app-sg"
  description = "App tier security group"
  vpc_id      = var.vpc_id

  # Ingress from web tier SG will be added from the root module.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-app-sg"
  }
}

# Internal ALB Security Group (receives traffic from web tier)
resource "aws_security_group" "app_alb_sg" {
  name        = "${var.name}-app-alb-sg"
  description = "App internal ALB security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-app-alb-sg"
  }
}

# Allow ALB -> App instances on 8000
resource "aws_security_group_rule" "app_from_alb" {
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.app_alb_sg.id
  description              = "Allow app traffic from internal ALB"
}

locals {
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y docker
              systemctl enable docker
              systemctl start docker

              EFS_DNS="${var.efs_mount_target_dns}"

              if [ -n "$EFS_DNS" ]; then
                yum install -y amazon-efs-utils
                mkdir -p /mnt/r360-share
                echo "$EFS_DNS:/ /mnt/r360-share efs defaults,_netdev 0 0" >> /etc/fstab
                mount -a -t efs defaults
              fi

              docker run -d --restart=always --name rgs-core \
                -p 8000:8000 \
                -e DATABASE_URL=${var.db_endpoint} \
                rgs-core:1.8.0
              EOF
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.name}-app-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(local.user_data)

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-app"
      Tier = "app"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "app_alb" {
  name               = "${var.name}-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_alb_sg.id]
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.name}-app-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.name}-app-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 20
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.name}-app-tg"
  }
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.name}-app-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 120

  # private app subnets like the diagram's "Private subnet" pair
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.name}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
