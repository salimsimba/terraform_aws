resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.prefix}-ecs_cluster"

  tags = local.common_tags
}

resource "aws_ecs_task_definition" "task_definition" {
  family = "${local.prefix}-app-service"

  container_definitions = jsonencode([
    {
      name         = var.app_container_name
      essential    = true
      memory       = 256
      cpu          = 2
      image        = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.app_image_name}"
      environment  = [],
      portMappings = [
        {
          containerPort = var.app_container_port
          hostPort      = var.app_container_port
        }
      ]
    },
  ])

  tags = local.common_tags
}

resource "aws_ecs_service" "app_service" {
  name            = "${local.prefix}-app-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_grp.arn
    container_name   = var.app_container_name
    container_port   = var.app_container_port
  }

  depends_on = [aws_lb_listener.http]
}
