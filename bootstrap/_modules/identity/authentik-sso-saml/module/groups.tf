
# data "authentik_user" "management-cluster" {
#   for_each = toset(var.management-cluster)
#   username = each.key
# }

# data "authentik_user" "management-organization" {
#   for_each = toset(var.management-organization)
#   username = each.key
# }

# data "authentik_user" "users" {
#   for_each = toset(var.users)
#   username = each.key
# }


# resource "authentik_group" "management-cluster" {
#   name       = "${var.tenantName}-${var.appName}-management-cluster"
#   attributes = "{\"tenant\": \"${var.tenantName}\", \"app\": \"${var.appName}\", \"LogScaleIsRoot\": true}"
#   users      = [for u in data.authentik_user.management-cluster : u.id]
# }
# resource "authentik_group" "management-organization" {
#   name       = "${var.tenantName}-${var.appName}-management-organization"
#   attributes = "{\"tenant\": \"${var.tenantName}\", \"app\": \"${var.appName}\", \"LogScaleIsRoot\": true}"
#   users      = [for u in data.authentik_user.management-organization : u.id]
# }

# resource "authentik_group" "users" {
#   name       = "${var.tenantName}-${var.appName}-users"
#   attributes = "{\"tenant\": \"${var.tenantName}\", \"app\": \"${var.appName}\"}"
#   users      = [for u in data.authentik_user.users : u.id]
# }
