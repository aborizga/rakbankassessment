resource "aws_ecr_repository" "rakbank_ecr" {
    name = "rakbank-ecr"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
      scan_on_push = true
    } 
}