output "public_subnets" {
  value = data.aws_subnets.public.ids
}