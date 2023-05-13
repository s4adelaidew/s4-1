resource "aws_db_instance" "postgres" {
  identifier                  = format("%s-%s-artifactory-db", var.common_tags["Environment"], var.common_tags["Project"])
  engine                      = lookup(var.postgres, "engine")
  engine_version              = lookup(var.postgres, "engine_version")
  instance_class              = lookup(var.postgres, "instance_class")
  allocated_storage           = lookup(var.postgres, "allocated_storage")
  max_allocated_storage       = lookup(var.postgres, "max_allocated_storage")
  publicly_accessible         = lookup(var.postgres, "publicly_accessible")
  name                        = lookup(var.postgres, "name")
  username                    = lookup(var.postgres, "username")
  password                    = lookup(var.postgres, "password")
  final_snapshot_identifier   = format("%sArtifactorySnapshot", var.common_tags["Project"])
  skip_final_snapshot         = lookup(var.postgres, "skip_final_snapshot")
  parameter_group_name        = aws_db_parameter_group.postgres.name
  backup_retention_period     = lookup(var.postgres, "backup_retention_period")
  deletion_protection         = lookup(var.postgres, "deletion_protection")
  maintenance_window          = lookup(var.postgres, "maintenance_window")
  multi_az                    = lookup(var.postgres, "multi_az")
  allow_major_version_upgrade = lookup(var.postgres, "allow_major_version_upgrade")
  auto_minor_version_upgrade  = lookup(var.postgres, "auto_minor_version_upgrade")

  vpc_security_group_ids = [aws_security_group.postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name

  tags = merge(var.common_tags, {
    Name = format("%s-%s-%s-artifactory-db", var.common_tags["AssetID"], var.common_tags["Environment"], var.common_tags["Project"])
    },
  )
}

resource "aws_security_group" "postgres" {
  name_prefix = format("%s-%s-%s-artifactory-db-sg", var.common_tags["AssetID"], var.common_tags["Environment"], var.common_tags["Project"])
  vpc_id      = data.aws_vpc.alpha-vpc.id
}

resource "aws_security_group_rule" "postgres_ingress" {
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.postgres.id
}

resource "aws_security_group_rule" "postgres_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.postgres.id
}

resource "aws_db_subnet_group" "postgres" {
  name = format("%s-%s-subnet-group", var.common_tags["Environment"], var.common_tags["Project"])
  subnet_ids = [
    data.aws_subnet.apha-private-subnet1.id,
    data.aws_subnet.apha-private-subnet2.id
  ]
}

resource "aws_db_parameter_group" "postgres" {
  name   = format("%s-%s-artifactory-parameter-group", var.common_tags["Environment"], var.common_tags["Project"])
  family = lookup(var.postgres, "family")
}

