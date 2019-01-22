
data "nsxt_transport_zone" "overlay_tz" {
  id = "${var.overlay_tz_uuid}"
}

data "nsxt_edge_cluster" "edge_cluster" {
  id = "${var.edge_cluster_uuid}"
}

data "nsxt_logical_tier0_router" "tier0_router" {
  id = "${var.tier0_router_uuid}"
}


resource "nsxt_logical_switch" "webls" {
  admin_state       = "UP"
  description       = "LS created by Terraform"
  display_name      = "webls"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_tz.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}


resource "nsxt_logical_switch" "appls" {
  admin_state       = "UP"
  description       = "LS created by Terraform"
  display_name      = "appls"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_tz.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}


resource "nsxt_logical_switch" "dbls" {
  admin_state       = "UP"
  description       = "LS created by Terraform"
  display_name      = "dbls"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_tz.id}"
  replication_mode  = "MTEP"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}


resource "nsxt_logical_router_link_port_on_tier1" "link_port_T1_3tier_to_T0" {
  description                   = "TIER1_PORT1 provisioned by Terraform"
  display_name                  = "LRP_T1_3tier_to_T0"
  logical_router_id             = "${nsxt_logical_tier1_router.3tier_t1_router.id}"
  linked_logical_router_port_id = "${nsxt_logical_router_link_port_on_tier0.link_port_T0_to_T1_3tier.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}
resource "nsxt_logical_tier1_router" "3tier_t1_router" {
  description                 = "Tier1 router provisioned by Terraform"
  display_name                = "T1-3tier"
  enable_router_advertisement = true
  advertise_connected_routes  = true
  advertise_static_routes     = false
  advertise_nat_routes        = false
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_link_port_on_tier0" "link_port_T0_to_T1_3tier" {
  description       = "TIER0_PORT1 provisioned by Terraform"
  display_name      = "T0_to_T1_3tier"
  logical_router_id = "${data.nsxt_logical_tier0_router.tier0_router.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}

resource "nsxt_logical_port" "logical_port_on_webls" {
  admin_state       = "UP"
  description       = "LP1 provisioned by Terraform"
  display_name      = "lp_web"
  logical_switch_id = "${nsxt_logical_switch.webls.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
  
}

resource "nsxt_logical_router_downlink_port" "downlink_port_to_webls" {
  description                   = "DP1 provisioned by Terraform"
  display_name                  = "downlink_port_to_webls"
  logical_router_id             = "${nsxt_logical_tier1_router.3tier_t1_router.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.logical_port_on_webls.id}"
  ip_address                    = "${var.web_gateway}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}

resource "nsxt_logical_port" "logical_port_on_appls" {
  admin_state       = "UP"
  description       = "LP1 provisioned by Terraform"
  display_name      = "lp_app"
  logical_switch_id = "${nsxt_logical_switch.appls.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }

}

resource "nsxt_logical_router_downlink_port" "downlink_port_to_appls" {
  description                   = "DP1 provisioned by Terraform"
  display_name                  = "downlink_port_to_appls"
  logical_router_id             = "${nsxt_logical_tier1_router.3tier_t1_router.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.logical_port_on_appls.id}"
  ip_address                    = "${var.app_gateway}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}

resource "nsxt_logical_port" "logical_port_on_dbls" {
  admin_state       = "UP"
  description       = "LP1 provisioned by Terraform"
  display_name      = "lp_db"
  logical_switch_id = "${nsxt_logical_switch.dbls.id}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }

}

resource "nsxt_logical_router_downlink_port" "downlink_port_to_dbls" {
  description                   = "DP1 provisioned by Terraform"
  display_name                  = "downlink_port_to_dbls"
  logical_router_id             = "${nsxt_logical_tier1_router.3tier_t1_router.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.logical_port_on_dbls.id}"
  ip_address                    = "${var.db_gateway}"
  tag {
    scope = "${var.object_scope}"
    tag   = "${var.object_tag}"
  }
}

