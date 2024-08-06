variable "secondary_region" {
  description = "Secondary AWS region"
  type        = string
}

variable "snapshot_id" {
  description = "Snapshot ID for DB instance restoration"
  type        = string
}

variable "desired_capacity" {
  description = "Desired capacity for instances in the secondary environment"
  type        = number
}

variable "max_size" {
  description = "Maximum size for auto-scaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum size for auto-scaling group"
  type        = number
}
