resource "aws_ecr_repository" "hello_flask" {
  name = "hello-flask"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}
output "ecr_repository_url" {
  value = aws_ecr_repository.hello_flask.repository_url
}
