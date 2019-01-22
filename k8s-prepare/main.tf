provider "nsxt" {
  host                  = "${var.nsxmanager_host}"
  username              = "${var.nsxmanager_username}"
  password              = "${var.nsxmanager_password}"
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

data "nsxt_transport_zone" "overlay_tz" {
  id = "${var.overlay_tz_uuid}"
}

data "nsxt_edge_cluster" "edge_cluster" {
  id = "${var.edge_cluster_uuid}"
}

data "nsxt_logical_tier0_router" "tier0_router" {
  id = "${var.tier0_router_uuid}"
}

resource "nsxt_ip_pool" "ippool" {
  description = "ip_pool provisioned by Terraform"
  display_name = "ippool-k8s"

  subnet = {
    allocation_ranges = ["${var.k8s_ippool_allocation_range}"]
    cidr              = "${var.k8s_ippool_cidr}"
  }
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}

resource "nsxt_ip_block" "k8s_ipblock" {
  description  = "ip_block provisioned by Terraform"
  display_name = "ipblock-k8s"
  cidr         = "${var.k8s_ipblock_cidr}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}


resource "nsxt_logical_switch" "ls" {
  admin_state       = "UP"
  description       = "LS created by Terraform"
  display_name      = "ls-k8s-pod"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_tz.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_tier1_router" "tier1_router" {
  description                 = "Tier1 router provisioned by Terraform"
  display_name                = "T1-VM2-k8s-pod"
  enable_router_advertisement = true
  advertise_connected_routes  = true
  advertise_static_routes     = false
  advertise_nat_routes        = false
  failover_mode               = "PREEMPTIVE"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_link_port_on_tier1" "link_port_T1_to_T0" {
  description                   = "TIER1_PORT1 provisioned by Terraform"
  display_name                  = "rp_on_T1-VM2-k8s-pod"
  logical_router_id             = "${nsxt_logical_tier1_router.tier1_router.id}"
  linked_logical_router_port_id = "${nsxt_logical_router_link_port_on_tier0.link_port_T0_to_T1.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_link_port_on_tier0" "link_port_T0_to_T1" {
  description       = "TIER0_PORT1 provisioned by Terraform"
  display_name      = "lp_on_T0-VM2"
  logical_router_id = "${data.nsxt_logical_tier0_router.tier0_router.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}


resource "nsxt_logical_port" "logical_port" {
  admin_state       = "UP"
  description       = "LP1 provisioned by Terraform"
  display_name      = "lp_on_k8s-pod"
  logical_switch_id = "${nsxt_logical_switch.ls.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_downlink_port" "downlink_port_to_ls" {
  description                   = "DP1 provisioned by Terraform"
  display_name                  = "dp_to_ls-k8s-pod"
  logical_router_id             = "${nsxt_logical_tier1_router.tier1_router.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.logical_port.id}"
  ip_address                    = "${var.k8s_pod_gateway}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}



resource "nsxt_logical_switch" "ls_dummy" {
  admin_state       = "UP"
  description       = "LS created by Terraform"
  display_name      = "ls-dummy"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_tz.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_tier1_router" "tier1_router_lb" {
  description                 = "Tier1 router provisioned by Terraform"
  display_name                = "T1-VM2-k8s-lb"
  edge_cluster_id             = "${data.nsxt_edge_cluster.edge_cluster.id}"
  enable_router_advertisement = true
  advertise_connected_routes  = false
  advertise_static_routes     = false
  advertise_lb_vip_routes     = true
  advertise_nat_routes        = false
  failover_mode               = "PREEMPTIVE"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_link_port_on_tier1" "link_port_T1lb_to_T0" {
  description                   = "TIER1_PORT1 provisioned by Terraform"
  display_name                  = "rp_on_T1-VM2-k8s-lb"
  logical_router_id             = "${nsxt_logical_tier1_router.tier1_router_lb.id}"
  linked_logical_router_port_id = "${nsxt_logical_router_link_port_on_tier0.link_port_T0_to_T1lb.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_link_port_on_tier0" "link_port_T0_to_T1lb" {
  description       = "TIER0_PORT1 provisioned by Terraform"
  display_name      = "lp_on_T0-VM2"
  logical_router_id = "${data.nsxt_logical_tier0_router.tier0_router.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}


resource "nsxt_logical_port" "logical_port_dummy" {
  admin_state       = "UP"
  description       = "LP1 provisioned by Terraform"
  display_name      = "lp_on_ls_dummy"
  logical_switch_id = "${nsxt_logical_switch.ls_dummy.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_downlink_port" "downlink_port_to_ls_dummy" {
  description                   = "DP1 provisioned by Terraform"
  display_name                  = "dp_to_ls-dummy"
  logical_router_id             = "${nsxt_logical_tier1_router.tier1_router_lb.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.logical_port_dummy.id}"
  ip_address                    = "169.254.254.1/24"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_lb_fast_tcp_application_profile" "lb_tcp_profile_k8s" {
  description       = "lb_fast_tcp_application_profile provisioned by Terraform"
  display_name      = "lb_tcp_profile_k8s"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}

resource "nsxt_lb_tcp_monitor" "lb_tcp_monitor_k8s" {
  description  = "lb_tcp_monitor_k8s provisioned by Terraform"
  display_name = "lb_tcp_monitor_k8s"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}

resource "nsxt_lb_service" "lb_for_k8s" {
  description  = "lb_on_t1sa provisioned by Terraform"
  display_name = "lb-for-k8s"
  enabled           = true
  logical_router_id = "${nsxt_logical_tier1_router.tier1_router_lb.id}"
  error_log_level   = "INFO"
  size              = "SMALL"
  virtual_server_ids = ["${nsxt_lb_tcp_virtual_server.lb_vs_k8s_api.id}"]
  depends_on        = ["nsxt_logical_router_link_port_on_tier1.link_port_T1lb_to_T0"]
}

resource "nsxt_lb_pool" "lb_pool_k8s_api" {
  description              = "lb_pool_k8s_api provisioned by Terraform"
  display_name             = "lb_pool_k8s_api"
  algorithm                = "LEAST_CONNECTION"
  active_monitor_id        = "${nsxt_lb_tcp_monitor.lb_tcp_monitor_k8s.id}"

  snat_translation {
    type = "SNAT_AUTO_MAP"
  }

  member {
    admin_state                = "ENABLED"
    backup_member              = "false"
    display_name               = "k8s-master1"    
    ip_address                 = "192.168.91.71"    
    port                       = "6443"
  }

  member {
    admin_state                = "ENABLED"
    backup_member              = "false"
    display_name               = "k8s-master2"    
    ip_address                 = "192.168.91.72"
    port                       = "6443"
  }
  
  member {
    admin_state                = "ENABLED"
    backup_member              = "false"
    display_name               = "k8s-master3"
    ip_address                 = "192.168.91.73"    
    port                       = "6443"
  }
  
}

resource "nsxt_lb_tcp_virtual_server" "lb_vs_k8s_api" {
  description                = "lb-vs-k8s-api provisioned by terraform"
  display_name               = "lb-vs-k8s-api"
  access_log_enabled         = true
  application_profile_id     = "${nsxt_lb_fast_tcp_application_profile.lb_tcp_profile_k8s.id}"
  enabled                    = true
  ip_address                 = "192.168.91.129"
  ports                      = ["6443"]
  default_pool_member_ports  = ["6443"]
  pool_id                    = "${nsxt_lb_pool.lb_pool_k8s_api.id}"
}
