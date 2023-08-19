output "db_subnet_ids" {
  value       = module.vpc.db.*.id
  description = "List of private subnet IDs"
}