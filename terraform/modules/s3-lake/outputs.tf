output "pems_raw_bucket" {
  description = "Bucket for storing raw data from PeMS"
  value = {
    name = aws_s3_bucket.pems_raw.id
    arn  = aws_s3_bucket.pems_raw.arn
  }
}

output "pems_raw_read_write_policy" {
  description = "Policy for read/write access to the PeMS raw bucket"
  value = {
    name = aws_iam_policy.pems_raw_read_write.name
    arn  = aws_iam_policy.pems_raw_read_write.arn
  }
}
