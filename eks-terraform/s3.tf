resource "aws_s3_bucket" "rakbank" {
  bucket = "rakbanks3"
}

resource "aws_s3_bucket_ownership_controls" "s3acl" {
  bucket = aws_s3_bucket.rakbank.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.s3acl]

  bucket = aws_s3_bucket.rakbank.id
  acl    = "private"
}