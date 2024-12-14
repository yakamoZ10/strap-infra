locals {
  create = true

  project = "ultralinkk"

  number_of_strapi_servers = 2

  default_tags = {
    Project     = local.project
    Environment = var.environment
    Role        = "ultralinkk-server"
    Training    = "devops-engineer-associate"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${local.project}-ultralinkk-servers-asg"
  desired_capacity    = local.number_of_strapi_servers
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = data.terraform_remote_state.networking.outputs.strapi_server_subnets_ids

  launch_template {
    id      = aws_launch_template.strapi_server_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.strapi_servers.arn]

  tag {
    key                 = "Name"
    value               = "strapi"
    propagate_at_launch = true
  }
}


# resource "aws_autoscaling_policy" "scale_up" {
#   name                    = "${local.project}-strapi-scale-up"
#   scaling_adjustment      = 1
#   adjustment_type         = "ChangeInCapacity"
#   cooldown                = 30
#   autoscaling_group_name  = aws_autoscaling_group.asg.name
#   metric_aggregation_type = "Average"
# }

# resource "aws_autoscaling_policy" "scale_down" {
#   name                    = "${local.project}-strapi-scale-down"
#   scaling_adjustment      = -1
#   adjustment_type         = "ChangeInCapacity"
#   cooldown                = 30
#   autoscaling_group_name  = aws_autoscaling_group.asg.name
#   metric_aggregation_type = "Average"
# }


# resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
#   alarm_name          = "${local.project}-strapi-scale-up-on-80-percent-cpu"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 80
#   alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.asg.name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
#   alarm_name          = "${local.project}-web-scale-down-on-50-percent-cpu"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 60
#   statistic           = "Average"
#   threshold           = 50
#   alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.asg.name
#   }
# }

# resource "aws_sns_topic" "asg_topic" {
#   name = "asg-scaling"

#   # arn is an exported attribute
# }

# resource "aws_autoscaling_notification" "asg_notifications" {
#   group_names = [
#     aws_autoscaling_group.asg.name,
#   ]

#   notifications = [
#     "autoscaling:EC2_INSTANCE_LAUNCH",
#     "autoscaling:EC2_INSTANCE_TERMINATE",
#     "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
#     "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
#   ]

#   topic_arn = aws_sns_topic.asg_topic.arn
# }


# resource "aws_sns_topic_subscription" "aws_notifications" {
#   topic_arn = aws_sns_topic.asg_topic.arn
#   protocol  = "email"
#   endpoint  = local.subscriber
# }