variable "overlay_tz_uuid" {}
variable "tier0_router_uuid" {}
variable "edge_cluster_uuid" {}
variable "web_gateway" {}
variable "app_gateway" {}
variable "db_gateway" {}
variable "object_tag" {}
variable "object_scope" {
  default = "terraform"
}
