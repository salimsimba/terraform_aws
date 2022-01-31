## AWS AutoScaling {{{1
## aws_launch_configuration {{{2
resource "aws_launch_configuration" "ecs_launch_config" {
  name                 = "${local.prefix}-ecs_launch_config"
  image_id             = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro"
  key_name             = var.key_name
  security_groups      = [aws_security_group.AppSG.id]
  user_data            = <<EOF
#!/bin/bash
amazon-linux-extras install epel -y
yum update -y
yum install nginx -y
echo -e "user nginx;\nworker_processes auto;\nerror_log /var/log/nginx/error.log;\nevents { worker_connections 1024; }\nhttp { server { listen 80; location / { root /var/www/html; } } }" > /etc/nginx/nginx.conf
mkdir -p /var/www/html/;chmod -R 755 /var/www/html/
touch /var/www/html/index.html
chmod -R 777 /var/www/html/index.html
MYIP=`ifconfig eth0 | grep inet | awk '{ print $2 }' | head -1`
host=`hostname`
echo "IP: $MYIP    HOST: $host" > /var/www/html/index.html
systemctl start nginx
EOF

  lifecycle {
    create_before_destroy = true
  }
}
## }}}2

## aws_autoscaling_group {{{2
resource "aws_autoscaling_group" "ec2_app_asg" {
  name                 = "${local.prefix}-ec2_app_asg"
  vpc_zone_identifier  = [aws_subnet.AppA.id, aws_subnet.AppB.id, aws_subnet.AppC.id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 6
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
}

## aws_autoscaling_policy {{{3
resource "aws_autoscaling_policy" "scale_up_cpu_policy" {
  name                   = "${local.prefix}-scale_up_cpu_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ec2_app_asg.name
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_down_cpu_policy" {
  name                   = "${local.prefix}-scale_down_cpu_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ec2_app_asg.name
  policy_type            = "SimpleScaling"
}
## }}}3
## }}}2

## aws_cloudwatch_metric_alarm {{{2
resource "aws_cloudwatch_metric_alarm" "scale_up_cpu_alarm" {
  alarm_name          = "${local.prefix}-scale_up_cpu_alarm"
  alarm_description   = "Increase EC2 instance on CPU utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_app_asg.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_up_cpu_policy.arn]

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "scale_down_cpu_alarm" {
  alarm_name          = "${local.prefix}-scale_down_cpu_alarm"
  alarm_description   = "Decrease EC2 instance on CPU utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_app_asg.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scale_down_cpu_policy.arn]

  tags = local.common_tags
}
## }}}2
## }}}1
