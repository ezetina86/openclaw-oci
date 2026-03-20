variable "tenancy_ocid" {
  description = "The OCID of the root tenancy. Required for budget and IAM resources."
  type        = string
}

variable "budget_alert_email" {
  description = "Email address to notify when budget threshold is breached."
  type        = string
}

# A $1/month budget scoped to the entire tenancy.
# Since this account should always be within the Always Free tier,
# any spend above $1 indicates an unexpected billable resource.
resource "oci_budget_budget" "openclaw_spend_alert" {
  compartment_id = var.tenancy_ocid
  amount         = 1
  reset_period   = "MONTHLY"
  display_name   = "openclaw-spend-alert"
  description    = "Alert on any spend. Free tier should always be zero."
  target_type    = "COMPARTMENT"
  targets        = [var.tenancy_ocid]
}

resource "oci_budget_alert_rule" "openclaw_alert_rule" {
  budget_id      = oci_budget_budget.openclaw_spend_alert.id
  threshold      = 100
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  display_name   = "openclaw-100pct-alert"
  description    = "Notify when 100% of the $1 budget is consumed."
  recipients     = var.budget_alert_email
  message        = "OpenClaw OCI spend has exceeded $1 this month. Review your resources immediately."
}
