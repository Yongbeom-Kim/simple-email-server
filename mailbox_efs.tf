resource "aws_efs_file_system" "mailbox" {
  creation_token = "${var.service_name}-mailbox-efs"
  encrypted = true
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  lifecycle_policy {
    # transition_to_archive = "AFTER_30_DAYS"
    transition_to_ia = "AFTER_14_DAYS"
  }

  tags = {
    Name = "${var.service_name}-mailbox-efs"
  }
}

resource "aws_efs_access_point" "mailbox" {
  file_system_id = aws_efs_file_system.mailbox.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/mailbox"
    creation_info {
      owner_uid = 1000
      owner_gid = 1000
      permissions = "755"
    }
  }
}

resource "aws_efs_mount_target" "mailbox" {
  file_system_id = aws_efs_file_system.mailbox.id
  subnet_id      = aws_subnet.private.id
  security_groups = [ aws_security_group.allow_all_local.id ]
}

// TODO: EFS Mount commands that can be used to mount the EFS filesystem in an EC2 instance (inside the VPC)
output "efs_mount_command" {
    value = "sudo mount -t efs -o tls,mounttargetip=${aws_efs_mount_target.mailbox.ip_address} ${aws_efs_file_system.mailbox.id} /efs"
}

output "efs_mount_access_point_command" {
    value = "sudo mount -t efs -o tls,mounttargetip=${aws_efs_mount_target.mailbox.ip_address},accesspoint=${aws_efs_access_point.mailbox.id} ${aws_efs_file_system.mailbox.id} /efs"
}