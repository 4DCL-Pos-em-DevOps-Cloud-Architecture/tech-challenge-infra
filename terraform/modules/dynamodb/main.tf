module "dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 2.0"

  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"
  range_key    = "timestamp"
  attributes = [
    {
      name = "event_id"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    }
  ]

  tags = var.tags
}