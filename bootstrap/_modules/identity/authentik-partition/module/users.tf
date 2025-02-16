resource "authentik_user" "name" {
  for_each  = var.users
  name      = each.value.name
  email     = each.value.email
  type      = each.value.type
  username  = each.key
  is_active = each.value
  # groups   = [authentik_group.group.id]
}
